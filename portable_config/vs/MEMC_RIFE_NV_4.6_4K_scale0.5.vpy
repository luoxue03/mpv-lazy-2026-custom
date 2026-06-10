### https://github.com/hooke007/MPV_lazy/wiki/3_K7sfunc
### RIFE 4.6 4K scale=0.5 smooth-first experimental preset, NVIDIA TensorRT only
### Note: real scale=0.5 flow estimation for 4K smoothness; may reduce interpolation detail

import vapoursynth as vs
from vapoursynth import core
import k7sfunc as k7f

clip = video_in

############
# Options  #
############

H_Pre = 2160
Model = 46
Fps_Num = 2
Fps_Den = 1
Sc_Mode = 1
Gpu = 0
Gpu_T = 2
Ws_Size = 0
Lk_Fmt = False
Turbo = 1
Flow_Scale = 0.5
# H_Pre limits input height before RIFE.
# Model IDs: 46=4.6, 47=4.7, 48=4.8, 49=4.9, 4151=4.15_lite, 4251=4.25_lite, 426=4.26, 4262=4.26_heavy.
# Turbo: 0=ensemble quality path, 1=external processing path, 2=current fast v2 path.
# Flow_Scale only works on older models such as 4.6; vs-mlrt rejects non-1.0 scale for RIFE 4.7+.

ret = k7f.FPS_CTRL(clip, fps_in=container_fps, fps_ret=True)
clip = k7f.FMT_CTRL(clip, h_max=H_Pre, fmt_pix=1 if Lk_Fmt else 0)
clip = k7f.RIFE_NV(clip, model=Model, int8_qnt=False, turbo=Turbo, fps_in=container_fps, fps_num=Fps_Num, fps_den=Fps_Den, sc_mode=Sc_Mode, gpu=Gpu, gpu_t=Gpu_T, ws_size=Ws_Size, flow_scale=Flow_Scale)

clip.set_output()
