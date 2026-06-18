#!/usr/bin/env python3
"""Build split GitHub Release packages for mpv-lazy-2026-custom.

The repository only stores configuration/source-like files.  A complete
release must be staged from a verified runnable mpv-lazy directory, then
overlaid with this repository's latest tracked config files.
"""

from __future__ import annotations

import argparse
import fnmatch
import hashlib
import os
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path


VERSION = "v2026.06"
PACKAGE_ROOT_NAME = "mpv-lazy-2026-custom"
REPO_SLUG = "luoxue03/mpv-lazy-2026-custom"


AI_TOP_DIRS = {
    "Lib",
    "Scripts",
    "vsgenstubs4",
    "vs-plugins",
    "vs-coreplugins",
    "vs-scripts",
}

AI_TOP_FILES = {
    "_asyncio.pyd",
    "_bz2.pyd",
    "_ctypes.pyd",
    "_decimal.pyd",
    "_elementtree.pyd",
    "_hashlib.pyd",
    "_lzma.pyd",
    "_multiprocessing.pyd",
    "_overlapped.pyd",
    "_queue.pyd",
    "_remote_debugging.pyd",
    "_socket.pyd",
    "_sqlite3.pyd",
    "_ssl.pyd",
    "_uuid.pyd",
    "_wmi.pyd",
    "_zoneinfo.pyd",
    "_zstd.pyd",
    "concrt140.dll",
    "get-pip.py",
    "libcrypto-3.dll",
    "libffi-8.dll",
    "libssl-3.dll",
    "msvcp140.dll",
    "msvcp140_1.dll",
    "msvcp140_2.dll",
    "msvcp140_atomic_wait.dll",
    "msvcp140_codecvt_ids.dll",
    "pfm-192-vapoursynth-win.exe",
    "pyexpat.pyd",
    "python.cat",
    "python.exe",
    "python3.dll",
    "python314._pth",
    "python314.dll",
    "python314.zip",
    "pythonw.exe",
    "select.pyd",
    "sqlite3.dll",
    "unicodedata.pyd",
    "vccorlib140.dll",
    "vcruntime140.dll",
    "vcruntime140_1.dll",
    "vcruntime140_threads.dll",
    "VSPipe.exe",
    "vsrepo.py",
    "VSScript.dll",
    "VSScriptPython38.dll",
    "VSVFW.dll",
    "winsound.pyd",
    "vsgenstubs.py",
}

BASE_DUPLICATE_FILES = {
    "concrt140.dll",
    "libcrypto-3.dll",
    "libffi-8.dll",
    "libssl-3.dll",
    "msvcp140.dll",
    "msvcp140_1.dll",
    "msvcp140_2.dll",
    "msvcp140_atomic_wait.dll",
    "msvcp140_codecvt_ids.dll",
    "sqlite3.dll",
    "vccorlib140.dll",
    "vcruntime140.dll",
    "vcruntime140_1.dll",
    "vcruntime140_threads.dll",
}

AI_PREFIXES = {
    "portable_config/faster-whisper-win",
}

CONFIG_EXACT_FILES = {
    "portable.vs",
    "external_player.js",
    "umpv.conf",
    "truehdrtweaks.ini",
    "portable_config/fonts.conf",
    "portable_config/input_uosc.conf",
    "portable_config/input_uosc.conf_2025",
    "portable_config/manager.json",
    "portable_config/menu.conf",
    "portable_config/mpv.conf",
    "portable_config/profiles.conf",
    "portable_config/script-opts.conf",
}

CONFIG_PREFIXES = {
    "portable_config/script-opts",
    "portable_config/scripts",
    "portable_config/vs",
}

DOCS_EXACT_FILES = {
    "LICENSE.MD",
    "LICENSE.txt",
    "README.MD",
    "REPO_STRUCTURE.md",
    "mpv_manual.pdf",
    "使用说明.md",
}

DOCS_PREFIXES = {
    "docs",
}

OVERLAY_SKIP_TOP = {
    "Lib",
    "Scripts",
    "vs-plugins",
    "vs-coreplugins",
    "vs-scripts",
    "vsgenstubs4",
}

OVERLAY_EXCLUDE_DIRS = {
    ".git",
    ".qoder",
    "_runtime_backups",
    "node_modules",
}

OVERLAY_EXCLUDE_REL_DIRS = {
    "portable_config/_cache",
    "tools/telegram-web-mpv-bridge/.venv",
    "tools/telegram-web-mpv-bridge/__pycache__",
}

OVERLAY_EXCLUDE_GLOBS = {
    "*.lnk",
    "*.log",
    "config.json",
    "cookies.backup*.txt",
    "cookies.txt",
    "portable_config/recent.json",
    "portable_config/saved-props.json",
    "portable_config/script-opts/rife_runtime.json",
    "portable_config/script-opts/trakt_scrobble.conf",
    "portable_config/trakt_config.json",
    "portable_config/trakt_history.json",
    "settings.json",
    "viewed.json",
}

STAGING_REMOVE_RELS = {
    ".qoder",
    "_runtime_backups",
    "config.json",
    "cookies.backup-1.txt",
    "cookies.backup-before-export.txt",
    "cookies.txt",
    "external-player-pornhub.log",
    "external-player-ytdlp.log",
    "missav-config-debug.log",
    "missav-mpv-debug.log",
    "missav-url-no-config.log",
    "mpv_2026.lnk",
    "portable_config/_cache",
    "portable_config/recent.json",
    "portable_config/saved-props.json",
    "portable_config/script-opts/rife_runtime.json",
    "portable_config/script-opts/trakt_scrobble.conf",
    "portable_config/trakt_config.json",
    "portable_config/trakt_history.json",
    "quality-menu-syntax-check.log",
    "settings.json",
    "tools/telegram-web-mpv-bridge/.venv",
    "tools/telegram-web-mpv-bridge/__pycache__",
    "truehdrtweaks.log",
    "viewed.json",
}

FORBIDDEN_RELS = {
    ".qoder",
    "_runtime_backups",
    "config.json",
    "cookies.backup-1.txt",
    "cookies.backup-before-export.txt",
    "cookies.txt",
    "portable_config/_cache",
    "portable_config/recent.json",
    "portable_config/saved-props.json",
    "portable_config/script-opts/rife_runtime.json",
    "portable_config/script-opts/trakt_scrobble.conf",
    "portable_config/trakt_config.json",
    "portable_config/trakt_history.json",
    "settings.json",
    "tools/telegram-web-mpv-bridge/.venv",
    "viewed.json",
}


@dataclass(frozen=True)
class Paths:
    repo: Path
    source: Path
    work: Path
    artifacts: Path
    staging: Path
    package_inputs: Path
    verify: Path
    seven_zip: Path


def configure_stdout() -> None:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="backslashreplace")
        sys.stderr.reconfigure(encoding="utf-8", errors="backslashreplace")


def run(cmd: list[str], *, cwd: Path | None = None, timeout: int | None = None) -> subprocess.CompletedProcess[str]:
    print("$ " + " ".join(cmd))
    completed = subprocess.run(
        cmd,
        cwd=str(cwd) if cwd else None,
        text=True,
        capture_output=True,
        errors="replace",
        timeout=timeout,
    )
    if completed.stdout:
        print(completed.stdout[-4000:])
    if completed.stderr:
        print(completed.stderr[-4000:], file=sys.stderr)
    if completed.returncode != 0:
        raise RuntimeError(f"Command failed with {completed.returncode}: {' '.join(cmd)}")
    return completed


def run_robocopy(source: Path, target: Path) -> None:
    cmd = [
        "robocopy",
        str(source),
        str(target),
        "/E",
        "/COPY:DAT",
        "/DCOPY:DAT",
        "/R:1",
        "/W:1",
        "/NFL",
        "/NDL",
        "/NP",
        "/NJH",
        "/NJS",
    ]
    print("$ " + " ".join(cmd))
    completed = subprocess.run(cmd, text=True, capture_output=True, errors="replace", timeout=3600)
    print(f"robocopy_rc={completed.returncode}")
    if completed.returncode >= 8:
        print(completed.stdout[-4000:])
        print(completed.stderr[-4000:], file=sys.stderr)
        raise RuntimeError("robocopy failed")


def safe_rmtree(path: Path, allowed_parent: Path) -> None:
    if not path.exists():
        return
    resolved = path.resolve()
    allowed = allowed_parent.resolve()
    if resolved == allowed or allowed not in resolved.parents:
        raise RuntimeError(f"Refusing to remove unsafe path: {resolved}")
    shutil.rmtree(path)


def tree_size(path: Path) -> tuple[int, int]:
    if not path.exists():
        return 0, 0
    if path.is_file():
        return path.stat().st_size, 1
    total = 0
    files = 0
    for file in path.rglob("*"):
        if file.is_file():
            files += 1
            total += file.stat().st_size
    return total, files


def has_prefix(rel: str, prefixes: set[str]) -> bool:
    return any(rel == prefix or rel.startswith(prefix + "/") for prefix in prefixes)


def is_ai(rel: str) -> bool:
    top = rel.split("/")[0]
    return top in AI_TOP_DIRS or rel in AI_TOP_FILES or has_prefix(rel, AI_PREFIXES)


def is_config(rel: str) -> bool:
    return rel in CONFIG_EXACT_FILES or has_prefix(rel, CONFIG_PREFIXES)


def is_docs(rel: str) -> bool:
    return rel in DOCS_EXACT_FILES or has_prefix(rel, DOCS_PREFIXES)


def should_overlay(rel: str, filename: str) -> bool:
    top = rel.split("/")[0]
    if top in OVERLAY_SKIP_TOP:
        return False
    if has_prefix(rel, OVERLAY_EXCLUDE_REL_DIRS):
        return False
    return not any(fnmatch.fnmatch(rel, pattern) or fnmatch.fnmatch(filename, pattern) for pattern in OVERLAY_EXCLUDE_GLOBS)


def find_7z(source: Path, repo: Path, explicit: Path | None) -> Path:
    candidates = []
    if explicit:
        candidates.append(explicit)
    candidates.extend([source / "7z.exe", repo / "7z.exe", repo.parent / "mpv-lazy" / "7z.exe"])
    for candidate in candidates:
        if candidate.exists():
            return candidate
    raise FileNotFoundError("7z.exe not found; pass --seven-zip")


def build_paths(args: argparse.Namespace) -> Paths:
    repo = args.repo.resolve()
    source = args.source.resolve()
    work = args.work.resolve()
    artifacts = args.artifacts.resolve()
    return Paths(
        repo=repo,
        source=source,
        work=work,
        artifacts=artifacts,
        staging=work / PACKAGE_ROOT_NAME,
        package_inputs=work / "packages",
        verify=work / "verify",
        seven_zip=find_7z(source, repo, args.seven_zip.resolve() if args.seven_zip else None),
    )


def clean_work(paths: Paths) -> None:
    for path in [paths.work, paths.artifacts]:
        if path.exists():
            safe_rmtree(path, path.parent)
    paths.work.mkdir(parents=True, exist_ok=True)
    paths.artifacts.mkdir(parents=True, exist_ok=True)


def overlay_repo(paths: Paths) -> int:
    copied = 0
    for dirpath, dirnames, filenames in os.walk(paths.repo):
        current = Path(dirpath)
        rel_dir = current.relative_to(paths.repo).as_posix() if current != paths.repo else ""
        kept_dirs = []
        for dirname in dirnames:
            rel = f"{rel_dir}/{dirname}".strip("/")
            if dirname in OVERLAY_EXCLUDE_DIRS or dirname in OVERLAY_SKIP_TOP or rel in OVERLAY_EXCLUDE_REL_DIRS:
                continue
            kept_dirs.append(dirname)
        dirnames[:] = kept_dirs
        for filename in filenames:
            source = current / filename
            rel = source.relative_to(paths.repo).as_posix()
            if not should_overlay(rel, filename):
                continue
            target = paths.staging / rel
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)
            copied += 1
    return copied


def clean_staging(paths: Paths) -> list[str]:
    removed: list[str] = []
    for rel in sorted(STAGING_REMOVE_RELS):
        path = paths.staging / rel
        if not path.exists():
            continue
        if path.is_dir():
            shutil.rmtree(path)
        else:
            path.unlink()
        removed.append(rel)
    for path in list(paths.staging.rglob("*.log")):
        path.unlink()
        removed.append(path.relative_to(paths.staging).as_posix())
    for path in list(paths.staging.rglob("__pycache__")):
        if path.is_dir():
            shutil.rmtree(path)
            removed.append(path.relative_to(paths.staging).as_posix())
    (paths.staging / "portable.vs").touch(exist_ok=True)
    return removed


def make_staging(paths: Paths) -> None:
    print(f"Staging from: {paths.source}")
    run_robocopy(paths.source, paths.staging)
    copied = overlay_repo(paths)
    removed = clean_staging(paths)
    print(f"Overlay files: {copied}")
    print(f"Removed staging residues: {len(removed)}")


def copy_to_package(paths: Paths, package: str, source: Path, rel: str) -> None:
    target = paths.package_inputs / package / PACKAGE_ROOT_NAME / rel
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)


def build_package_inputs(paths: Paths) -> None:
    safe_rmtree(paths.package_inputs, paths.work)
    paths.package_inputs.mkdir(parents=True, exist_ok=True)
    counts = {"base": 0, "ai": 0, "config": 0, "docs": 0}
    sizes = {"base": 0, "ai": 0, "config": 0, "docs": 0}
    for source in paths.staging.rglob("*"):
        if not source.is_file():
            continue
        rel = source.relative_to(paths.staging).as_posix()
        size = source.stat().st_size
        if is_ai(rel):
            copy_to_package(paths, "ai", source, rel)
            counts["ai"] += 1
            sizes["ai"] += size
            if rel in BASE_DUPLICATE_FILES:
                copy_to_package(paths, "base", source, rel)
                counts["base"] += 1
                sizes["base"] += size
        else:
            copy_to_package(paths, "base", source, rel)
            counts["base"] += 1
            sizes["base"] += size
        if is_config(rel):
            copy_to_package(paths, "config", source, rel)
            counts["config"] += 1
            sizes["config"] += size
        if is_docs(rel):
            copy_to_package(paths, "docs", source, rel)
            counts["docs"] += 1
            sizes["docs"] += size

    for package in ["base", "config"]:
        (paths.package_inputs / package / PACKAGE_ROOT_NAME / "portable.vs").touch(exist_ok=True)

    readmes = {
        "base": "基础可播放包。可直接运行 mpv.exe 播放普通视频；AI 补帧/超分需继续解压 AI 包和 Config 包。\n",
        "ai": "AI/VS 大依赖包。先解压 Base，再解压本包到同一根目录覆盖。\n",
        "config": "配置更新包。包含菜单、脚本、快捷键、滤镜 vpy；后续小更新通常只需覆盖本包。\n",
        "docs": "文档包。包含迁移记录、测试报告、RIFE benchmark HTML 和使用说明。\n",
    }
    for package, text in readmes.items():
        readme = paths.package_inputs / package / PACKAGE_ROOT_NAME / f"包说明-{package}.txt"
        readme.parent.mkdir(parents=True, exist_ok=True)
        readme.write_text(text, encoding="utf-8", newline="\n")
        counts[package] += 1
        sizes[package] += readme.stat().st_size

    for package in ["base", "ai", "config", "docs"]:
        print(f"{package}: files={counts[package]}, size={sizes[package] / 1024 ** 2:.2f}MB")


def archive_packages(paths: Paths, version: str, volume: str, compression: int) -> None:
    package_specs = [
        ("base", f"mpv-lazy-2026-custom-base-{version}.zip", []),
        ("ai", f"mpv-lazy-2026-custom-ai-{version}.zip", [f"-v{volume}"]),
        ("config", f"mpv-lazy-2026-custom-config-{version}.zip", []),
        ("docs", f"mpv-lazy-2026-custom-docs-{version}.zip", []),
    ]
    for package, filename, extra_args in package_specs:
        source = paths.package_inputs / package / PACKAGE_ROOT_NAME
        target = paths.artifacts / filename
        run(
            [str(paths.seven_zip), "a", "-tzip", f"-mx={compression}", *extra_args, str(target), str(source)],
            cwd=paths.artifacts,
            timeout=7200,
        )


def write_sha256(paths: Paths, version: str) -> None:
    sha_path = paths.artifacts / f"SHA256SUMS-{version}.txt"
    with sha_path.open("w", encoding="utf-8", newline="\n") as handle:
        for path in sorted(paths.artifacts.iterdir()):
            if not path.is_file() or path.name == sha_path.name or path.name.startswith("RELEASE_NOTES-"):
                continue
            digest = hashlib.sha256()
            with path.open("rb") as stream:
                for chunk in iter(lambda: stream.read(1024 * 1024), b""):
                    digest.update(chunk)
            handle.write(f"{digest.hexdigest()}  {path.name}\n")


def write_release_notes(paths: Paths, version: str) -> Path:
    notes = paths.artifacts / f"RELEASE_NOTES-{version}.md"
    body = f"""基于 [hooke007/mpv_PlayKit](https://github.com/hooke007/mpv_PlayKit) 的 mpv-lazy 2026 自定义整合包。当前版本采用分类包发布：基础播放、AI/VS 大依赖、配置更新包分离。

## 下载顺序

1. 下载 `mpv-lazy-2026-custom-base-{version}.zip`。
2. 下载 `mpv-lazy-2026-custom-ai-{version}.zip.001` 起始的所有 AI 分卷，放在同一目录。
3. 下载 `mpv-lazy-2026-custom-config-{version}.zip`。
4. 先解压 base，再解压 AI 的 `.001` 分卷到同一目录覆盖，最后解压 config 覆盖。
5. 运行 `mpv-lazy-2026-custom\\mpv.exe`。

## 包说明

| 文件 | 作用 | 是否必须 |
| --- | --- | --- |
| `mpv-lazy-2026-custom-base-{version}.zip` | 基础可播放包，包含 mpv、基础配置、脚本、着色器、文档、工具 | 必须 |
| `mpv-lazy-2026-custom-ai-{version}.zip.*` | AI/VS 大包，包含 VapourSynth、TensorRT/CUDA、RIFE/UAI/RealESRGAN/AnimeJaNai/faster-whisper 等依赖 | 需要补帧/超分/AI字幕时必须 |
| `mpv-lazy-2026-custom-config-{version}.zip` | 菜单、脚本、快捷键、滤镜 vpy、配置文件更新包 | 完整安装推荐覆盖 |
| `mpv-lazy-2026-custom-docs-{version}.zip` | 迁移记录、测试报告、RIFE benchmark HTML、说明文档 | 可选 |
| `SHA256SUMS-{version}.txt` | 文件校验值 | 可选 |

## 重要说明

- 不要把新版本直接覆盖到旧 mpv-lazy 目录；建议解压到新目录。
- 路径建议不要包含中文、空格和特殊符号。
- 首次使用 RIFE/AI 超分时可能会生成 TensorRT engine，耗时较长，属于正常现象。
- 本包保留根目录 `portable.vs`，避免 VapourSynth 初始化失败。

## 需要自行配置的个人内容

- AI 字幕 API key（可选）：`portable_config\\script-opts.conf` 里的 `sub_fastwhisper-api_key`。
- `cookies.txt`（可选）：需要登录态网站视频时自行导出。
- Trakt 授权（可选）：首次使用时重新授权。
- Telegram Bridge（可选）：`tools\\telegram-web-mpv-bridge` 按说明安装依赖。
"""
    notes.write_text(body, encoding="utf-8", newline="\n")
    return notes


def load_forbidden_texts(paths: Paths, args: argparse.Namespace) -> list[str]:
    texts: list[str] = []
    texts.extend(text for text in args.forbidden_text if text)
    env_text = os.environ.get("MPV_RELEASE_FORBIDDEN_TEXT", "")
    if env_text:
        texts.extend(text for text in env_text.splitlines() if text)
    text_files: list[Path] = []
    default_local_file = paths.repo / "tools" / "release" / "forbidden_texts.local.txt"
    if default_local_file.exists():
        text_files.append(default_local_file)
    if args.forbidden_text_file:
        text_files.append(args.forbidden_text_file)
    for text_file in text_files:
        for line in text_file.read_text(encoding="utf-8", errors="ignore").splitlines():
            line = line.strip()
            if line and not line.startswith("#"):
                texts.append(line)
    return texts


def verify_extracted(paths: Paths, version: str, forbidden_texts: list[str]) -> None:
    safe_rmtree(paths.verify, paths.work)
    paths.verify.mkdir(parents=True, exist_ok=True)
    archives = [
        paths.artifacts / f"mpv-lazy-2026-custom-base-{version}.zip",
        paths.artifacts / f"mpv-lazy-2026-custom-ai-{version}.zip.001",
        paths.artifacts / f"mpv-lazy-2026-custom-config-{version}.zip",
        paths.artifacts / f"mpv-lazy-2026-custom-docs-{version}.zip",
    ]
    for archive in archives:
        run([str(paths.seven_zip), "x", "-y", str(archive), f"-o{paths.verify}"], timeout=7200)

    root = paths.verify / PACKAGE_ROOT_NAME
    required = {
        "installer",
        "installer/mpv-register.bat",
        "installer/mpv-unregister.bat",
        "installer/umpv-install.bat",
        "Lib",
        "Scripts",
        "VSPipe.exe",
        "mpv.exe",
        "portable.vs",
        "portable_config/mpv.conf",
        "portable_config/scripts/rife_runtime_menu.lua",
        "portable_config/shaders",
        "portable_config/vs",
        "vs-coreplugins",
        "vs-plugins",
    }
    missing = [rel for rel in sorted(required) if not (root / rel).exists()]
    if missing:
        raise RuntimeError(f"Missing required files after extraction: {missing}")

    forbidden = [rel for rel in sorted(FORBIDDEN_RELS) if (root / rel).exists()]
    if forbidden:
        raise RuntimeError(f"Forbidden runtime/sensitive files after extraction: {forbidden}")

    key_hits: list[str] = []
    for file in root.rglob("*"):
        if not file.is_file() or file.stat().st_size > 5 * 1024 * 1024:
            continue
        if file.suffix.lower() not in {".conf", ".ini", ".js", ".json", ".lua", ".md", ".py", ".txt", ".vpy"}:
            continue
        text = file.read_text(encoding="utf-8", errors="ignore")
        if any(forbidden in text for forbidden in forbidden_texts):
            key_hits.append(file.relative_to(root).as_posix())
    if key_hits:
        raise RuntimeError(f"Forbidden text found after extraction: {key_hits}")

    run([str(root / "VSPipe.exe"), "--version"], cwd=root, timeout=60)
    run(
        [str(root / "python.exe"), "-c", "import vapoursynth as vs; print(vs.__api_version__)"],
        cwd=root,
        timeout=60,
    )
    size, files = tree_size(root)
    print(f"Verified extraction: {size / 1024 ** 3:.2f}GB, files={files}")


def release_asset_files(paths: Paths, version: str) -> list[Path]:
    files = [paths.artifacts / f"mpv-lazy-2026-custom-base-{version}.zip"]
    files.extend(sorted(paths.artifacts.glob(f"mpv-lazy-2026-custom-ai-{version}.zip.*")))
    files.extend(
        [
            paths.artifacts / f"mpv-lazy-2026-custom-config-{version}.zip",
            paths.artifacts / f"mpv-lazy-2026-custom-docs-{version}.zip",
            paths.artifacts / f"SHA256SUMS-{version}.txt",
        ]
    )
    missing = [str(file) for file in files if not file.exists()]
    if missing:
        raise FileNotFoundError(f"Missing release assets: {missing}")
    return files


def release_exists(version: str, repo_slug: str) -> bool:
    completed = subprocess.run(
        ["gh", "release", "view", version, "--repo", repo_slug],
        text=True,
        capture_output=True,
        errors="replace",
        timeout=120,
    )
    if completed.returncode == 0:
        return True
    if "not found" in (completed.stderr + completed.stdout).lower():
        return False
    raise RuntimeError((completed.stderr or completed.stdout).strip())


def publish_release(paths: Paths, version: str, repo_slug: str, title: str, replace_existing_assets: bool) -> None:
    notes = paths.artifacts / f"RELEASE_NOTES-{version}.md"
    files = release_asset_files(paths, version)
    if not release_exists(version, repo_slug):
        run(
            [
                "gh",
                "release",
                "create",
                version,
                *[str(file) for file in files],
                "--repo",
                repo_slug,
                "--title",
                title,
                "--notes-file",
                str(notes),
            ],
            timeout=7200,
        )
        return

    if not replace_existing_assets:
        raise RuntimeError(
            f"Release {version} already exists. Use a new --version for normal publishing, "
            "or pass --replace-existing-assets to intentionally replace assets on the existing release."
        )

    run(["gh", "release", "edit", version, "--repo", repo_slug, "--notes-file", str(notes), "--title", title], timeout=300)
    assets = run(
        ["gh", "release", "view", version, "--repo", repo_slug, "--json", "assets", "--jq", ".assets[].name"],
        timeout=120,
    ).stdout.splitlines()
    for asset in assets:
        run(["gh", "release", "delete-asset", version, asset, "--repo", repo_slug, "--yes"], timeout=300)
    for file in files:
        run(["gh", "release", "upload", version, str(file), "--repo", repo_slug, "--clobber"], timeout=3600)


def print_summary(paths: Paths) -> None:
    print("Artifacts:")
    for path in sorted(paths.artifacts.iterdir()):
        if path.is_file():
            print(f"  {path.name}\t{path.stat().st_size / 1024 ** 2:.2f}MB")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build split mpv-lazy custom release packages.")
    parser.add_argument("--repo", type=Path, default=Path(__file__).resolve().parents[2], help="clean config repository path")
    parser.add_argument("--source", type=Path, default=Path(r"F:\mpv_2026\_release_test"), help="verified complete runnable source directory")
    parser.add_argument("--work", type=Path, default=Path(r"F:\mpv_2026\_release_package_work"), help="temporary work directory; deleted on each run unless --no-clean")
    parser.add_argument("--artifacts", type=Path, default=Path(r"F:\mpv_2026\_release_artifacts_split"), help="output artifacts directory; deleted on each run unless --no-clean")
    parser.add_argument("--seven-zip", type=Path, default=None, help="path to 7z.exe")
    parser.add_argument("--version", default=VERSION, help="release version/tag")
    parser.add_argument("--repo-slug", default=REPO_SLUG, help="GitHub repository slug for --upload")
    parser.add_argument("--release-title", default=None, help="GitHub Release title; defaults to the version tag")
    parser.add_argument("--volume", default="2000m", help="AI split volume size for 7-Zip, e.g. 2000m")
    parser.add_argument("--compression", type=int, default=5, choices=range(0, 10), help="zip compression level")
    parser.add_argument("--no-clean", action="store_true", help="do not delete work/artifacts before building")
    parser.add_argument("--skip-verify", action="store_true", help="skip extraction and VapourSynth verification")
    parser.add_argument("--upload", action="store_true", help="create a GitHub Release and upload assets")
    parser.add_argument(
        "--replace-existing-assets",
        action="store_true",
        help="if the target release already exists, delete and replace its assets; dangerous by design",
    )
    parser.add_argument(
        "--forbidden-text",
        action="append",
        default=[],
        help="literal text that must not appear in extracted release files; can be repeated",
    )
    parser.add_argument(
        "--forbidden-text-file",
        type=Path,
        default=None,
        help="UTF-8 text file containing forbidden literals, one per line; # comments allowed; local default is tools/release/forbidden_texts.local.txt",
    )
    return parser.parse_args()


def main() -> int:
    configure_stdout()
    args = parse_args()
    paths = build_paths(args)
    print(f"Repo: {paths.repo}")
    print(f"Source: {paths.source}")
    print(f"Work: {paths.work}")
    print(f"Artifacts: {paths.artifacts}")
    print(f"7z: {paths.seven_zip}")
    if not paths.repo.exists():
        raise FileNotFoundError(paths.repo)
    if not paths.source.exists():
        raise FileNotFoundError(paths.source)
    if not args.no_clean:
        clean_work(paths)
    make_staging(paths)
    build_package_inputs(paths)
    archive_packages(paths, args.version, args.volume, args.compression)
    write_release_notes(paths, args.version)
    write_sha256(paths, args.version)
    if not args.skip_verify:
        verify_extracted(paths, args.version, load_forbidden_texts(paths, args))
    print_summary(paths)
    if args.upload:
        title = args.release_title or f"mpv-lazy 2026 custom {args.version}"
        publish_release(paths, args.version, args.repo_slug, title, args.replace_existing_assets)
    else:
        print("Upload skipped. Pass --upload to create a new GitHub Release.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
