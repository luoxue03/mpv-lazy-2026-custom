#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
import subprocess
import time
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VSPIPE = ROOT / "VSPipe.exe"

MODELS = [(46, "4.6", True), (4151, "4.15 lite", False), (422, "4.22", False), (4221, "4.22 lite", False), (4251, "4.25 lite", False), (426, "4.26", False), (4262, "4.26 heavy", False), (47, "4.7", False), (48, "4.8", False), (49, "4.9", False)]
TURBOS = [0, 1, 2]
FLOW_SCALES_ALL = [1.0, 0.5, 0.25]
H_PRE_VALUES = [2160, 1920, 1608, 1440]

@dataclass(frozen=True)
class Combo:
    model: int
    label: str
    turbo: int
    flow_scale: float
    h_pre: int


def combos() -> list[Combo]:
    items: list[Combo] = []
    for model, label, supports_flow in MODELS:
        flow_values = FLOW_SCALES_ALL if supports_flow else [1.0]
        for turbo in TURBOS:
            for flow_scale in flow_values:
                # vsmlrt RIFEMerge path currently does not support 4.6 turbo=0 with downscaled flow.
                # Skipping avoids known-fast failures and 0-byte engine remnants.
                if model == 46 and turbo == 0 and flow_scale != 1.0:
                    continue
                for h_pre in H_PRE_VALUES:
                    items.append(Combo(model, label, turbo, flow_scale, h_pre))
    return items


def combo_id(combo: Combo) -> str:
    flow = str(combo.flow_scale).replace(".", "p")
    label = combo.label.replace(" ", "_").replace(".", "p")
    return f"m{combo.model}_{label}_t{combo.turbo}_f{flow}_h{combo.h_pre}"


def write_vpy(path: Path, combo: Combo, frames: int) -> None:
    code = f'''
import vapoursynth as vs
from vapoursynth import core
import k7sfunc as k7f

core.num_threads = k7f.vs_t_dft
clip = core.std.BlankClip(width=3840, height=2160, format=vs.YUV420P16, length={max(frames + 3, 8)}, fpsnum=25, fpsden=1, color=[4096, 32768, 32768])
clip = k7f.FMT_CTRL(clip, h_max={combo.h_pre}, fmt_pix=0)
clip = k7f.RIFE_NV(
    clip,
    model={combo.model},
    int8_qnt=False,
    turbo={combo.turbo},
    fps_in=25.0,
    fps_num=2,
    fps_den=1,
    sc_mode=1,
    gpu=0,
    gpu_t=2,
    ws_size=0,
    flow_scale={combo.flow_scale},
)
clip.set_output()
'''.lstrip()
    path.write_text(code, encoding="utf-8", newline="\n")


def engine_snapshot() -> set[str]:
    model_root = ROOT / "vs-plugins" / "models"
    if not model_root.exists():
        return set()
    return {str(p.relative_to(model_root)).replace("\\", "/") for p in model_root.rglob("*.engine")}


def cleanup_zero_engines() -> list[str]:
    model_root = ROOT / "vs-plugins" / "models"
    removed: list[str] = []
    if not model_root.exists():
        return removed
    for path in model_root.rglob("*.engine"):
        try:
            if path.is_file() and path.stat().st_size == 0:
                removed.append(str(path.relative_to(model_root)).replace("\\", "/"))
                path.unlink()
        except OSError:
            pass
    return removed


def run_combo(combo: Combo, log_dir: Path, frames: int, timeout: int) -> dict[str, object]:
    vpy = log_dir / f"{combo_id(combo)}.vpy"
    stdout = log_dir / f"{combo_id(combo)}.stdout.txt"
    stderr = log_dir / f"{combo_id(combo)}.stderr.txt"
    write_vpy(vpy, combo, frames)
    before = engine_snapshot()
    cmd = [str(VSPIPE), "--start", "0", "--end", str(max(frames - 1, 0)), str(vpy), "--"]
    started = time.perf_counter()
    proc = subprocess.run(cmd, cwd=str(ROOT), text=True, encoding="utf-8", errors="replace", stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=timeout)
    elapsed = time.perf_counter() - started
    stdout.write_text(proc.stdout, encoding="utf-8", newline="\n")
    stderr.write_text(proc.stderr, encoding="utf-8", newline="\n")
    removed_zero = cleanup_zero_engines()
    after = engine_snapshot()
    new_engines = sorted(after - before)
    return {"combo_id": combo_id(combo), "model": combo.model, "label": combo.label, "turbo": combo.turbo, "flow_scale": combo.flow_scale, "h_pre": combo.h_pre, "status": "ok" if proc.returncode == 0 else "failed", "returncode": proc.returncode, "elapsed_seconds": round(elapsed, 3), "new_engine_count": len(new_engines), "new_engines": ";".join(new_engines), "stdout": str(stdout.relative_to(log_dir.parent)), "stderr": str(stderr.relative_to(log_dir.parent)), "removed_zero_engines": ";".join(removed_zero)}


def write_rows(path: Path, rows: list[dict[str, object]], fieldnames: list[str]) -> None:
    with path.open("w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--limit", type=int, default=0)
    parser.add_argument("--frames", type=int, default=2)
    parser.add_argument("--timeout", type=int, default=900)
    parser.add_argument("--out", type=Path, default=ROOT / "docs" / "research" / "rife-engine-prebuild-2026-06-15")
    args = parser.parse_args()
    all_combos = combos()
    if args.limit:
        all_combos = all_combos[:args.limit]
    args.out.mkdir(parents=True, exist_ok=True)
    log_dir = args.out / "logs"
    log_dir.mkdir(exist_ok=True)
    matrix_path = args.out / "rife-engine-combos.csv"
    fieldnames = ["combo_id", "model", "label", "turbo", "flow_scale", "h_pre", "status", "returncode", "elapsed_seconds", "new_engine_count", "new_engines", "stdout", "stderr", "removed_zero_engines"]
    rows: list[dict[str, object]] = []
    if args.dry_run:
        for combo in all_combos:
            rows.append({"combo_id": combo_id(combo), "model": combo.model, "label": combo.label, "turbo": combo.turbo, "flow_scale": combo.flow_scale, "h_pre": combo.h_pre, "status": "planned", "returncode": "", "elapsed_seconds": "", "new_engine_count": "", "new_engines": "", "stdout": "", "stderr": "", "removed_zero_engines": ""})
        write_rows(matrix_path, rows, fieldnames)
    else:
        for index, combo in enumerate(all_combos, 1):
            print(f"[{index}/{len(all_combos)}] {combo_id(combo)}", flush=True)
            try:
                row = run_combo(combo, log_dir, args.frames, args.timeout)
            except subprocess.TimeoutExpired as exc:
                row = {"combo_id": combo_id(combo), "model": combo.model, "label": combo.label, "turbo": combo.turbo, "flow_scale": combo.flow_scale, "h_pre": combo.h_pre, "status": "timeout", "returncode": "timeout", "elapsed_seconds": args.timeout, "new_engine_count": "", "new_engines": "", "stdout": "", "stderr": repr(exc), "removed_zero_engines": ""}
            except Exception as exc:
                row = {"combo_id": combo_id(combo), "model": combo.model, "label": combo.label, "turbo": combo.turbo, "flow_scale": combo.flow_scale, "h_pre": combo.h_pre, "status": "error", "returncode": "error", "elapsed_seconds": "", "new_engine_count": "", "new_engines": "", "stdout": "", "stderr": repr(exc), "removed_zero_engines": ""}
            rows.append(row)
            write_rows(matrix_path, rows, fieldnames)
    summary = {"combo_count": len(rows), "dry_run": args.dry_run, "frames": args.frames, "timeout": args.timeout, "status_counts": {status: sum(1 for row in rows if row["status"] == status) for status in sorted({row["status"] for row in rows})}}
    (args.out / "summary.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
    (args.out / "README.md").write_text("# RIFE Engine 预构建记录（2026-06-15）\n\n" f"- 组合数：`{len(rows)}`\n" f"- frames：`{args.frames}`\n" f"- timeout：`{args.timeout}` 秒/组合\n" f"- dry-run：`{args.dry_run}`\n" "- 结果表：`rife-engine-combos.csv`\n" "- 日志目录：`logs/`\n", encoding="utf-8", newline="\n")
    print(f"wrote {matrix_path}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
