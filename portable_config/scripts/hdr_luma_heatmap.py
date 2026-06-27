#!/usr/bin/env python3
"""Generate relative luma heatmaps from an mpv raw screenshot.

The helper intentionally uses only the Python standard library so it works with
the bundled mpv-lazy Python runtime. It accepts the PPM file written by
hdr_luma_heatmap.lua and writes two PNGs: a continuous false-color heatmap and a
peak mask focused on the brightest areas in the current frame.
"""

from __future__ import annotations

import argparse
import binascii
import pathlib
import struct
import zlib


PNG_SIG = b"\x89PNG\r\n\x1a\n"


def parse_ppm(path: pathlib.Path):
    data = path.read_bytes()
    if not data.startswith(b"P6"):
        raise ValueError("input is not a binary PPM file")
    pos = 2

    def token() -> bytes:
        nonlocal pos
        while pos < len(data) and data[pos] in b" \t\r\n":
            pos += 1
        if pos < len(data) and data[pos] == ord("#"):
            while pos < len(data) and data[pos] not in b"\r\n":
                pos += 1
            return token()
        start = pos
        while pos < len(data) and data[pos] not in b" \t\r\n":
            pos += 1
        return data[start:pos]

    width = int(token())
    height = int(token())
    maxval = int(token())
    if maxval != 255:
        raise ValueError("only 8-bit PPM is supported")
    while pos < len(data) and data[pos] in b" \t\r\n":
        pos += 1
    rgb = data[pos:]
    expected = width * height * 3
    if len(rgb) < expected:
        raise ValueError("truncated PPM payload")
    return width, height, rgb[:expected]


def heat_color(t: float) -> tuple[int, int, int]:
    stops = [
        (0.00, (0, 0, 0)),
        (0.20, (0, 0, 180)),
        (0.40, (0, 220, 255)),
        (0.60, (0, 220, 40)),
        (0.78, (255, 230, 0)),
        (0.92, (255, 80, 0)),
        (1.00, (255, 255, 255)),
    ]
    for (a_pos, a), (b_pos, b) in zip(stops, stops[1:]):
        if t <= b_pos:
            f = 0 if b_pos == a_pos else (t - a_pos) / (b_pos - a_pos)
            return tuple(round(a[i] + (b[i] - a[i]) * f) for i in range(3))
    return stops[-1][1]


def write_png(path: pathlib.Path, width: int, height: int, rgb: bytes) -> None:
    def chunk(ctype: bytes, payload: bytes) -> bytes:
        return (
            struct.pack(">I", len(payload))
            + ctype
            + payload
            + struct.pack(">I", binascii.crc32(ctype + payload) & 0xFFFFFFFF)
        )

    rows = bytearray()
    stride = width * 3
    for y in range(height):
        rows.append(0)
        rows.extend(rgb[y * stride : (y + 1) * stride])
    payload = PNG_SIG
    payload += chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
    payload += chunk(b"IDAT", zlib.compress(bytes(rows), 6))
    payload += chunk(b"IEND", b"")
    path.write_bytes(payload)


def pq_eotf(x: float | None) -> float | None:
    if x is None:
        return None
    m1 = 2610.0 / 4096 * 1.0 / 4
    m2 = 2523.0 / 4096 * 128
    c1 = 3424.0 / 4096
    c2 = 2413.0 / 4096 * 32
    c3 = 2392.0 / 4096 * 32
    v = x ** (1.0 / m2)
    v = max(v - c1, 0.0) / (c2 - c3 * v)
    return (v ** (1.0 / m1)) * 10000.0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("input", type=pathlib.Path)
    parser.add_argument("output", type=pathlib.Path)
    parser.add_argument("--clip-low", type=float, default=0.0)
    parser.add_argument("--clip-high", type=float, default=100.0)
    parser.add_argument("--report", type=pathlib.Path)
    parser.add_argument("--mpv-max-pq-y", type=float)
    parser.add_argument("--mpv-avg-pq-y", type=float)
    args = parser.parse_args()

    width, height, pixels = parse_ppm(args.input)

    lumas = []
    for i in range(0, len(pixels), 3):
        r, g, b = pixels[i], pixels[i + 1], pixels[i + 2]
        lumas.append(0.2126 * r + 0.7152 * g + 0.0722 * b)

    sorted_luma = sorted(lumas)
    lo = sorted_luma[int((len(sorted_luma) - 1) * max(args.clip_low, 0) / 100)]
    hi = sorted_luma[int((len(sorted_luma) - 1) * min(args.clip_high, 100) / 100)]
    if hi <= lo:
        hi = max(sorted_luma[-1], lo + 1)

    out = bytearray(width * height * 3)
    for idx, lum in enumerate(lumas):
        t = min(max((lum - lo) / (hi - lo), 0.0), 1.0) ** 0.75
        r, g, b = heat_color(t)
        j = idx * 3
        out[j : j + 3] = bytes((r, g, b))
    write_png(args.output, width, height, bytes(out))

    peak = bytearray(width * height * 3)
    max_luma = max(sorted_luma[-1], 1.0)
    for idx, lum in enumerate(lumas):
        ratio = lum / max_luma
        if ratio >= 0.98:
            color = (255, 255, 255)
        elif ratio >= 0.90:
            color = (255, 0, 0)
        elif ratio >= 0.75:
            color = (255, 128, 0)
        elif ratio >= 0.60:
            color = (255, 230, 0)
        else:
            color = (0, 0, 0)
        j = idx * 3
        peak[j : j + 3] = bytes(color)
    peak_path = args.output.with_name(args.output.stem + "-peakmask" + args.output.suffix)
    write_png(peak_path, width, height, bytes(peak))

    top_01 = sorted_luma[int((len(sorted_luma) - 1) * 0.999)]
    top_1 = sorted_luma[int((len(sorted_luma) - 1) * 0.99)]
    print(f"Wrote: {args.output}")
    print(f"Wrote: {peak_path}")
    print("Peak mask: white=>=98% of this frame max, red=>=90%, orange=>=75%, yellow=>=60%")
    print(f"Luma p99={top_1:.1f}, p99.9={top_01:.1f}, max={sorted_luma[-1]:.1f} (8-bit relative)")

    if args.report:
        avg_luma = sum(lumas) / len(lumas)
        p50 = sorted_luma[int((len(sorted_luma) - 1) * 0.50)]
        p90 = sorted_luma[int((len(sorted_luma) - 1) * 0.90)]
        p99 = sorted_luma[int((len(sorted_luma) - 1) * 0.99)]
        lines = [
            "HDR luma heatmap report",
            f"input={args.input}",
            f"output={args.output}",
            f"peakmask={peak_path}",
            f"resolution={width}x{height}",
            "",
            "Raw screenshot luma (8-bit relative, comparable only if the screenshot pipeline is identical):",
            f"avg={avg_luma:.2f}",
            f"p50={p50:.2f}",
            f"p90={p90:.2f}",
            f"p99={p99:.2f}",
            f"p99.9={top_01:.2f}",
            f"max={sorted_luma[-1]:.2f}",
            "",
        ]
        if args.mpv_max_pq_y is not None or args.mpv_avg_pq_y is not None:
            lines += [
                "mpv video-out-params PQ(Y) (current rendered frame/status):",
                f"max-pq-y={args.mpv_max_pq_y if args.mpv_max_pq_y is not None else 'n/a'}",
                f"max-nits={pq_eotf(args.mpv_max_pq_y) if args.mpv_max_pq_y is not None else 'n/a'}",
                f"avg-pq-y={args.mpv_avg_pq_y if args.mpv_avg_pq_y is not None else 'n/a'}",
                f"avg-nits={pq_eotf(args.mpv_avg_pq_y) if args.mpv_avg_pq_y is not None else 'n/a'}",
            ]
        else:
            lines.append("mpv video-out-params PQ(Y): unavailable in this screenshot state")
        args.report.write_text("\n".join(str(x) for x in lines) + "\n", encoding="utf-8")
        print(f"Wrote: {args.report}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
