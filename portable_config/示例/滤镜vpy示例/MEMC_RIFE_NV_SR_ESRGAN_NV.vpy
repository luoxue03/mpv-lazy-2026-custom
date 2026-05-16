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
## 整数，预降低处理源高度
## <True|False> 是否对超过HD分辨率（720P）的源进行处理
## <0|2|5005|5006|5007|5008|5009|5010> 使用的模型
## 使用的显卡序号，0为排序一号
## <1|2|3> 使用的显卡线程数
## <True|False> 是否使用静态引擎（需要对不同分辨率的源各进行预处理）；动态引擎自适应不同分辨率（64²→DCI2K）
## <0~1024> 约束显存（MiB），静态引擎的最小值为128（动态引擎自动双倍），设为低于此数的值即为不限制
## 整数，输出高度限制（填你的显示器高度）
## <True|False> 是否锁定像素格式为yuv420p8


# 补帧选项
H_Pre_RIFE = 2160
Model_RIFE = 46
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
clip = k7f.FMT_CTRL(clip, h_max=H_Pre_SR, fmt_pix=1 if Lk_Fmt_SR else 0)  # 降采样
clip = k7f.ESRGAN_NV(
    clip, lt_hd=Lt_Hd_SR, model=Model_SR, gpu=Gpu_SR, gpu_t=Gpu_T_SR, st_eng=St_Eng_SR, ws_size=Ws_Size_SR
)  # ESRGAN超分辨率处理
clip = k7f.FMT_CTRL(clip, h_max=H_Max_SR, fmt_pix=1 if Lk_Fmt_SR else 0)  # 恢复最大分辨率


# 补帧处理
clip = k7f.FMT_CTRL(clip, h_max=H_Pre_RIFE, fmt_pix=1 if Lk_Fmt_RIFE else 0)
clip = k7f.RIFE_NV(clip, model=Model_RIFE, int8_qnt=False, turbo=True, fps_in=container_fps, fps_num=Fps_Num, fps_den=Fps_Den, sc_mode=Sc_Mode, gpu=Gpu_RIFE, gpu_t=Gpu_T_RIFE, ws_size=Ws_Size_RIFE)

# 输出
clip.set_output()
