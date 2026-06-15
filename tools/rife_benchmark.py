#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
import re
import statistics
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VSPIPE = ROOT / "VSPipe.exe"
PREBUILD = ROOT / "docs" / "research" / "rife-engine-prebuild-2026-06-15" / "rife-engine-combos.csv"


def load_combos() -> list[dict[str, str]]:
    rows = list(csv.DictReader(PREBUILD.open("r", encoding="utf-8")))
    return [r for r in rows if r.get("status") == "ok"]


def write_vpy(path: Path, row: dict[str, str], frames: int, width: int, height: int) -> None:
    model = int(row["model"])
    turbo = int(row["turbo"])
    flow_scale = float(row["flow_scale"])
    h_pre = int(row["h_pre"])
    code = f'''
import vapoursynth as vs
from vapoursynth import core
import k7sfunc as k7f

core.num_threads = k7f.vs_t_dft
clip = core.std.BlankClip(width={width}, height={height}, format=vs.YUV420P16, length={max(frames + 5, 16)}, fpsnum=25, fpsden=1, color=[4096, 32768, 32768])
clip = k7f.FMT_CTRL(clip, h_max={h_pre}, fmt_pix=0)
clip = k7f.RIFE_NV(
    clip,
    model={model},
    int8_qnt=False,
    turbo={turbo},
    fps_in=25.0,
    fps_num=2,
    fps_den=1,
    sc_mode=1,
    gpu=0,
    gpu_t=2,
    ws_size=0,
    flow_scale={flow_scale},
)
clip.set_output()
'''.lstrip()
    path.write_text(code, encoding="utf-8", newline="\n")


def parse_fps(stderr: str) -> float | None:
    matches = re.findall(r"Output\s+\d+\s+frames\s+in\s+[0-9.]+\s+seconds\s+\(([0-9.]+)\s+fps\)", stderr)
    if matches:
        return float(matches[-1])
    return None


def run_once(row: dict[str, str], log_dir: Path, run_index: int, frames: int, width: int, height: int, timeout: int) -> dict[str, object]:
    combo_id = row["combo_id"]
    vpy = log_dir / f"{combo_id}.bench.vpy"
    stdout = log_dir / f"{combo_id}.run{run_index}.stdout.txt"
    stderr = log_dir / f"{combo_id}.run{run_index}.stderr.txt"
    write_vpy(vpy, row, frames, width, height)
    cmd = [str(VSPIPE), "--start", "0", "--end", str(max(frames - 1, 0)), str(vpy), "--"]
    started = time.perf_counter()
    proc = subprocess.run(cmd, cwd=str(ROOT), text=True, encoding="utf-8", errors="replace", stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=timeout)
    elapsed = time.perf_counter() - started
    stdout.write_text(proc.stdout, encoding="utf-8", newline="\n")
    stderr.write_text(proc.stderr, encoding="utf-8", newline="\n")
    return {
        "returncode": proc.returncode,
        "elapsed_seconds": round(elapsed, 3),
        "fps": parse_fps(proc.stderr),
        "stdout": str(stdout.relative_to(log_dir.parent)),
        "stderr": str(stderr.relative_to(log_dir.parent)),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--limit", type=int, default=0)
    parser.add_argument("--frames", type=int, default=100)
    parser.add_argument("--runs", type=int, default=3)
    parser.add_argument("--timeout", type=int, default=600)
    parser.add_argument("--width", type=int, default=3840)
    parser.add_argument("--height", type=int, default=2160)
    parser.add_argument("--out", type=Path, default=ROOT / "docs" / "research" / "rife-benchmark-4k-2026-06-15")
    args = parser.parse_args()

    combos = load_combos()
    if args.limit:
        combos = combos[: args.limit]
    args.out.mkdir(parents=True, exist_ok=True)
    log_dir = args.out / "logs"
    log_dir.mkdir(exist_ok=True)
    result_path = args.out / "rife-benchmark-4k.csv"
    fieldnames = [
        "combo_id", "model", "label", "turbo", "flow_scale", "h_pre", "status",
        "run1_fps", "run2_fps", "run3_fps", "median_fps", "mean_fps", "min_fps", "max_fps",
        "run1_elapsed", "run2_elapsed", "run3_elapsed", "notes",
    ]
    results: list[dict[str, object]] = []
    if args.dry_run:
        for row in combos:
            results.append({"combo_id": row["combo_id"], "model": row["model"], "label": row["label"], "turbo": row["turbo"], "flow_scale": row["flow_scale"], "h_pre": row["h_pre"], "status": "planned", "run1_fps": "", "run2_fps": "", "run3_fps": "", "median_fps": "", "mean_fps": "", "min_fps": "", "max_fps": "", "run1_elapsed": "", "run2_elapsed": "", "run3_elapsed": "", "notes": ""})
    else:
        for index, row in enumerate(combos, 1):
            print(f"[{index}/{len(combos)}] {row['combo_id']}", flush=True)
            run_results=[]
            status="ok"
            notes=[]
            for run_index in range(1, args.runs + 1):
                try:
                    rr = run_once(row, log_dir, run_index, args.frames, args.width, args.height, args.timeout)
                except subprocess.TimeoutExpired as exc:
                    rr = {"returncode": "timeout", "elapsed_seconds": args.timeout, "fps": None, "stderr": repr(exc)}
                if rr["returncode"] != 0 or rr["fps"] is None:
                    status="failed"
                    notes.append(f"run{run_index} failed")
                run_results.append(rr)
            fps_values=[float(r["fps"]) for r in run_results if r.get("fps") is not None]
            result={
                "combo_id": row["combo_id"], "model": row["model"], "label": row["label"], "turbo": row["turbo"], "flow_scale": row["flow_scale"], "h_pre": row["h_pre"], "status": status,
                "run1_fps": run_results[0].get("fps") if len(run_results)>0 else "",
                "run2_fps": run_results[1].get("fps") if len(run_results)>1 else "",
                "run3_fps": run_results[2].get("fps") if len(run_results)>2 else "",
                "median_fps": round(statistics.median(fps_values), 3) if fps_values else "",
                "mean_fps": round(statistics.mean(fps_values), 3) if fps_values else "",
                "min_fps": round(min(fps_values), 3) if fps_values else "",
                "max_fps": round(max(fps_values), 3) if fps_values else "",
                "run1_elapsed": run_results[0].get("elapsed_seconds") if len(run_results)>0 else "",
                "run2_elapsed": run_results[1].get("elapsed_seconds") if len(run_results)>1 else "",
                "run3_elapsed": run_results[2].get("elapsed_seconds") if len(run_results)>2 else "",
                "notes": "; ".join(notes),
            }
            results.append(result)
            with result_path.open("w", newline="", encoding="utf-8") as f:
                writer=csv.DictWriter(f, fieldnames=fieldnames)
                writer.writeheader(); writer.writerows(results)

    with result_path.open("w", newline="", encoding="utf-8") as f:
        writer=csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader(); writer.writerows(results)
    summary = {
        "combo_count": len(results), "dry_run": args.dry_run, "frames": args.frames, "runs": args.runs,
        "ok_count": sum(1 for r in results if r["status"] == "ok"),
        "failed_count": sum(1 for r in results if r["status"] == "failed"),
    }
    (args.out / "summary.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
    (args.out / "README.md").write_text(
        "# RIFE 4K Benchmark（2026-06-15）\n\n"
        f"- 分辨率：`{args.width}x{args.height}`\n"
        f"- 每组帧数：`{args.frames}`\n"
        f"- 每组次数：`{args.runs}`\n"
        f"- 组合数：`{len(results)}`\n"
        "- 结果表：`rife-benchmark-4k.csv`\n",
        encoding="utf-8", newline="\n"
    )
    print(f"wrote {result_path}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
