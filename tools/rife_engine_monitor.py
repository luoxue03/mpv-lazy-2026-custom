
#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
import time
from collections import Counter
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "docs" / "research" / "rife-engine-prebuild-2026-06-15"
CSV_PATH = BASE / "rife-engine-combos.csv"
CONSOLE_LOG = BASE / "full-run-console.log"
MONITOR_LOG = BASE / "monitor.log"
STATUS_JSON = BASE / "monitor-status.json"
MODEL_ROOT = ROOT / "vs-plugins" / "models"


def read_rows() -> list[dict[str, str]]:
    if not CSV_PATH.exists():
        return []
    try:
        with CSV_PATH.open("r", encoding="utf-8", newline="") as file:
            return list(csv.DictReader(file))
    except Exception:
        return []


def zero_engines() -> list[str]:
    if not MODEL_ROOT.exists():
        return []
    out = []
    for path in MODEL_ROOT.rglob("*.engine"):
        try:
            if path.is_file() and path.stat().st_size == 0:
                out.append(str(path.relative_to(MODEL_ROOT)).replace("\\", "/"))
        except OSError:
            pass
    return sorted(out)


def console_tail() -> str:
    if not CONSOLE_LOG.exists():
        return ""
    try:
        lines = CONSOLE_LOG.read_text(encoding="utf-8", errors="replace").splitlines()
        return "\n".join(lines[-5:])
    except Exception:
        return ""


def snapshot(total: int) -> dict[str, object]:
    rows = read_rows()
    counts = Counter(row.get("status", "") for row in rows)
    done = len(rows)
    last = rows[-1] if rows else {}
    zeros = zero_engines()
    status = {
        "time": datetime.now().isoformat(timespec="seconds"),
        "done": done,
        "total": total,
        "percent": round(done / total * 100, 2) if total else 0,
        "status_counts": dict(counts),
        "last_combo": last.get("combo_id", ""),
        "last_status": last.get("status", ""),
        "last_elapsed_seconds": last.get("elapsed_seconds", ""),
        "zero_engine_count": len(zeros),
        "zero_engines": zeros,
        "console_tail": console_tail(),
    }
    return status


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--interval", type=int, default=60)
    parser.add_argument("--total", type=int, default=136)
    parser.add_argument("--max-hours", type=float, default=18.0)
    args = parser.parse_args()
    started = time.time()
    MONITOR_LOG.parent.mkdir(parents=True, exist_ok=True)
    with MONITOR_LOG.open("a", encoding="utf-8", newline="\n") as log:
        log.write(f"\n=== monitor started {datetime.now().isoformat(timespec='seconds')} ===\n")
        while True:
            status = snapshot(args.total)
            STATUS_JSON.write_text(json.dumps(status, ensure_ascii=False, indent=2), encoding="utf-8")
            log.write(json.dumps(status, ensure_ascii=False) + "\n")
            log.flush()
            if status["done"] >= args.total:
                log.write("=== monitor complete: reached total ===\n")
                break
            if time.time() - started > args.max_hours * 3600:
                log.write("=== monitor stopped: max-hours reached ===\n")
                break
            time.sleep(args.interval)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
