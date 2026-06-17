from __future__ import annotations

import argparse
from collections import OrderedDict
from pathlib import Path

import torch
from torch import nn


class SRVGGNetCompact(nn.Module):
    def __init__(
        self,
        num_in_ch: int = 3,
        num_out_ch: int = 3,
        num_feat: int = 64,
        num_conv: int = 32,
        upscale: int = 4,
        act_type: str = "prelu",
    ) -> None:
        super().__init__()
        self.upscale = upscale
        self.body = nn.ModuleList()
        self.body.append(nn.Conv2d(num_in_ch, num_feat, 3, 1, 1))
        if act_type == "prelu":
            self.body.append(nn.PReLU(num_parameters=num_feat))
        elif act_type == "relu":
            self.body.append(nn.ReLU(inplace=True))
        else:
            raise ValueError(act_type)
        for _ in range(num_conv):
            self.body.append(nn.Conv2d(num_feat, num_feat, 3, 1, 1))
            if act_type == "prelu":
                self.body.append(nn.PReLU(num_parameters=num_feat))
            else:
                self.body.append(nn.ReLU(inplace=True))
        self.body.append(nn.Conv2d(num_feat, num_out_ch * upscale * upscale, 3, 1, 1))
        self.upsampler = nn.PixelShuffle(upscale)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        out = x
        for layer in self.body:
            out = layer(out)
        out = self.upsampler(out)
        base = torch.nn.functional.interpolate(x, scale_factor=self.upscale, mode="nearest")
        return out + base


def load_weights(path: Path) -> OrderedDict[str, torch.Tensor]:
    state = torch.load(path, map_location="cpu")
    if isinstance(state, dict) and "params_ema" in state:
        state = state["params_ema"]
    elif isinstance(state, dict) and "params" in state:
        state = state["params"]
    return OrderedDict((key.replace("module.", ""), value) for key, value in state.items())


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Export official realesr-general-x4v3 .pth weights to dynamic ONNX for k7sfunc UAI_NV_TRT."
    )
    parser.add_argument("--input", required=True, type=Path, help="Path to official realesr-general-x4v3.pth")
    parser.add_argument("--output", required=True, type=Path, help="Output ONNX path")
    args = parser.parse_args()

    model = SRVGGNetCompact(num_in_ch=3, num_out_ch=3, num_feat=64, num_conv=32, upscale=4, act_type="prelu")
    missing, unexpected = model.load_state_dict(load_weights(args.input), strict=False)
    if missing or unexpected:
        raise SystemExit(f"missing={missing}\nunexpected={unexpected[:20]}")
    model.eval()

    args.output.parent.mkdir(parents=True, exist_ok=True)
    dummy = torch.randn(1, 3, 64, 64)
    torch.onnx.export(
        model,
        dummy,
        args.output,
        input_names=["input"],
        output_names=["output"],
        dynamic_axes={
            "input": {2: "height", 3: "width"},
            "output": {2: "height_out", 3: "width_out"},
        },
        opset_version=17,
        do_constant_folding=True,
    )
    print(args.output)
    print(args.output.stat().st_size)


if __name__ == "__main__":
    main()
