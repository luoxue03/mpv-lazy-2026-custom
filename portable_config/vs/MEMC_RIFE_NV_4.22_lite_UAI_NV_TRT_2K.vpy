### 使用自定义的AI放大模型，RTX N卡专用
### 文档_ https://github.com/hooke007/MPV_lazy/discussions/329
### 参数_ https://github.com/hooke007/MPV_lazy/wiki/3_K7sfunc#uai_nv_trt

### https://github.com/hooke007/MPV_lazy/wiki/3_K7sfunc
### mvtools的偏保守型补帧策略，中等消耗。

### From Luoxue
import vapoursynth as vs
from vapoursynth import core
import k7sfunc as k7f

clip = video_in

### 用户选项 ###

### 超分辨率 ###
H_Pre = 720
Model = "the_database_AnimeJaNaiV2L1_x2_fp16_op17.onnx"
Fp16_Qnt = True
Gpu = 0
Gpu_T = 2
St_Eng = False
Res_Opt = [1280, 720]
Res_Max = [1920, 1200]
Ws_Size = 0
H_Max = 2160
Lk_Fmt = False
## 整数，预降低处理源高度
## 指定使用的模型，文件放置位为 .../mpv-lazy/vs-plugins/models/
## <True|False> 是否为fp32模型使用fp16量化
## 使用的显卡序号，0为排序一号
## <1|2|3> 使用的显卡线程数
## <True|False> 是否使用静态引擎，否则为动态
## 动态引擎的优化源分辨率（高度不大于 H_Pre）
## 动态引擎的最大支持源分辨率
## <0~1024> 整数，约束显存（MiB），最小值为128，设为低于此数的值即为不限制
## 整数，输出高度限制（填你的显示器高度）
## <True|False> 是否锁定像素格式为yuv420p8


# 补帧选项
H_Pre_RIFE = 2160
Model_RIFE = 4221
Fps_Num = 2
Fps_Den = 1
Sc_Mode = 1
Gpu_RIFE = 0
Gpu_T_RIFE = 4
Ws_Size_RIFE = 0
Lk_Fmt_RIFE = False
## 整数，预降低处理源高度（填你的显示器高度）
## [46, 422, 4221, 4251, 4151, 426, 4262] 使用的模型
## 整数，Fps_Num/Fps_Den 的值即帧率倍数
## 整数
## <0|1|2> 场景切换检测的模式，0为禁用
## 使用的显卡序号，0为排序一号
## <1|2|3> 显卡线程数
## 整数，手动约束引擎构建阶段的显存（MiB），最小值为128，设为低于此数的值即最大化利用
## <True|False> 锁定像素格式为yuv420p8


##############
# 处理流程 #
##############

# 超分辨率处理
ret = k7f.FMT_CTRL(clip, h_max=1200, h_ret=True)
clip = k7f.FMT_CTRL(clip, h_max=H_Pre, fmt_pix=1 if Lk_Fmt else 0)
clip = k7f.UAI_NV_TRT(clip, crc=False, model_pth=Model, opt_lv=3, cuda_opt=[0, 0, 0], int8_qnt=False, fp16_qnt=Fp16_Qnt, gpu=Gpu, gpu_t=Gpu_T, st_eng=St_Eng, res_opt=Res_Opt, res_max=Res_Max, ws_size=Ws_Size)
clip = k7f.FMT_CTRL(clip, h_max=H_Max, fmt_pix=1 if Lk_Fmt else 0)

# 补帧处理
clip = k7f.FMT_CTRL(clip, h_max=H_Pre_RIFE, fmt_pix=1 if Lk_Fmt_RIFE else 0)
clip = k7f.RIFE_NV(clip, model=Model_RIFE, int8_qnt=False, turbo=True, fps_in=container_fps, fps_num=Fps_Num, fps_den=Fps_Den, sc_mode=Sc_Mode, gpu=Gpu_RIFE, gpu_t=Gpu_T_RIFE, ws_size=Ws_Size_RIFE)

clip.set_output()