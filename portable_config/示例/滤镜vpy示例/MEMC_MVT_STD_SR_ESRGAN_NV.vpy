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
H_Pre_MVT = 2160
Fps_Out = container_fps*2
Lk_Fmt_MVT = False

## 整数，预降低处理源高度（填你的显示器高度）
## 浮点，目标帧率，示例即约60fps。特殊值比如 display_fps/2 即目标为显示器刷新率的一半帧率；填 container_fps*2 即倍帧（越高的帧率增加耗能，产生更多伪影，通常是不必要的。例如对于144hz的显示器来说，最多只需要补到72fps，剩下的可让 --interpolation 帧混成补偿）
## <True|False> 锁定像素格式为yuv420p8

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
clip = k7f.FMT_CTRL(clip, h_max=H_Pre_MVT, fmt_pix=1 if Lk_Fmt_MVT else 0)

clip = k7f.MVT_STD(clip, fps_in=container_fps, fps_out=Fps_Out)

# 输出
clip.set_output()






