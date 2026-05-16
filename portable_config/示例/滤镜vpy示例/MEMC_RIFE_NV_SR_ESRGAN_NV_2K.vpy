import vapoursynth as vs
from vapoursynth import core
import k7sfunc as k7f

# 输入视频
clip = video_in

############
# 用户选项 #
############

# 超分辨率选项
H_Pre_SR = 720  # 预降低处理源高度
Lt_Hd_SR = True  # 是否对低于HD分辨率处理
Model_SR = 2 # 超分辨率使用模型
Gpu_SR = 0  # GPU序号
Gpu_T_SR = 2  # GPU线程数
St_Eng_SR = False  # 是否使用静态引擎
Ws_Size_SR = 0  # 显存限制
H_Max_SR = 2160  # 超分辨率输出的最大高度
Lk_Fmt_SR = False  # 是否锁定像素格式

# 补帧选项
H_Pre_RIFE = 1440   # 预降低处理源高度
Lt_D2k_RIFE = True  # 是否对低于DCI2K分辨率补帧
Model_RIFE = 4251  # 补帧使用模型
Ext_Proc_RIFE = False  # 是否使用外部处理
T_Tta_RIFE = False  # 是否使用ensemble版模型
Fps_Num_RIFE = 2  # 帧率分子（倍数）
Fps_Den_RIFE = 1  # 帧率分母（倍数）
Sc_Mode_RIFE = 1  # 场景切换模式
Gpu_RIFE = 0  # GPU序号
Gpu_T_RIFE = 2  # GPU线程数
St_Eng_RIFE = False  # 是否使用静态引擎
Ws_Size_RIFE = 0  # 显存限制
Lk_Fmt_RIFE = False  # 是否锁定像素格式

##############
# 处理流程 #
##############

# 超分辨率处理
clip = k7f.FMT_CTRL(clip, h_max=H_Pre_SR, fmt_pix=1 if Lk_Fmt_SR else 0)  # 降采样
clip = k7f.ESRGAN_NV(
    clip, lt_hd=Lt_Hd_SR, model=Model_SR, gpu=Gpu_SR, gpu_t=Gpu_T_SR, st_eng=St_Eng_SR, ws_size=Ws_Size_SR
)  # ESRGAN超分辨率处理
clip = k7f.FMT_CTRL(clip, h_max=H_Max_SR, fmt_pix=1 if Lk_Fmt_SR else 0)  # 恢复最大分辨率


# 补帧处理
clip = k7f.FMT_CTRL(clip, h_max=H_Pre_RIFE, fmt_pix=1 if Lk_Fmt_RIFE else 0)  # 再次降采样
clip = k7f.RIFE_NV(
    clip,
    lt_d2k=Lt_D2k_RIFE,
    model=Model_RIFE,
    ext_proc=Ext_Proc_RIFE,
    t_tta=T_Tta_RIFE,
    fps_in=container_fps,
    fps_num=Fps_Num_RIFE,
    fps_den=Fps_Den_RIFE,
    sc_mode=Sc_Mode_RIFE,
    gpu=Gpu_RIFE,
    gpu_t=Gpu_T_RIFE,
    st_eng=St_Eng_RIFE,
    ws_size=Ws_Size_RIFE,
)  # RIFE补帧处理

# 输出
clip.set_output()
