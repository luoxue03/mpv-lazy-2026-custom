import vapoursynth as vs
from vapoursynth import core
import k7sfunc as k7f

core.num_threads = k7f.vs_t_dft
clip = core.std.BlankClip(width=3840, height=2160, format=vs.YUV420P16, length=8, fpsnum=25, fpsden=1, color=[4096, 32768, 32768])
clip = k7f.FMT_CTRL(clip, h_max=2160, fmt_pix=0)
clip = k7f.RIFE_NV(
    clip,
    model=46,
    int8_qnt=False,
    turbo=2,
    fps_in=25.0,
    fps_num=2,
    fps_den=1,
    sc_mode=1,
    gpu=0,
    gpu_t=2,
    ws_size=0,
    flow_scale=0.5,
)
clip.set_output()
