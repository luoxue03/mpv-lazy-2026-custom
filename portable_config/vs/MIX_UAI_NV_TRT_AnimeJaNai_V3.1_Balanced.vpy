### AnimeJaNai V3.1 Balanced standard 2x super-resolution, NVIDIA TensorRT only
### Source: the-database/mpv-upscale-2x_animejanai 3.3.0
### Note: quality-first V3.1 model; official target is near UltraCompact speed with better-than-Compact quality
### Best for 720p/1080p anime upscaling. Native 4K input is limited to 1080p before 2x upscale.

import vapoursynth as vs
from vapoursynth import core
import k7sfunc as k7f

core.num_threads = k7f.vs_t_dft
clip = video_in

############
# Options  #
############

H_Pre = 1080
Model = "2x_AnimeJaNai_HD_V3.1_Balanced_SPANF3_b8f64_unshuffle_fp16.onnx"
Fp16_Qnt = True
Gpu = 0
Gpu_T = 2
St_Eng = True
Res_Opt = [1920, 1080]
Res_Max = [1920, 1080]
Ws_Size = 0
H_Max = 2160
Lk_Fmt = False
# H_Pre limits input height; AnimeJaNai HD V3.1 is designed for 1080p -> 4K.
# Model files are located in .../mpv-lazy/vs-plugins/models/.
# St_Eng=True follows AnimeJaNai 3.3.0 static-engine preference for playback performance.

ret = k7f.FMT_CTRL(clip, h_max=1200, h_ret=True)
clip = k7f.FMT_CTRL(clip, h_max=H_Pre, fmt_pix=1 if Lk_Fmt else 0)
clip = k7f.UAI_NV_TRT(clip, crc=False, model_pth=Model, opt_lv=5, cuda_opt=[1, 0, 0], int8_qnt=False, fp16_qnt=Fp16_Qnt, gpu=Gpu, gpu_t=Gpu_T, st_eng=St_Eng, res_opt=Res_Opt, res_max=Res_Max, ws_size=Ws_Size)
clip = k7f.FMT_CTRL(clip, h_max=H_Max, fmt_pix=1 if Lk_Fmt else 0)

clip.set_output()
