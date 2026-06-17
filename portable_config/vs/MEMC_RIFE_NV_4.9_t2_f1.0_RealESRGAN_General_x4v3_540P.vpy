### RealESRGAN General x4v3 540P -> 4K + RIFE 4.9 T2 F1.0, NVIDIA TensorRT only
### Strong live-action/general enhancement first, then RIFE interpolation.

import vapoursynth as vs
from vapoursynth import core
import k7sfunc as k7f

core.num_threads = k7f.vs_t_dft
clip = video_in

############
# Options  #
############

SR_H_Pre = 540
SR_Model = "realesr-general-x4v3_dynamic.onnx"
SR_Fp16_Qnt = True
SR_Gpu = 0
SR_Gpu_T = 2
SR_St_Eng = True
SR_Res_Opt = [960, 540]
SR_Res_Max = [960, 540]
SR_Ws_Size = 0
SR_H_Max = 2160
SR_Lk_Fmt = False

RIFE_H_Pre = 2160
RIFE_Model = 49
RIFE_Fps_Num = 2
RIFE_Fps_Den = 1
RIFE_Sc_Mode = 1
RIFE_Gpu = 0
RIFE_Gpu_T = 2
RIFE_Ws_Size = 0
RIFE_Lk_Fmt = False
RIFE_Turbo = 2
RIFE_Flow_Scale = 1.0

ret = k7f.FMT_CTRL(clip, h_max=1200, h_ret=True)
clip = k7f.FMT_CTRL(clip, h_max=SR_H_Pre, fmt_pix=1 if SR_Lk_Fmt else 0)
clip = k7f.UAI_NV_TRT(clip, crc=False, model_pth=SR_Model, opt_lv=5, cuda_opt=[1, 0, 0], int8_qnt=False, fp16_qnt=SR_Fp16_Qnt, gpu=SR_Gpu, gpu_t=SR_Gpu_T, st_eng=SR_St_Eng, res_opt=SR_Res_Opt, res_max=SR_Res_Max, ws_size=SR_Ws_Size)
clip = k7f.FMT_CTRL(clip, h_max=SR_H_Max, fmt_pix=1 if SR_Lk_Fmt else 0)

ret = k7f.FPS_CTRL(clip, fps_in=container_fps, fps_ret=True)
clip = k7f.FMT_CTRL(clip, h_max=RIFE_H_Pre, fmt_pix=1 if RIFE_Lk_Fmt else 0)
clip = k7f.RIFE_NV(clip, model=RIFE_Model, int8_qnt=False, turbo=RIFE_Turbo, fps_in=container_fps, fps_num=RIFE_Fps_Num, fps_den=RIFE_Fps_Den, sc_mode=RIFE_Sc_Mode, gpu=RIFE_Gpu, gpu_t=RIFE_Gpu_T, ws_size=RIFE_Ws_Size, flow_scale=RIFE_Flow_Scale)

clip.set_output()
