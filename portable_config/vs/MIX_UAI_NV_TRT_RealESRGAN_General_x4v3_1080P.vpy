### Real-ESRGAN General x4v3 experimental 4x super-resolution, NVIDIA TensorRT only
### Source model: realesr-general-x4v3, intended for general/live-action content
### Note: this ONNX is adapted to dynamic input shape for k7sfunc UAI_NV_TRT.

import vapoursynth as vs
from vapoursynth import core
import k7sfunc as k7f

core.num_threads = k7f.vs_t_dft
clip = video_in

############
# Options  #
############

H_Pre = 1080
Model = "realesr-general-x4v3_dynamic.onnx"
Fp16_Qnt = True
Gpu = 0
Gpu_T = 2
St_Eng = True
Res_Opt = [1920, 1080]
Res_Max = [1920, 1080]
Ws_Size = 0
H_Max = 2160
Lk_Fmt = False

ret = k7f.FMT_CTRL(clip, h_max=1200, h_ret=True)
clip = k7f.FMT_CTRL(clip, h_max=H_Pre, fmt_pix=1 if Lk_Fmt else 0)
clip = k7f.UAI_NV_TRT(clip, crc=False, model_pth=Model, opt_lv=5, cuda_opt=[1, 0, 0], int8_qnt=False, fp16_qnt=Fp16_Qnt, gpu=Gpu, gpu_t=Gpu_T, st_eng=St_Eng, res_opt=Res_Opt, res_max=Res_Max, ws_size=Ws_Size)
clip = k7f.FMT_CTRL(clip, h_max=H_Max, fmt_pix=1 if Lk_Fmt else 0)

clip.set_output()
