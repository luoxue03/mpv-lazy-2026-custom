#!/usr/bin/env python3
"""Launch mpv from a release directory and scan its log for fatal issues."""

from __future__ import annotations

import argparse
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path


DEFAULT_ROOT = Path(r"F:\mpv_2026\_release_test")
DEFAULT_VIDEO = Path(r"I:\Torren_DownloadFile\剑来\第二季\S02E25_4K.mp4")


FATAL_PATTERNS = [
    "failed to initialize vsscript",
    "creating filter 'vapoursynth' failed",
    "creating filter \"vapoursynth\" failed",
    "failed to create filter",
    "error parsing option",
    "script failed",
    "cannot load script",
    "lua error",
    "python exception",
    "traceback (most recent call last)",
    "no such file or directory",
]

WARNING_PATTERNS = [
    "unknown key",
    "deprecated",
    "audio device underrun",
    "frame requested during init",
    "vf-remove",
]


@dataclass(frozen=True)
class SmokeResult:
    return_code: int | None
    fatal_hits: list[str]
    warning_hits: list[str]
    log_path: Path


def configure_stdout() -> None:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="backslashreplace")
        sys.stderr.reconfigure(encoding="utf-8", errors="backslashreplace")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Open mpv for a short playback smoke test and scan mpv.log.")
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT, help="mpv release root containing mpv.exe")
    parser.add_argument("--video", type=Path, default=DEFAULT_VIDEO, help="local video file or URL to play")
    parser.add_argument("--seconds", type=int, default=20, help="seconds to keep mpv open before terminating")
    parser.add_argument("--start", default="00:00:10", help="mpv --start value")
    parser.add_argument("--vf", default=None, help="optional vf value, e.g. vapoursynth=~~/vs/MEMC_RIFE_NV_4.15_lite.vpy")
    parser.add_argument("--profile", action="append", default=[], help="optional mpv profile; can be repeated")
    parser.add_argument("--log", type=Path, default=None, help="log path; defaults to <root>/smoke-test-mpv.log")
    parser.add_argument("--no-window", action="store_true", help="run with --vo=null --ao=null instead of opening a window")
    parser.add_argument("--keep-open", action="store_true", help="do not terminate mpv after --seconds; useful for manual inspection")
    parser.add_argument("--ignore-warning", action="append", default=[], help="warning substring to ignore; can be repeated")
    parser.add_argument("--extra-arg", action="append", default=[], help="extra mpv argument; can be repeated")
    return parser.parse_args()


def validate_inputs(root: Path, video: Path) -> Path:
    mpv = root / "mpv.exe"
    if not root.exists():
        raise FileNotFoundError(f"mpv root does not exist: {root}")
    if not mpv.exists():
        raise FileNotFoundError(f"mpv.exe not found: {mpv}")
    if not (str(video).startswith("http://") or str(video).startswith("https://")) and not video.exists():
        raise FileNotFoundError(f"video does not exist: {video}")
    return mpv


def build_command(args: argparse.Namespace, mpv: Path, log_path: Path) -> list[str]:
    command = [
        str(mpv),
        str(args.video),
        "--force-window=yes",
        "--idle=no",
        f"--start={args.start}",
        f"--log-file={log_path}",
        "--msg-level=all=v",
    ]
    for profile in args.profile:
        command.append(f"--profile={profile}")
    if args.vf:
        command.append(f"--vf={args.vf}")
    if args.no_window:
        command.extend(["--vo=null", "--ao=null"])
    command.extend(args.extra_arg)
    return command


def terminate_process(process: subprocess.Popen[str], timeout: int = 5) -> int | None:
    if process.poll() is not None:
        return process.returncode
    process.terminate()
    try:
        process.wait(timeout=timeout)
    except subprocess.TimeoutExpired:
        process.kill()
        process.wait(timeout=timeout)
    return process.returncode


def collect_hits(log_path: Path, ignore_warnings: list[str]) -> tuple[list[str], list[str]]:
    if not log_path.exists():
        return ["log file was not created"], []
    text = log_path.read_text(encoding="utf-8", errors="ignore")
    lines = text.splitlines()
    fatal_hits: list[str] = []
    warning_hits: list[str] = []
    for line in lines:
        lower = line.lower()
        if any(pattern in lower for pattern in FATAL_PATTERNS):
            fatal_hits.append(line)
        if any(pattern in lower for pattern in WARNING_PATTERNS) and not any(ignore.lower() in lower for ignore in ignore_warnings):
            warning_hits.append(line)
    return fatal_hits, warning_hits


def run_smoke(args: argparse.Namespace) -> SmokeResult:
    root = args.root.resolve()
    video = args.video if str(args.video).startswith(("http://", "https://")) else args.video.resolve()
    mpv = validate_inputs(root, Path(video) if not isinstance(video, Path) else video)
    log_path = (args.log or (root / "smoke-test-mpv.log")).resolve()
    if log_path.exists():
        log_path.unlink()
    command = build_command(args, mpv, log_path)
    print("$ " + " ".join(command))
    process = subprocess.Popen(command, cwd=str(root), text=True)
    if args.keep_open:
        print(f"mpv started with pid={process.pid}. Log: {log_path}")
        return SmokeResult(process.poll(), [], [], log_path)
    time.sleep(max(args.seconds, 1))
    return_code = terminate_process(process)
    fatal_hits, warning_hits = collect_hits(log_path, args.ignore_warning)
    return SmokeResult(return_code, fatal_hits, warning_hits, log_path)


def print_result(result: SmokeResult) -> int:
    print(f"return_code={result.return_code}")
    print(f"log={result.log_path}")
    print(f"fatal_hits={len(result.fatal_hits)}")
    for line in result.fatal_hits[:50]:
        print("FATAL\t" + line)
    print(f"warning_hits={len(result.warning_hits)}")
    for line in result.warning_hits[:50]:
        print("WARN\t" + line)
    if result.fatal_hits:
        return 2
    return 0


def main() -> int:
    configure_stdout()
    args = parse_args()
    result = run_smoke(args)
    return print_result(result)


if __name__ == "__main__":
    raise SystemExit(main())
