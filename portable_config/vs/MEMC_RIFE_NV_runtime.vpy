### RIFE NV runtime preset controlled by portable_config/scripts/rife_runtime_menu.lua
### Runtime state is stored outside this source file to keep Git diffs clean.

import json
import os

import vapoursynth as vs
from vapoursynth import core
import k7sfunc as k7f

core.num_threads = k7f.vs_t_dft
clip = video_in

MODEL_INFO = {
    46: {"label": "4.6", "supports_flow_scale": True},
    4151: {"label": "4.15 lite", "supports_flow_scale": False},
    422: {"label": "4.22", "supports_flow_scale": False},
    4221: {"label": "4.22 lite", "supports_flow_scale": False},
    4251: {"label": "4.25 lite", "supports_flow_scale": False},
    426: {"label": "4.26", "supports_flow_scale": False},
    4262: {"label": "4.26 heavy", "supports_flow_scale": False},
    47: {"label": "4.7", "supports_flow_scale": False},
    48: {"label": "4.8", "supports_flow_scale": False},
    49: {"label": "4.9", "supports_flow_scale": False},
}
DEFAULT_CONFIG = {
    "model": 46,
    "model_label": "4.6",
    "turbo": 2,
    "flow_scale": 1.0,
    "h_pre": 2160,
    "fps_num": 2,
    "fps_den": 1,
    "sc_mode": 1,
    "gpu": 0,
    "gpu_t": 2,
    "ws_size": 0,
    "lk_fmt": False,
}
VALID_TURBO = {0, 1, 2}
VALID_FLOW_SCALE = {0.25, 0.5, 1.0}


def portable_config_dir() -> str:
    return os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir))


def config_path() -> str:
    return os.path.join(portable_config_dir(), "script-opts", "rife_runtime.json")


def load_config() -> dict:
    path = config_path()
    try:
        with open(path, "r", encoding="utf-8-sig") as file:
            data = json.load(file)
    except FileNotFoundError:
        return dict(DEFAULT_CONFIG)
    except Exception as exc:
        raise vs.Error(f"RIFE runtime: failed to read {path}: {exc}")

    config = dict(DEFAULT_CONFIG)
    if isinstance(data, dict):
        config.update(data)
    return normalize_config(config)


def normalize_config(config: dict) -> dict:
    try:
        model = int(config["model"])
        turbo = int(config["turbo"])
        flow_scale = float(config["flow_scale"])
        h_pre = int(config.get("h_pre", DEFAULT_CONFIG["h_pre"]))
        fps_num = int(config.get("fps_num", DEFAULT_CONFIG["fps_num"]))
        fps_den = int(config.get("fps_den", DEFAULT_CONFIG["fps_den"]))
        sc_mode = int(config.get("sc_mode", DEFAULT_CONFIG["sc_mode"]))
        gpu = int(config.get("gpu", DEFAULT_CONFIG["gpu"]))
        gpu_t = int(config.get("gpu_t", DEFAULT_CONFIG["gpu_t"]))
        ws_size = int(config.get("ws_size", DEFAULT_CONFIG["ws_size"]))
        lk_fmt = bool(config.get("lk_fmt", DEFAULT_CONFIG["lk_fmt"]))
    except Exception as exc:
        raise vs.Error(f"RIFE runtime: invalid runtime config: {exc}")

    if model not in MODEL_INFO:
        raise vs.Error(f"RIFE runtime: unsupported model id {model}")
    if turbo not in VALID_TURBO:
        raise vs.Error(f"RIFE runtime: unsupported turbo {turbo}")
    if flow_scale not in VALID_FLOW_SCALE:
        raise vs.Error(f"RIFE runtime: unsupported flow_scale {flow_scale}")
    if not MODEL_INFO[model]["supports_flow_scale"] and flow_scale != 1.0:
        label = MODEL_INFO[model]["label"]
        raise vs.Error(f"RIFE runtime: model {label} only supports flow_scale=1.0 in current vs-mlrt")

    return {
        "model": model,
        "model_label": MODEL_INFO[model]["label"],
        "turbo": turbo,
        "flow_scale": flow_scale,
        "h_pre": h_pre,
        "fps_num": fps_num,
        "fps_den": fps_den,
        "sc_mode": sc_mode,
        "gpu": gpu,
        "gpu_t": gpu_t,
        "ws_size": ws_size,
        "lk_fmt": lk_fmt,
    }


config = load_config()
ret = k7f.FPS_CTRL(clip, fps_in=container_fps, fps_ret=True)
clip = k7f.FMT_CTRL(clip, h_max=config["h_pre"], fmt_pix=1 if config["lk_fmt"] else 0)
clip = k7f.RIFE_NV(
    clip,
    model=config["model"],
    int8_qnt=False,
    turbo=config["turbo"],
    fps_in=container_fps,
    fps_num=config["fps_num"],
    fps_den=config["fps_den"],
    sc_mode=config["sc_mode"],
    gpu=config["gpu"],
    gpu_t=config["gpu_t"],
    ws_size=config["ws_size"],
    flow_scale=config["flow_scale"],
)

clip.set_output()
