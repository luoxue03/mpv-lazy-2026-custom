# Overview

This page includes benchmarks for various hardware configurations tested against various upscaling configurations. In order to run 23.976 fps video smoothly in mpv, a benchmark fps of 30 or higher is recommended. 

# Running Benchmarks

To generate benchmarks for your hardware, first ensure that you are running the latest `v3.2.0` release. Then launch `mpvnet.exe`, press `ctrl+E` to launch AnimeJaNaiConfEditor, and press the Run Benchmarks button on the bottom left of the window. After running benchmarks for several minutes, a `benchmark.txt` file will be saved at `mpv-upscale-2x_animejanai-v3.2.0\animejanai\benchmark.txt`. This contains the benchmark results in a table in markdown format which can be pasted directly to this wiki. If you have hardware which has not been benchmarked on this wiki and you would like to contribute, feel free to run a benchmark and paste your benchmark results to this wiki. Please include the GPU and CPU which were used in your benchmarks. 

# Single Benchmarks
Benchmarking a single resolution can be done via command line. For example to benchmark at 1080p only:
```
C:\mpv-upscale-2x_animejanai-v3.2.2\vs-plugins\vsmlrt-cuda\trtexec --onnx="C:\mpv-upscale-2x_animejanai-v3.2.2\animejanai\onnx\2x_AnimeJaNai_HD_V3_Compact.onnx" --saveEngine="C:\mpv-upscale-2x_animejanai-v3.2.2\animejanai\onnx\2x_AnimeJaNai_HD_V3_Compact.engine" --stronglyTyped --optShapes=input:1x3x1080x1920 --builderOptimizationLevel=5 --tacticSources=-CUDNN,-CUBLAS,-CUBLAS_LT --skipInference
C:\mpv-upscale-2x_animejanai-v3.2.2\vs-plugins\vsmlrt-cuda\trtexec --loadEngine="C:\mpv-upscale-2x_animejanai-v3.2.2\animejanai\onnx\2x_AnimeJaNai_HD_V3_Compact.engine" --stronglyTyped --optShapes=input:1x3x1080x1920 --warmUp=1000 --duration=10 --noDataTransfers --useCudaGraph --useSpinWait
```

# Benchmark Results - Nvidia GPU

## RTX 5090
### RTX 5090 + i9-12900K + v3.2.0 build (the-database)
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|706.43 fps|420.06 fps|283.19 fps|133.69 fps|59.71 fps
|2x (2x_UltraCompact)|1215.53 fps|735.72 fps|507.85 fps|243.66 fps|109.69 fps
|2x (2x_SuperUltraCompact)|1580.22 fps|919.84 fps|648.49 fps|303.36 fps|131.31 fps
|4x (2x_Compact+2x_Compact)|141.35 fps|81.63 fps|62.13 fps|41.40 fps|
|4x (2x_Compact+2x_UltraCompact)|221.21 fps|129.24 fps|96.78 fps|60.72 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|350.39 fps|199.54 fps|132.38 fps|82.43 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|378.47 fps|214.96 fps|144.67 fps|95.68 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|242.95 fps|142.43 fps|110.95 fps|76.32 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|385.55 fps|220.90 fps|150.85 fps|100.59 fps|

### RTX 5090 + i9-13900K + v3.2.0 build (422415)
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|704.74 fps|404.80 fps|271.94 fps|130.42 fps|58.30 fps
|2x (2x_UltraCompact)|1162.22 fps|696.00 fps|459.11 fps|231.38 fps|104.56 fps
|2x (2x_SuperUltraCompact)|1778.28 fps|1081.59 fps|762.47 fps|379.41 fps|162.38 fps
|4x (2x_Compact+2x_Compact)|138.68 fps|79.02 fps|60.27 fps|40.83 fps|
|4x (2x_Compact+2x_UltraCompact)|213.63 fps|122.69 fps|91.93 fps|58.63 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|357.41 fps|208.92 fps|147.54 fps|87.29 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|421.67 fps|248.48 fps|155.20 fps|113.24 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|243.96 fps|140.14 fps|105.24 fps|72.62 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|453.16 fps|256.69 fps|165.90 fps|116.90 fps|

## RTX 5080
### RTX 5080 Inspire OC (C+550Mhz|M+2000Mhz @850mV) + 9800x3D(Custom PBO) + 32GB @6000Mhz + V3.2.1 build [Bradjy]
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|462.00 fps|268.18 fps|192.11 fps|95.80 fps|43.44 fps
|2x (2x_UltraCompact)|729.06 fps|424.74 fps|303.74 fps|151.72 fps|68.90 fps
|2x (2x_SuperUltraCompact)|1195.85 fps|732.04 fps|524.42 fps|258.40 fps|115.47 fps
|4x (2x_Compact+2x_Compact)|99.31 fps|57.15 fps|44.34 fps|29.59 fps|
|4x (2x_Compact+2x_UltraCompact)|139.58 fps|80.50 fps|61.92 fps|40.29 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|199.08 fps|112.65 fps|85.31 fps|52.47 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|236.70 fps|133.46 fps|102.04 fps|65.68 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|156.96 fps|90.57 fps|70.23 fps|47.41 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|271.60 fps|153.52 fps|118.28 fps|79.95 fps|

### Streaming to your friends?
You can watch the upscaled anime and stream it just fine in real time. I have tested this on Discord and the sweet spot is at 1440p30fps. Performance loss should be about 1-2% or more depending on your hardware and the source of the anime (BluRay / WEB-DL).

### RTX 5080 OC (C+550MHz | M+1999MHz @ 890mV) + 9900X3D + v3.2.0 build
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|419.52 fps|240.26 fps|164.14 fps|79.90 fps|36.09 fps
|2x (2x_UltraCompact)|766.31 fps|428.89 fps|290.66 fps|143.07 fps|63.99 fps
|2x (2x_SuperUltraCompact)|1594.83 fps|888.36 fps|646.34 fps|336.24 fps|145.06 fps
|4x (2x_Compact+2x_Compact)|85.09 fps|48.67 fps|37.56 fps|24.95 fps|
|4x (2x_Compact+2x_UltraCompact)|131.05 fps|74.86 fps|57.09 fps|35.92 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|241.75 fps|130.30 fps|96.64 fps|54.92 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|318.81 fps|171.16 fps|127.41 fps|76.83 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|151.68 fps|86.43 fps|66.32 fps|44.46 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|381.14 fps|216.44 fps|151.09 fps|103.14 fps|

### RTX 5080 + 9900X3D + v3.2.0 build
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|377.07 fps|215.99 fps|141.30 fps|73.13 fps|32.94 fps
|2x (2x_UltraCompact)|731.98 fps|383.82 fps|260.92 fps|131.00 fps|58.81 fps
|2x (2x_SuperUltraCompact)|1655.89 fps|819.41 fps|603.67 fps|317.69 fps|137.74 fps
|4x (2x_Compact+2x_Compact)|77.22 fps|42.81 fps|33.84 fps|22.74 fps|
|4x (2x_Compact+2x_UltraCompact)|121.43 fps|66.56 fps|51.62 fps|32.83 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|217.33 fps|117.46 fps|81.21 fps|49.15 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|300.39 fps|155.60 fps|115.88 fps|70.89 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|140.81 fps|79.42 fps|60.55 fps|40.55 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|370.03 fps|191.65 fps|143.16 fps|96.08 fps|

### RTX 5080 OC (C+550MHz | M+1999MHz @ 890mV) + i5-13600K + v3.2.0 build
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|420.26 fps|236.68 fps|161.35 fps|75.65 fps|34.55 fps
|2x (2x_UltraCompact)|721.67 fps|402.70 fps|261.73 fps|128.80 fps|58.81 fps
|2x (2x_SuperUltraCompact)|1207.57 fps|595.91 fps|485.89 fps|235.11 fps|91.06 fps
|4x (2x_Compact+2x_Compact)|83.59 fps|47.67 fps|35.97 fps|24.55 fps|
|4x (2x_Compact+2x_UltraCompact)|127.62 fps|72.80 fps|54.63 fps|34.24 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|223.99 fps|120.52 fps|81.29 fps|46.99 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|264.61 fps|148.93 fps|103.67 fps|63.26 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|147.09 fps|83.57 fps|64.18 fps|40.65 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|284.43 fps|156.14 fps|110.81 fps|70.80 fps|

## RTX 5070 Ti
### RTX 5070ti + 9800x3D + v3.2.0 build
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|288.30 fps|159.18 fps|112.42 fps|54.94 fps|24.65 fps
|2x (2x_UltraCompact)|522.34 fps|289.69 fps|204.97 fps|100.45 fps|44.95 fps
|2x (2x_SuperUltraCompact)|1285.57 fps|774.37 fps|556.08 fps|269.96 fps|122.63 fps
|4x (2x_Compact+2x_Compact)|58.75 fps|33.25 fps|25.40 fps|16.97 fps|
|4x (2x_Compact+2x_UltraCompact)|92.49 fps|51.76 fps|39.06 fps|24.49 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|162.81 fps|90.75 fps|66.72 fps|37.12 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|214.18 fps|121.06 fps|91.13 fps|55.58 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|106.27 fps|60.06 fps|46.33 fps|30.91 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|283.35 fps|164.84 fps|126.62 fps|83.97 fps|

### RTX 5070ti + Intel I5-11400
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|273.20 fps|154.72 fps|109.57 fps|54.09 fps|24.16 fps
|2x (2x_UltraCompact)|476.67 fps|266.76 fps|189.30 fps|93.68 fps|42.20 fps
|2x (2x_SuperUltraCompact)|932.39 fps|502.17 fps|362.44 fps|172.90 fps|81.12 fps
|4x (2x_Compact+2x_Compact)|56.78 fps|32.13 fps|24.80 fps|16.70 fps|
|4x (2x_Compact+2x_UltraCompact)|86.74 fps|49.25 fps|37.56 fps|24.02 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|147.12 fps|83.69 fps|61.89 fps|36.01 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|186.72 fps|107.94 fps|79.60 fps|49.01 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|99.77 fps|56.98 fps|44.08 fps|29.69 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|213.68 fps|122.52 fps|86.05 fps|59.50 fps|

## RTX 5060 TI
### RTX 5060 TI 16GB + Ryzen 7 5800X3D 4.45Ghz + 64GB DDR4 3600Mhz + v3.2.0 build [Bradjy]
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|183.00 fps|97.87 fps|67.73 fps|33.13 fps|14.60 fps
|2x (2x_UltraCompact)|337.87 fps|184.13 fps|127.64 fps|61.03 fps|27.58 fps
|2x (2x_SuperUltraCompact)|783.14 fps|474.83 fps|293.58 fps|154.94 fps|71.28 fps
|4x (2x_Compact+2x_Compact)|35.05 fps|19.69 fps|15.41 fps|10.18 fps|
|4x (2x_Compact+2x_UltraCompact)|56.68 fps|31.39 fps|22.81 fps|14.75 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|97.83 fps|54.75 fps|39.57 fps|22.31 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|129.06 fps|73.21 fps|55.15 fps|32.62 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|64.42 fps|36.46 fps|28.03 fps|18.77 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|159.16 fps|94.84 fps|74.10 fps|49.58 fps|

### Just a heads up
**I wouldn't really trust this GPU with anything, since it kept giving me black screens during the benchmark. Whenever it goes to or near 100% usage it either lags, black screens or straight up crashes. I'm not sure if it's the drivers, the GPU model I got(MSI Ventus 2x OC Plus) or just the 5060 TI in general. Your mileage may vary.**


##  RTX 4090

### RTX 4090 + i9-13900K + v2 build + v3 fp16 models ([422415](https://github.com/422415))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|433.58 fps|252.50 fps|170.21 fps|84.82 fps|38.26 fps
|2x (2x_UltraCompact)|739.29 fps|406.56 fps|272.49 fps|139.95 fps|61.11 fps
|2x (2x_SuperUltraCompact)|1407.08 fps|847.08 fps|606.60 fps|280.94 fps|122.78 fps
|4x (2x_Compact+2x_Compact)|89.04 fps|51.51 fps|39.34 fps|26.36 fps|
|4x (2x_Compact+2x_UltraCompact)|125.60 fps|73.05 fps|54.25 fps|35.68 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|209.59 fps|110.56 fps|81.74 fps|49.69 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|261.36 fps|138.18 fps|102.05 fps|66.16 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|141.81 fps|81.25 fps|62.99 fps|43.81 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|319.09 fps|166.82 fps|128.48 fps|86.17 fps|

### RTX 4090 + i9-13900K + v2 build + v2 fp16 models ([422415](https://github.com/422415))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|449.50 fps|257.29 fps|154.00 fps|84.85 fps|38.36 fps
|2x (2x_UltraCompact)|738.11 fps|408.52 fps|264.06 fps|141.12 fps|61.61 fps
|2x (2x_SuperUltraCompact)|1400.62 fps|805.75 fps|588.83 fps|279.86 fps|123.05 fps
|4x (2x_Compact+2x_Compact)|89.04 fps|51.47 fps|36.54 fps|25.39 fps|
|4x (2x_Compact+2x_UltraCompact)|131.68 fps|73.67 fps|53.67 fps|36.36 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|211.88 fps|111.33 fps|79.47 fps|50.91 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|260.14 fps|139.62 fps|96.96 fps|66.29 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|148.89 fps|85.38 fps|58.73 fps|42.90 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|308.45 fps|154.79 fps|121.74 fps|86.43 fps|

### RTX 4090 + i9-13900K + v2 build + v3 fp32 models ([422415](https://github.com/422415))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|374.30 fps|226.11 fps|150.72 fps|75.09 fps|33.08 fps
|2x (2x_UltraCompact)|583.54 fps|336.74 fps|235.35 fps|111.95 fps|51.86 fps
|2x (2x_SuperUltraCompact)|990.09 fps|583.82 fps|417.21 fps|191.16 fps|83.35 fps
|4x (2x_Compact+2x_Compact)|77.01 fps|43.61 fps|33.76 fps|23.42 fps|
|4x (2x_Compact+2x_UltraCompact)|107.22 fps|61.91 fps|47.29 fps|30.03 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|159.67 fps|87.40 fps|65.33 fps|39.19 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|186.70 fps|99.60 fps|76.74 fps|48.96 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|118.13 fps|68.60 fps|53.71 fps|35.59 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|206.75 fps|113.10 fps|87.92 fps|56.49 fps|

### RTX 4090 + 7800x3D
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|484.71 fps|265.74 fps|173.29 fps|88.54 fps|39.89 fps
|2x (2x_UltraCompact)|738.30 fps|435.68 fps|294.18 fps|147.95 fps|67.26 fps
|2x (2x_SuperUltraCompact)|1033.64 fps|612.35 fps|422.79 fps|189.98 fps|85.97 fps
|4x (2x_Compact+2x_Compact)|93.27 fps|53.40 fps|38.48 fps|26.96 fps|
|4x (2x_Compact+2x_UltraCompact)|139.79 fps|79.33 fps|55.56 fps|39.00 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|168.04 fps|94.66 fps|68.25 fps|44.96 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|191.50 fps|108.75 fps|83.15 fps|53.53 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|155.31 fps|89.14 fps|68.55 fps|46.48 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|205.04 fps|114.54 fps|89.36 fps|59.42 fps|

### RTX 4090 + i9-13900K
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|512.00 fps|269.32 fps|161.24 fps|85.75 fps|37.10 fps
|2x (2x_UltraCompact)|649.80 fps|342.30 fps|240.18 fps|112.31 fps|50.56 fps
|2x (2x_SuperUltraCompact)|617.91 fps|364.06 fps|246.07 fps|106.21 fps|50.82 fps
|4x (2x_Compact+2x_Compact)|90.38 fps|52.11 fps|38.41 fps|25.85 fps|
|4x (2x_Compact+2x_UltraCompact)|138.68 fps|72.76 fps|49.66 fps||
|4x (2x_Compact+2x_SuperUltraCompact)|141.17 fps|75.12 fps|51.03 fps||
|4x (2x_UltraCompact+2x_SuperUltraCompact)|145.30 fps|73.10 fps|50.63 fps||
|4x (2x_UltraCompact+2x_UltraCompact)|138.84 fps|69.46 fps|50.88 fps|35.67 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|140.56 fps|73.63 fps|50.25 fps|36.13 fps|

### RTX 4090 + i9-13900K fp16 
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|514.26 fps|288.30 fps|176.22 fps|88.67 fps|40.08 fps
|2x (2x_UltraCompact)|933.72 fps|525.96 fps|321.32 fps|160.81 fps|72.99 fps
|2x (2x_SuperUltraCompact)|1442.50 fps|648.35 fps|463.23 fps|197.39 fps|85.44 fps
|4x (2x_Compact+2x_Compact)|93.55 fps|54.14 fps|40.70 fps|27.60 fps|
|4x (2x_Compact+2x_UltraCompact)|148.24 fps|85.72 fps|62.46 fps||
|4x (2x_Compact+2x_SuperUltraCompact)|236.48 fps|130.40 fps|88.12 fps||
|4x (2x_UltraCompact+2x_SuperUltraCompact)|236.86 fps|128.11 fps|89.18 fps||
|4x (2x_UltraCompact+2x_UltraCompact)|170.09 fps|85.04 fps|73.97 fps|50.37 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|241.05 fps|130.73 fps|86.95 fps|63.64 fps|

### RTX 4090 + i9-13900K fp16 infStreams=4 --builderOptimizationLevel=4
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|489.77 fps|265.88 fps|159.47 fps|79.63 fps|35.69 fps
|2x (2x_UltraCompact)|850.09 fps|466.03 fps|316.13 fps|143.09 fps|60.32 fps
|2x (2x_SuperUltraCompact)|1439.70 fps|632.65 fps|468.53 fps|193.16 fps|87.23 fps
|4x (2x_Compact+2x_Compact)|85.96 fps|48.41 fps|36.29 fps|24.63 fps|
|4x (2x_Compact+2x_UltraCompact)|136.99 fps|76.72 fps|55.43 fps||
|4x (2x_Compact+2x_SuperUltraCompact)|251.37 fps|119.62 fps|88.04 fps||
|4x (2x_UltraCompact+2x_SuperUltraCompact)|267.42 fps|124.10 fps|95.93 fps||
|4x (2x_UltraCompact+2x_UltraCompact)|153.56 fps|85.90 fps|65.66 fps|44.79 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|265.77 fps|124.47 fps|94.29 fps|64.90 fps|


### RTX 4090 + i9-13900K fp16 infStreams=4 --builderOptimizationLevel=4 (Redo)
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|517.10 fps|287.42 fps|174.83 fps|88.45 fps|40.17 fps
|2x (2x_UltraCompact)|906.39 fps|514.46 fps|322.76 fps|163.41 fps|73.54 fps
|2x (2x_SuperUltraCompact)|1511.68 fps|693.34 fps|478.79 fps|203.00 fps|92.17 fps
|4x (2x_Compact+2x_Compact)|93.72 fps|54.26 fps|40.64 fps|27.67 fps|
|4x (2x_Compact+2x_UltraCompact)|149.37 fps|86.21 fps|62.64 fps||
|4x (2x_Compact+2x_SuperUltraCompact)|271.53 fps|142.63 fps|96.53 fps||
|4x (2x_UltraCompact+2x_SuperUltraCompact)|279.71 fps|143.53 fps|99.28 fps||
|4x (2x_UltraCompact+2x_UltraCompact)|171.31 fps|98.30 fps|74.76 fps|50.81 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|281.62 fps|142.64 fps|96.06 fps|66.95 fps|

### RTX 4090 + i9-13900K DirectML
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|70.76 fps|52.39 fps|38.31 fps|20.07 fps|11.85 fps
|2x (2x_UltraCompact)|73.72 fps|55.16 fps|42.82 fps|23.07 fps|11.90 fps
|2x (2x_SuperUltraCompact)|76.39 fps|63.37 fps|46.40 fps|27.95 fps|15.43 fps
|4x (2x_Compact+2x_Compact)|24.55 fps|15.97 fps|13.36 fps|9.04 fps|
|4x (2x_Compact+2x_UltraCompact)|30.86 fps|17.01 fps|14.69 fps|10.56 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|32.89 fps|18.99 fps|15.46 fps|11.76 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|34.21 fps|19.66 fps|15.63 fps|12.02 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|28.71 fps|17.78 fps|15.51 fps|11.17 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|35.38 fps|20.43 fps|12.96 fps|12.99 fps|


### RTX 4090 + i9-13900K ([your-eggcellency](https://github.com/your-eggcellency))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|483.59 fps|276.37 fps|183.20 fps|91.37 fps|41.36 fps
|2x (2x_UltraCompact)|776.95 fps|445.90 fps|306.24 fps|154.10 fps|69.71 fps
|2x (2x_SuperUltraCompact)|1520.68 fps|911.78 fps|663.46 fps|325.43 fps|148.11 fps
|4x (2x_Compact+2x_Compact)|96.43 fps|55.54 fps|42.21 fps|28.57 fps|
|4x (2x_Compact+2x_UltraCompact)|144.60 fps|82.83 fps|61.82 fps|39.84 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|245.79 fps|134.52 fps|96.83 fps|57.52 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|301.01 fps|163.92 fps|122.20 fps|77.08 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|162.68 fps|93.60 fps|71.54 fps|48.40 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|365.18 fps|195.49 fps|142.42 fps|104.23 fps|

### RTX 4090 + i9-12900K v3.0.1 build
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|456.60 fps|265.89 fps|166.16 fps|82.35 fps|36.97 fps
|2x (2x_UltraCompact)|740.68 fps|434.57 fps|277.12 fps|137.01 fps|61.60 fps
|2x (2x_SuperUltraCompact)|1416.15 fps|851.65 fps|587.62 fps|278.40 fps|121.59 fps
|4x (2x_Compact+2x_Compact)|87.66 fps|50.30 fps|37.82 fps|25.66 fps|
|4x (2x_Compact+2x_UltraCompact)|130.11 fps|74.72 fps|54.82 fps|35.62 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|220.70 fps|117.44 fps|83.11 fps|50.62 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|265.10 fps|142.12 fps|103.67 fps|65.13 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|145.98 fps|83.82 fps|63.30 fps|42.67 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|309.19 fps|167.04 fps|111.88 fps|85.87 fps|


### RTX 4090 + Ryzen 5900x
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|530.07 fps|283.73 fps|181.28 fps|77.83 fps|35.82 fps
|2x (2x_UltraCompact)|968.65 fps|414.81 fps|335.90 fps|160.49 fps|68.16 fps
|2x (2x_SuperUltraCompact)|1521.37 fps|893.56 fps|604.91 fps|308.41 fps|134.09 fps
|4x (2x_Compact+2x_Compact)|97.93 fps|41.65 fps|36.45 fps|26.43 fps|
|4x (2x_Compact+2x_UltraCompact)|155.95 fps|66.21 fps|64.82 fps|39.25 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|308.27 fps|136.34 fps|85.52 fps|58.14 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|370.88 fps|160.92 fps|136.28 fps|82.54 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|133.74 fps|84.43 fps|69.45 fps|43.29 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|379.71 fps|175.97 fps|141.87 fps|92.71 fps|

### RTX 4090 + Ryzen 5800X3D, DDR4 3800Mhz w/ tuned timings 
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|476.51 fps|272.01 fps|177.86 fps|88.82 fps|40.39 fps
|2x (2x_UltraCompact)|775.65 fps|464.59 fps|304.72 fps|151.91 fps|69.03 fps
|2x (2x_SuperUltraCompact)|1397.58 fps|866.50 fps|575.00 fps|266.86 fps|121.20 fps
|4x (2x_Compact+2x_Compact)|93.69 fps|53.86 fps|41.08 fps|27.80 fps|
|4x (2x_Compact+2x_UltraCompact)|142.48 fps|81.28 fps|60.15 fps|38.79 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|236.31 fps|127.30 fps|92.51 fps|55.34 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|290.82 fps|158.75 fps|115.94 fps|74.47 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|161.62 fps|93.01 fps|71.00 fps|47.48 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|337.15 fps|174.52 fps|117.52 fps|85.19 fps|


### RTX 4090 + i7-9700K Num-Threads 8 + FP32 ([422415](https://github.com/422415))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|353.19 fps|209.63 fps|131.72 fps|65.83 fps|29.95 fps
|2x (2x_UltraCompact)|499.64 fps|290.56 fps|190.59 fps|93.55 fps|41.86 fps
|2x (2x_SuperUltraCompact)|666.13 fps|389.27 fps|275.12 fps|129.33 fps|56.58 fps
|4x (2x_Compact+2x_Compact)|68.33 fps|39.43 fps|30.20 fps|19.52 fps|
|4x (2x_Compact+2x_UltraCompact)|91.64 fps|52.55 fps|39.45 fps||
|4x (2x_Compact+2x_SuperUltraCompact)|126.76 fps|69.07 fps|50.86 fps||
|4x (2x_UltraCompact+2x_SuperUltraCompact)|137.49 fps|75.89 fps|55.88 fps||
|4x (2x_UltraCompact+2x_UltraCompact)|96.90 fps|56.12 fps|42.55 fps|29.05 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|147.96 fps|80.79 fps|60.88 fps|40.53 fps|

### RTX 4090 + i7-9700K Num-Threads 4 + FP32 ([422415](https://github.com/422415))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|363.73 fps|209.92 fps|131.71 fps|66.10 fps|30.05 fps
|2x (2x_UltraCompact)|496.65 fps|288.08 fps|188.55 fps|91.72 fps|41.59 fps
|2x (2x_SuperUltraCompact)|676.13 fps|400.41 fps|280.93 fps|132.89 fps|58.24 fps
|4x (2x_Compact+2x_Compact)|69.43 fps|40.16 fps|30.36 fps|20.54 fps|
|4x (2x_Compact+2x_UltraCompact)|93.47 fps|53.74 fps|39.92 fps||
|4x (2x_Compact+2x_SuperUltraCompact)|129.84 fps|71.39 fps|51.27 fps||
|4x (2x_UltraCompact+2x_SuperUltraCompact)|141.90 fps|76.89 fps|56.96 fps||
|4x (2x_UltraCompact+2x_UltraCompact)|99.58 fps|56.75 fps|43.84 fps|29.76 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|150.43 fps|83.32 fps|61.41 fps|40.36 fps|

### RTX 4090 + i7-9700K Num-Threads 8 + FP16 ([422415](https://github.com/422415))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|432.75 fps|250.77 fps|153.95 fps|77.86 fps|35.69 fps
|2x (2x_UltraCompact)|665.83 fps|388.09 fps|247.28 fps|123.18 fps|56.59 fps
|2x (2x_SuperUltraCompact)|1082.45 fps|674.03 fps|482.36 fps|223.78 fps|97.53 fps
|4x (2x_Compact+2x_Compact)|82.44 fps|47.87 fps|35.96 fps|24.01 fps|
|4x (2x_Compact+2x_UltraCompact)|119.16 fps|68.79 fps|50.53 fps||
|4x (2x_Compact+2x_SuperUltraCompact)|190.47 fps|102.23 fps|71.82 fps||
|4x (2x_UltraCompact+2x_SuperUltraCompact)|220.47 fps|116.64 fps|86.61 fps||
|4x (2x_UltraCompact+2x_UltraCompact)|131.07 fps|75.32 fps|57.57 fps|39.00 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|256.33 fps|132.99 fps|102.68 fps|66.93 fps|

### RTX 4090 + i7-9700K Num-Threads 4 + FP16 ([422415](https://github.com/422415))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|442.10 fps|250.38 fps|154.00 fps|78.06 fps|35.75 fps
|2x (2x_UltraCompact)|669.76 fps|388.97 fps|246.61 fps|123.01 fps|56.63 fps
|2x (2x_SuperUltraCompact)|1104.46 fps|664.93 fps|460.40 fps|217.16 fps|96.76 fps
|4x (2x_Compact+2x_Compact)|82.33 fps|47.91 fps|35.96 fps|24.25 fps|
|4x (2x_Compact+2x_UltraCompact)|119.23 fps|68.80 fps|50.57 fps||
|4x (2x_Compact+2x_SuperUltraCompact)|192.09 fps|103.37 fps|71.16 fps||
|4x (2x_UltraCompact+2x_SuperUltraCompact)|222.64 fps|117.66 fps|86.24 fps||
|4x (2x_UltraCompact+2x_UltraCompact)|132.32 fps|75.98 fps|57.65 fps|39.02 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|251.84 fps|131.50 fps|96.63 fps|67.26 fps|

### RTX 4090 + i9-13900K (RIFE enabled on all benchmarks)

||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|126.49 fps|94.16 fps|62.99 fps|33.13 fps|19.48 fps
|2x (2x_UltraCompact)|82.62 fps|67.96 fps|70.41 fps|34.92 fps|21.88 fps
|2x (2x_SuperUltraCompact)|85.34 fps|77.13 fps|77.13 fps|36.83 fps|25.22 fps
|4x (2x_Compact+2x_Compact)|42.16 fps|24.60 fps|19.85 fps|16.97 fps|
|4x (2x_Compact+2x_UltraCompact)|48.46 fps|31.02 fps|24.39 fps|21.04 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|52.11 fps|33.77 fps|27.26 fps|21.94 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|52.35 fps|34.94 fps|27.57 fps|23.87 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|48.27 fps|32.02 fps|26.21 fps|21.01 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|49.37 fps|36.42 fps|30.38 fps|23.10 fps|

## RTX 4080 Super
### RTX 4080s + 7800x3D Default settings
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|344.05 fps|188.20 fps|127.98 fps|63.29 fps|28.26 fps
|2x (2x_UltraCompact)|601.29 fps|331.92 fps|225.71 fps|111.43 fps|49.60 fps
|2x (2x_SuperUltraCompact)|1307.96 fps|819.30 fps|578.00 fps|253.84 fps|112.08 fps
|4x (2x_Compact+2x_Compact)|67.21 fps|37.98 fps|29.17 fps|19.50 fps|
|4x (2x_Compact+2x_UltraCompact)|103.35 fps|57.95 fps|43.84 fps|27.85 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|182.75 fps|95.84 fps|70.34 fps|40.93 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|233.94 fps|121.79 fps|90.94 fps|56.75 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|118.50 fps|66.93 fps|51.33 fps|34.42 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|293.20 fps|154.73 fps|104.10 fps|77.79 fps|


## RTX 4080
### 7950x(No PBO) + 5600Mhz DDR5(2x) + RTX4080 ([hooke007](https://github.com/hooke007))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|345.79 fps|167.99 fps|126.77 fps|62.67 fps|27.93 fps
|2x (2x_UltraCompact)|671.05 fps|323.08 fps|242.30 fps|117.99 fps|52.73 fps
|2x (2x_SuperUltraCompact)|1840.96 fps|827.06 fps|571.67 fps|275.27 fps|118.53 fps
|4x (2x_Compact+2x_Compact)|66.89 fps|37.35 fps|28.49 fps|19.40 fps|
|4x (2x_Compact+2x_UltraCompact)|107.56 fps|57.28 fps|45.09 fps|28.78 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|203.77 fps|102.28 fps|77.05 fps|43.98 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|283.85 fps|144.57 fps|104.65 fps|65.30 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|126.33 fps|70.66 fps|54.11 fps|36.45 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|308.08 fps|174.35 fps|119.94 fps|85.43 fps|

## RTX 4070 S
### RTX 4070 S + 14600K
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|224.38 fps|122.38 fps|85.67 fps|41.23 fps|18.15 fps
|2x (2x_UltraCompact)|462.06 fps|234.87 fps|164.31 fps|79.69 fps|35.22 fps
|2x (2x_SuperUltraCompact)|1131.36 fps|652.85 fps|457.58 fps|185.18 fps|83.86 fps
|4x (2x_Compact+2x_Compact)|44.30 fps|24.62 fps|18.87 fps|12.63 fps|
|4x (2x_Compact+2x_UltraCompact)|72.88 fps|40.56 fps|30.46 fps|19.08 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|120.60 fps|67.76 fps|49.41 fps|27.65 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|164.86 fps|89.26 fps|67.43 fps|40.73 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|86.55 fps|47.72 fps|36.63 fps|24.40 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|207.87 fps|117.33 fps|90.60 fps|56.48 fps|

## RTX 4070 Ti Super
### RTX 4070 Ti Super + Ryzen 5 5600X
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|265.13 fps|143.37 fps|101.76 fps|49.04 fps|21.44 fps
|2x (2x_UltraCompact)|458.24 fps|246.86 fps|176.18 fps|85.71 fps|37.54 fps
|2x (2x_SuperUltraCompact)|961.73 fps|461.91 fps|368.08 fps|175.14 fps|82.11 fps
|4x (2x_Compact+2x_Compact)|52.61 fps|29.34 fps|22.27 fps|15.06 fps|
|4x (2x_Compact+2x_UltraCompact)|79.67 fps|44.41 fps|34.02 fps|21.44 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|131.53 fps|71.82 fps|54.71 fps|31.46 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|161.68 fps|91.22 fps|67.57 fps|43.09 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|91.21 fps|51.21 fps|39.28 fps|26.27 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|189.66 fps|104.48 fps|86.61 fps|57.51 fps|

## RTX 4070 Ti
### RTX 4070 TI (OC) + Ryzen 7 5800X3D (4.45 Ghz) + DDR4 64 GB 3466 Mhz [Bradjy]
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|243.36 fps|127.73 fps|93.65 fps|44.81 fps|20.03 fps|
|2x (2x_UltraCompact)|426.74 fps|230.40 fps|165.69 fps|80.44 fps|35.88 fps|
|2x (2x_SuperUltraCompact)|1000.54 fps|578.72 fps|413.83 fps|175.42 fps|79.70 fps|
|4x (2x_Compact+2x_Compact)|48.61 fps|27.25 fps|20.46 fps|13.27 fps|
|4x (2x_Compact+2x_UltraCompact)|74.98 fps|41.57 fps|31.55 fps|19.82 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|123.06 fps|67.31 fps|50.27 fps|28.83 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|155.62 fps|85.40 fps|65.57 fps|39.39 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|85.88 fps|47.41 fps|37.21 fps|24.16 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|194.41 fps|109.12 fps|85.32 fps|52.93 fps|

### RTX 4070 TI + Ryzen 5 5600G ([animeojisan](https://github.com/animeojisan))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|254.65 fps|132.56 fps|93.55 fps|45.74 fps|20.27 fps
|2x (2x_UltraCompact)|485.64 fps|226.51 fps|160.02 fps|77.83 fps|34.48 fps
|2x (2x_SuperUltraCompact)|557.97 fps|326.24 fps|229.27 fps|108.35 fps|48.22 fps
|4x (2x_Compact+2x_Compact)|49.13 fps|27.47 fps|20.98 fps|14.08 fps|
|4x (2x_Compact+2x_UltraCompact)|74.24 fps|42.19 fps|30.87 fps|19.68 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|92.84 fps|52.17 fps|38.13 fps|23.43 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|111.77 fps|59.93 fps|46.04 fps|29.86 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|85.29 fps|46.37 fps|35.81 fps|23.96 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|115.01 fps|65.29 fps|50.32 fps|33.36 fps|

## RTX 4070

### RTX 4070 + Ryzen 7600X + DDR5 6000 32GB [16GB x2] ([2ji3150](https://github.com/2ji3150))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|194.89 fps|112.17 fps|79.48 fps|38.79 fps|17.37 fps
|2x (2x_UltraCompact)|351.15 fps|203.09 fps|142.99 fps|70.19 fps|31.31 fps
|2x (2x_SuperUltraCompact)|1029.08 fps|578.28 fps|390.38 fps|184.16 fps|82.33 fps
|4x (2x_Compact+2x_Compact)|40.88 fps|23.03 fps|17.78 fps|12.01 fps|
|4x (2x_Compact+2x_UltraCompact)|64.34 fps|35.93 fps|27.24 fps|17.33 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|113.40 fps|62.65 fps|46.30 fps|26.62 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|145.68 fps|82.88 fps|62.46 fps|38.19 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|73.29 fps|41.88 fps|32.11 fps|21.65 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|199.30 fps|111.97 fps|84.69 fps|57.09 fps|

### RTX 4070 + Ryzen 7600X + DDR5 4800 32GB [16GB x2] ([2ji3150](https://github.com/2ji3150))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|194.74 fps|113.00 fps|79.40 fps|38.89 fps|17.38 fps
|2x (2x_UltraCompact)|352.50 fps|203.11 fps|143.33 fps|70.17 fps|31.27 fps
|2x (2x_SuperUltraCompact)|1039.98 fps|567.59 fps|381.56 fps|182.20 fps|81.67 fps
|4x (2x_Compact+2x_Compact)|40.91 fps|23.08 fps|17.77 fps|12.06 fps|
|4x (2x_Compact+2x_UltraCompact)|63.83 fps|35.94 fps|27.25 fps|17.39 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|111.77 fps|62.60 fps|46.39 fps|26.60 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|145.57 fps|82.61 fps|62.32 fps|38.14 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|73.43 fps|41.79 fps|32.09 fps|21.67 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|199.02 fps|112.66 fps|81.71 fps|56.47 fps|

### 4070 + i5-12400F (Aqua)
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|186.52 fps|108.00 fps|76.10 fps|37.13 fps|16.58 fps
|2x (2x_UltraCompact)|338.34 fps|194.87 fps|137.26 fps|66.93 fps|29.65 fps
|2x (2x_SuperUltraCompact)|573.97 fps|330.94 fps|224.17 fps|108.87 fps|49.13 fps
|4x (2x_Compact+2x_Compact)|38.82 fps|22.00 fps|16.91 fps|11.46 fps|
|4x (2x_Compact+2x_UltraCompact)|60.42 fps|34.03 fps|25.93 fps|16.57 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|83.42 fps|47.35 fps|35.28 fps|21.21 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|103.59 fps|58.59 fps|44.57 fps|28.48 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|69.88 fps|39.64 fps|30.28 fps|20.46 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|118.46 fps|66.96 fps|51.20 fps|34.35 fps|

## RTX 4060 Ti
### RTX 4060 Ti 16 GB + i5-9600K ([uwi](https://github.com/uwidev))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|137.22 fps|76.94 fps|55.61 fps|24.16 fps|11.27 fps
|2x (2x_UltraCompact)|238.78 fps|144.93 fps|105.16 fps|49.27 fps|21.06 fps
|2x (2x_SuperUltraCompact)|827.09 fps|523.48 fps|247.01 fps|118.45 fps|51.22 fps
|4x (2x_Compact+2x_Compact)|26.44 fps|16.13 fps|12.11 fps|8.00 fps|
|4x (2x_Compact+2x_UltraCompact)|45.42 fps|25.23 fps|19.09 fps|11.52 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|77.36 fps|42.74 fps|32.34 fps|15.60 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|104.30 fps|59.85 fps|44.81 fps|25.01 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|50.06 fps|29.42 fps|23.08 fps|14.14 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|138.19 fps|77.91 fps|54.88 fps|34.58 fps|

### RTX 4060 Ti 16 GB + i9-11900K (anon)
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|130.98 fps|75.42 fps|52.69 fps|25.58 fps|11.43 fps
|2x (2x_UltraCompact)|236.94 fps|136.16 fps|94.28 fps|45.34 fps|20.29 fps
|2x (2x_SuperUltraCompact)|668.18 fps|384.37 fps|215.77 fps|103.02 fps|45.32 fps
|4x (2x_Compact+2x_Compact)|27.22 fps|15.33 fps|11.79 fps|7.93 fps|
|4x (2x_Compact+2x_UltraCompact)|42.70 fps|23.70 fps|17.85 fps|11.31 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|71.62 fps|38.91 fps|28.54 fps|16.51 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|87.43 fps|49.31 fps|37.29 fps|22.83 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|48.06 fps|27.09 fps|20.95 fps|13.98 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|114.84 fps|64.58 fps|47.89 fps|31.86 fps|

## RTX 3090
### RTX 3090 + 2700x (falaay)
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|223.53 fps|133.78 fps|96.09 fps|48.02 fps|21.77 fps
|2x (2x_UltraCompact)|360.01 fps|237.23 fps|168.04 fps|68.29 fps|34.70 fps
|2x (2x_SuperUltraCompact)|365.27 fps|243.29 fps|171.21 fps|72.50 fps|34.62 fps
|4x (2x_Compact+2x_Compact)|49.55 fps|28.58 fps|22.07 fps|15.02 fps|
|4x (2x_Compact+2x_UltraCompact)|77.32 fps|44.70 fps|33.96 fps|21.86 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|99.90 fps|54.13 fps|37.89 fps|25.31 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|101.93 fps|55.11 fps|38.72 fps|25.93 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|84.12 fps|45.97 fps|34.18 fps|25.07 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|103.17 fps|54.93 fps|38.73 fps|26.41 fps|

### RTX 3090 + i5-10600K (Alexandros)
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|220.83 fps|128.20 fps|89.94 fps|43.98 fps|19.48 fps
|2x (2x_UltraCompact)|344.86 fps|198.34 fps|139.28 fps|67.75 fps|30.21 fps
|2x (2x_SuperUltraCompact)|762.14 fps|453.02 fps|309.04 fps|148.95 fps|66.23 fps
|4x (2x_Compact+2x_Compact)|45.48 fps|25.44 fps|20.01 fps|13.91 fps|
|4x (2x_Compact+2x_UltraCompact)|63.66 fps|35.66 fps|26.90 fps|17.52 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|103.92 fps|59.88 fps|43.81 fps|25.81 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|125.16 fps|70.60 fps|54.67 fps|33.44 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|69.59 fps|38.77 fps|31.10 fps|20.93 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|148.91 fps|82.52 fps|61.58 fps|47.25 fps|

## RTX 3080 TI
### RTX 3080TI + i5 12400F + 32GB DDR4 3200MHz RAM (2 x 16GB) Singal Channel ([Natsu-raw](https://github.com/Natsu-raw))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|179.73 fps|104.54 fps|72.88 fps|36.29 fps|16.32 fps
|2x (2x_UltraCompact)|400.45 fps|234.50 fps|165.28 fps|81.95 fps|36.84 fps
|2x (2x_SuperUltraCompact)|740.92 fps|420.34 fps|308.16 fps|126.40 fps|58.25 fps
|4x (2x_Compact+2x_Compact)|37.46 fps|21.46 fps|16.53 fps|11.48 fps|
|4x (2x_Compact+2x_UltraCompact)|67.09 fps|38.51 fps|28.97 fps|18.43 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|102.83 fps|59.91 fps|43.88 fps|25.51 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|146.34 fps|85.95 fps|63.11 fps|41.50 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|84.67 fps|48.65 fps|37.35 fps|25.42 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|153.04 fps|86.63 fps|61.51 fps|43.30 fps|

## RTX 3080 
### RTX 3080 + i7-6700K + Num-Threads 4 + FP32 ([422415](https://github.com/422415))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|197.20 fps|120.57 fps|86.23 fps|43.79 fps|19.81 fps
|2x (2x_UltraCompact)|366.68 fps|222.43 fps|160.95 fps|79.56 fps|35.76 fps
|2x (2x_SuperUltraCompact)|460.61 fps|261.07 fps|182.52 fps|85.01 fps|38.47 fps
|4x (2x_Compact+2x_Compact)|44.51 fps|25.91 fps|20.00 fps|13.45 fps|
|4x (2x_Compact+2x_UltraCompact)|68.57 fps|40.11 fps|30.35 fps||
|4x (2x_Compact+2x_SuperUltraCompact)|110.62 fps|60.09 fps|40.81 fps||
|4x (2x_UltraCompact+2x_SuperUltraCompact)|109.75 fps|60.37 fps|40.25 fps||
|4x (2x_UltraCompact+2x_UltraCompact)|81.34 fps|47.08 fps|36.31 fps|24.63 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|111.30 fps|60.45 fps|40.02 fps|27.72 fps|

### RTX 3080 + i7-6700K + Num-Threads 4 + FP16 ([422415](https://github.com/422415))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|203.87 fps|123.46 fps|88.21 fps|44.56 fps|19.97 fps
|2x (2x_UltraCompact)|377.61 fps|228.41 fps|163.00 fps|81.98 fps|36.81 fps
|2x (2x_SuperUltraCompact)|745.08 fps|337.44 fps|313.44 fps|135.88 fps|64.91 fps
|4x (2x_Compact+2x_Compact)|45.25 fps|26.29 fps|20.22 fps|13.74 fps|
|4x (2x_Compact+2x_UltraCompact)|70.38 fps|41.14 fps|31.35 fps||
|4x (2x_Compact+2x_SuperUltraCompact)|124.56 fps|73.80 fps|54.67 fps||
|4x (2x_UltraCompact+2x_SuperUltraCompact)|171.84 fps|98.77 fps|68.80 fps||
|4x (2x_UltraCompact+2x_UltraCompact)|83.79 fps|48.48 fps|37.41 fps|25.58 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|184.14 fps|98.06 fps|69.14 fps|44.88 fps|

### RTX 3080 + i7-6700K + Num-Threads 8 + FP16 ([422415](https://github.com/422415))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|203.14 fps|123.13 fps|88.06 fps|43.76 fps|19.75 fps
|2x (2x_UltraCompact)|375.57 fps|227.78 fps|162.77 fps|81.00 fps|36.35 fps
|2x (2x_SuperUltraCompact)|727.48 fps|454.51 fps|318.00 fps|137.94 fps|57.49 fps
|4x (2x_Compact+2x_Compact)|45.13 fps|25.93 fps|20.27 fps|13.64 fps|
|4x (2x_Compact+2x_UltraCompact)|70.20 fps|40.79 fps|31.34 fps||
|4x (2x_Compact+2x_SuperUltraCompact)|123.13 fps|73.68 fps|54.79 fps||
|4x (2x_UltraCompact+2x_SuperUltraCompact)|172.72 fps|100.97 fps|75.63 fps||
|4x (2x_UltraCompact+2x_UltraCompact)|83.53 fps|48.41 fps|37.29 fps|25.00 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|197.31 fps|111.17 fps|76.90 fps|49.55 fps|

### RTX 3080 12G + i5 12600k + 16GB DDR4 3600MHz RAM (2 x 8GB) ([Galahahad](https://github.com/Galahahad))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|240.89 fps|143.15 fps|101.94 fps|51.05 fps|23.06 fps
|2x (2x_UltraCompact)|404.59 fps|239.46 fps|169.87 fps|84.12 fps|38.05 fps
|2x (2x_SuperUltraCompact)|896.09 fps|536.44 fps|391.25 fps|194.05 fps|88.24 fps
|4x (2x_Compact+2x_Compact)|52.35 fps|30.23 fps|23.31 fps|16.03 fps|
|4x (2x_Compact+2x_UltraCompact)|76.19 fps|44.05 fps|33.60 fps|21.82 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|124.32 fps|72.34 fps|54.23 fps|32.39 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|156.80 fps|90.88 fps|68.65 fps|42.78 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|87.26 fps|50.18 fps|38.78 fps|26.20 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|198.58 fps|115.12 fps|88.64 fps|60.41 fps|


## RTX 3070 Ti
### RTX 3070 Ti + Intel Core i5 12700 ([er-chisus](https://github.com/er-chisus))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|170.94 fps|102.74 fps|72.59 fps|35.80 fps|16.02 fps
|2x (2x_UltraCompact)|303.71 fps|182.60 fps|129.40 fps|63.93 fps|28.63 fps
|2x (2x_SuperUltraCompact)|691.69 fps|416.67 fps|300.67 fps|151.51 fps|68.41 fps
|4x (2x_Compact+2x_Compact)|37.68 fps|21.44 fps|16.45 fps|10.78 fps|
|4x (2x_Compact+2x_UltraCompact)|57.42 fps|32.90 fps|24.98 fps|15.81 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|94.72 fps|54.84 fps|40.68 fps|23.65 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|121.63 fps|70.98 fps|53.86 fps|33.33 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|66.10 fps|38.05 fps|29.50 fps|19.80 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|157.87 fps|90.73 fps|70.40 fps|47.79 fps|

### RTX 3070 Ti + AMD Ryzen 5900x ([aloola18](https://github.com/aloola18))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|140.33 fps|85.47 fps|60.30 fps|30.65 fps|14.03 fps
|2x (2x_UltraCompact)|305.31 fps|178.45 fps|124.26 fps|60.81 fps|27.65 fps
|2x (2x_SuperUltraCompact)|636.56 fps|381.95 fps|270.20 fps|131.79 fps|60.93 fps
|4x (2x_Compact+2x_Compact)|30.81 fps|18.19 fps|14.28 fps|9.54 fps|
|4x (2x_Compact+2x_UltraCompact)|52.22 fps|30.23 fps|22.89 fps|14.68 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|78.68 fps|46.50 fps|34.55 fps|20.25 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|112.17 fps|65.34 fps|48.77 fps|30.38 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|63.72 fps|36.20 fps|28.04 fps|19.09 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|138.84 fps|80.42 fps|62.47 fps|41.40 fps|

### RTX 3070 Ti + Ryzen 5 5600 ([RoyalQX](https://github.com/RoyalQX))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|162.49 fps|93.22 fps|67.31 fps|31.57 fps|15.65 fps
|2x (2x_UltraCompact)|268.58 fps|154.91 fps|114.24 fps|56.12 fps|26.06 fps
|2x (2x_SuperUltraCompact)|767.37 fps|466.46 fps|332.67 fps|166.33 fps|73.36 fps
|4x (2x_Compact+2x_Compact)|33.07 fps|19.38 fps|14.98 fps|10.69 fps|
|4x (2x_Compact+2x_UltraCompact)|49.38 fps|28.82 fps|21.96 fps|14.71 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|89.62 fps|52.06 fps|39.69 fps|22.47 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|124.33 fps|71.56 fps|53.17 fps|31.90 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|57.46 fps|33.26 fps|25.48 fps|17.73 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|159.57 fps|93.78 fps|75.79 fps|51.99 fps|

## RTX 3070
### RTX 3070 + AMD 5900x ([422415](https://github.com/422415))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|139.25 fps|89.38 fps|62.93 fps|29.90 fps|13.74 fps
|2x (2x_UltraCompact)|248.92 fps|156.68 fps|107.28 fps|54.16 fps|24.09 fps
|2x (2x_SuperUltraCompact)|560.32 fps|349.12 fps|244.51 fps|121.76 fps|52.65 fps
|4x (2x_Compact+2x_Compact)|31.54 fps|18.13 fps|14.02 fps|9.28 fps|
|4x (2x_Compact+2x_UltraCompact)|46.54 fps|27.36 fps|20.80 fps||
|4x (2x_Compact+2x_SuperUltraCompact)|77.45 fps|45.35 fps|33.96 fps||
|4x (2x_UltraCompact+2x_SuperUltraCompact)|98.19 fps|56.60 fps|44.58 fps||
|4x (2x_UltraCompact+2x_UltraCompact)|55.85 fps|32.18 fps|23.96 fps|16.28 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|120.56 fps|73.30 fps|54.45 fps|37.07 fps|

### RTX 3070 + Intel Core i9-10850K ([TheAlpha31](https://github.com/TheAlpha31))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|136.80 fps|78.98 fps|56.11 fps|28.08 fps|13.48 fps
|2x (2x_UltraCompact)|234.61 fps|135.76 fps|96.44 fps|47.90 fps|22.87 fps
|2x (2x_SuperUltraCompact)|410.75 fps|240.76 fps|170.69 fps|82.14 fps|38.00 fps
|4x (2x_Compact+2x_Compact)|29.71 fps|17.14 fps|13.22 fps|9.15 fps|
|4x (2x_Compact+2x_UltraCompact)|45.62 fps|25.68 fps|19.40 fps|12.61 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|63.63 fps|36.12 fps|26.68 fps|16.06 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|75.94 fps|43.68 fps|33.67 fps|20.94 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|49.98 fps|28.98 fps|23.02 fps|15.41 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|87.95 fps|50.72 fps|39.23 fps|25.89 fps|

## RTX 3060TI (GDDR6)
### RTX 3060TI + Ryzen 7600X ([2ji3150](https://github.com/2ji3150))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|121.53 fps|69.76 fps|49.06 fps|24.83 fps|11.25 fps
|2x (2x_UltraCompact)|212.98 fps|121.81 fps|86.01 fps|43.06 fps|19.70 fps
|2x (2x_SuperUltraCompact)|623.28 fps|365.39 fps|261.32 fps|130.84 fps|59.02 fps
|4x (2x_Compact+2x_Compact)|25.60 fps|14.83 fps|11.31 fps|7.78 fps|
|4x (2x_Compact+2x_UltraCompact)|39.22 fps|22.58 fps|16.97 fps|10.99 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|73.67 fps|41.77 fps|30.04 fps|17.44 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|97.37 fps|54.67 fps|40.71 fps|24.80 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|45.11 fps|25.85 fps|19.91 fps|13.45 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|135.23 fps|77.00 fps|59.65 fps|40.17 fps|


## RTX 3060
### RTX 3060 12GB + Ryzen 5 5600X with PBO enabled + 32GB DDR4 3200Mhz Ram (4x8GB) ([Kimi0n](https://github.com/Kimi0n))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|113.86 fps|66.14 fps|46.68 fps|20.60 fps|9.27 fps
|2x (2x_UltraCompact)|211.46 fps|123.16 fps|86.52 fps|37.88 fps|18.28 fps
|2x (2x_SuperUltraCompact)|628.99 fps|367.28 fps|260.99 fps|110.11 fps|57.36 fps
|4x (2x_Compact+2x_Compact)|23.78 fps|13.55 fps|10.44 fps|6.89 fps|
|4x (2x_Compact+2x_UltraCompact)|37.52 fps|21.42 fps|16.23 fps|9.97 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|67.93 fps|39.39 fps|28.96 fps|15.65 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|93.88 fps|53.87 fps|40.53 fps|23.68 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|44.14 fps|25.23 fps|19.40 fps|11.77 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|133.48 fps|76.20 fps|59.18 fps|33.98 fps|

### RTX 3060 12GB + intel 13400F + 32GB DDR4 3200Mhz Ram (2x16GB)
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|104.04 fps|61.13 fps|43.44 fps|21.41 fps|9.62 fps
|2x (2x_UltraCompact)|189.66 fps|111.55 fps|79.27 fps|39.05 fps|17.52 fps
|2x (2x_SuperUltraCompact)|510.41 fps|299.79 fps|214.32 fps|105.31 fps|47.14 fps
|4x (2x_Compact+2x_Compact)|22.48 fps|12.82 fps|9.85 fps|6.65 fps|
|4x (2x_Compact+2x_UltraCompact)|34.91 fps|20.00 fps|15.19 fps|9.68 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|60.88 fps|34.80 fps|25.91 fps|14.82 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|82.27 fps|46.80 fps|35.37 fps|21.48 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|41.12 fps|23.32 fps|17.95 fps|12.15 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|111.01 fps|63.56 fps|49.14 fps|33.01 fps|

### RTX 3060 + Intel 8700k
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|89.36 fps|50.53 fps|36.01 fps|17.76 fps|7.67 fps
|2x (2x_UltraCompact)|149.25 fps|89.71 fps|57.02 fps|31.22 fps|13.78 fps
|2x (2x_SuperUltraCompact)|420.96 fps|252.63 fps|163.89 fps|83.55 fps|39.14 fps
|4x (2x_Compact+2x_Compact)|18.52 fps|10.50 fps|8.15 fps|5.24 fps|
|4x (2x_Compact+2x_UltraCompact)|28.11 fps|16.10 fps|12.28 fps|7.16 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|53.24 fps|29.03 fps|21.58 fps|12.27 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|64.59 fps|37.78 fps|26.14 fps|17.55 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|32.21 fps|18.29 fps|14.46 fps|9.69 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|93.40 fps|53.51 fps|37.95 fps|27.50 fps|

### RTX 3060 + i3-10100 + 16gb ddr4 2400MHZ (2 x 8) ([waffle2022](https://github.com/waffle2022))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|94.73 fps|54.57 fps|38.14 fps|18.72 fps|8.31 fps
|2x (2x_UltraCompact)|185.62 fps|108.06 fps|75.90 fps|37.25 fps|16.60 fps
|2x (2x_SuperUltraCompact)|341.07 fps|199.07 fps|140.08 fps|68.12 fps|30.41 fps
|4x (2x_Compact+2x_Compact)|19.73 fps|11.09 fps|8.53 fps|5.82 fps|
|4x (2x_Compact+2x_UltraCompact)|33.19 fps|18.52 fps|13.96 fps|8.82 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|47.09 fps|26.86 fps|19.92 fps|11.73 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|61.51 fps|35.08 fps|26.64 fps|16.90 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|38.94 fps|22.16 fps|17.06 fps|11.47 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|72.37 fps|41.15 fps|31.73 fps|21.30 fps|


### RTX 3060 Laptop 6GB (105W) + Intel i5-10500H + 16GB DDR4 2933MHz RAM (2 x 8GB) ([AlteriaX](https://github.com/AlteriaX))

||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|107.59 fps|61.59 fps|42.79 fps|21.91 fps|9.60 fps
|2x (2x_UltraCompact)|177.20 fps|99.31 fps|68.37 fps|34.68 fps|15.43 fps
|2x (2x_SuperUltraCompact)|574.37 fps|331.01 fps|229.27 fps|113.49 fps|50.10 fps
|4x (2x_Compact+2x_Compact)|22.12 fps|12.71 fps|9.58 fps|6.81 fps|
|4x (2x_Compact+2x_UltraCompact)|31.51 fps|17.67 fps|13.36 fps|9.28 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|62.11 fps|35.11 fps|25.45 fps|15.49 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|80.94 fps|44.88 fps|32.93 fps|20.57 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|35.64 fps|19.85 fps|15.19 fps|10.90 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|118.80 fps|65.62 fps|50.30 fps|34.95 fps|

##  RTX 3050
### RTX 3050 8GB + Ryzen 5 5500 + 16GB DDR4 3200 mhz  RAM ([toprak](https://github.com/toprak))

||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|68.05 fps|40.40 fps|28.37 fps|13.79 fps|6.14 fps
|2x (2x_UltraCompact)|121.56 fps|72.05 fps|50.83 fps|24.63 fps|10.97 fps
|2x (2x_SuperUltraCompact)|318.75 fps|185.02 fps|130.79 fps|63.56 fps|28.49 fps
|4x (2x_Compact+2x_Compact)|14.60 fps|8.31 fps|6.35 fps|4.25 fps|
|4x (2x_Compact+2x_UltraCompact)|22.83 fps|12.81 fps|9.64 fps|6.11 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|39.62 fps|22.35 fps|16.25 fps|9.32 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|51.04 fps|29.40 fps|21.75 fps|13.25 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|26.23 fps|14.93 fps|11.33 fps|7.58 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|66.87 fps|38.05 fps|29.66 fps|19.67 fps|
### RTX 3050 Laptop 4GB (60W) + Ryzen 7 4800h + 16GB DDR4 3200MHz RAM (2 x 8GB) ([patrik](https://github.com/rvked)))

||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|52.73 fps|29.46 fps|21.05 fps|10.20 fps|4.60 fps
|2x (2x_UltraCompact)|94.09 fps|53.55 fps|37.52 fps|18.63 fps|8.36 fps
|2x (2x_SuperUltraCompact)|270.14 fps|156.22 fps|108.31 fps|52.46 fps|23.41 fps
|4x (2x_Compact+2x_Compact)|10.64 fps|6.13 fps|4.75 fps|3.21 fps|
|4x (2x_Compact+2x_UltraCompact)|16.74 fps|9.67 fps|7.31 fps|4.63 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|30.44 fps|17.15 fps|12.38 fps|7.10 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|40.96 fps|22.93 fps|16.98 fps|10.45 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|19.86 fps|11.16 fps|8.66 fps|5.79 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|55.49 fps|31.25 fps|24.04 fps|16.31 fps|

## RTX 2080 Ti
### RTX 2080 Ti + Ryzen 3950X + 32GB DDR4 3900MHz RAM (CPU + GPU + RAM OC) ([matikow2](https://github.com/matikow2))

||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|212.70 fps|122.94 fps|86.09 fps|42.07 fps|18.71 fps
|2x (2x_UltraCompact)|388.30 fps|225.93 fps|159.34 fps|77.43 fps|34.63 fps
|2x (2x_SuperUltraCompact)|902.74 fps|559.53 fps|409.15 fps|196.71 fps|97.86 fps
|4x (2x_Compact+2x_Compact)|43.37 fps|24.61 fps|19.34 fps|12.91 fps|
|4x (2x_Compact+2x_UltraCompact)|69.00 fps|38.08 fps|28.17 fps|17.75 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|121.81 fps|65.95 fps|46.92 fps|26.79 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|153.94 fps|88.77 fps|67.13 fps|39.86 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|75.22 fps|43.26 fps|33.62 fps|22.63 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|185.75 fps|110.17 fps|70.13 fps|58.49 fps|


##  RTX 2080
### RTX 2080 + Intel i7 9700k (Trnkers)

||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|130.21 fps|75.83 fps|53.20 fps|25.93 fps|11.58 fps
|2x (2x_UltraCompact)|244.37 fps|141.19 fps|97.41 fps|48.36 fps|21.50 fps
|2x (2x_SuperUltraCompact)|719.99 fps|337.46 fps|287.62 fps|147.99 fps|67.17 fps
|4x (2x_Compact+2x_Compact)|27.15 fps|15.46 fps|11.49 fps|8.11 fps|
|4x (2x_Compact+2x_UltraCompact)|42.92 fps|24.47 fps|18.10 fps|11.72 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|77.61 fps|45.29 fps|32.73 fps|18.74 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|109.22 fps|62.89 fps|46.26 fps|28.13 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|50.64 fps|28.81 fps|21.59 fps|14.86 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|145.41 fps|74.06 fps|66.80 fps|46.43 fps|

# Benchmark Results - AMD GPU
## RX 9070 XT
### RX 9070 XT Ti + Ryzen 9800X3D + 32GB DDR5 6000MHz RAM + v3.2.0 build + DirectML fp32 ([2ji3150](https://github.com/2ji3150)))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|326.57 fps|170.56 fps|119.47 fps|51.89 fps|22.01 fps
|2x (2x_UltraCompact)|479.77 fps|261.37 fps|178.37 fps|80.22 fps|34.32 fps
|2x (2x_SuperUltraCompact)|784.02 fps|440.96 fps|301.40 fps|138.88 fps|58.77 fps
|4x (2x_Compact+2x_Compact)|57.81 fps|30.46 fps|23.15 fps|15.28 fps|
|4x (2x_Compact+2x_UltraCompact)|83.46 fps|41.05 fps|33.86 fps|24.10 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|175.87 fps|95.11 fps|68.23 fps|29.96 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|177.83 fps|89.99 fps|59.98 fps|48.47 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|87.59 fps|45.42 fps|33.79 fps|23.45 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|168.92 fps|87.44 fps|63.28 fps|45.53 fps|

### RX 9070 XT Ti + Ryzen 9800X3D + 32GB DDR5 6000MHz RAM + v3.2.0 build + DirectML fp16 ([2ji3150](https://github.com/2ji3150)))
||480x360|640x480|768x576|1280x720|1920x1080|
|-|-|-|-|-|-|
|2x (2x_Compact)|350.31 fps|197.61 fps|132.44 fps|58.15 fps|24.66 fps
|2x (2x_UltraCompact)|594.37 fps|305.95 fps|216.39 fps|95.76 fps|40.71 fps
|2x (2x_SuperUltraCompact)|1085.87 fps|589.53 fps|418.41 fps|188.91 fps|77.94 fps
|4x (2x_Compact+2x_Compact)|58.05 fps|35.33 fps|26.50 fps|17.30 fps|
|4x (2x_Compact+2x_UltraCompact)|110.66 fps|52.11 fps|43.69 fps|25.73 fps|
|4x (2x_Compact+2x_SuperUltraCompact)|171.22 fps|107.55 fps|69.56 fps|35.95 fps|
|4x (2x_UltraCompact+2x_SuperUltraCompact)|230.56 fps|128.41 fps|98.39 fps|57.21 fps|
|4x (2x_UltraCompact+2x_UltraCompact)|101.06 fps|53.51 fps|43.60 fps|28.66 fps|
|4x (2x_SuperUltraCompact+2x_SuperUltraCompact)|255.63 fps|132.37 fps|98.74 fps|68.17 fps|
