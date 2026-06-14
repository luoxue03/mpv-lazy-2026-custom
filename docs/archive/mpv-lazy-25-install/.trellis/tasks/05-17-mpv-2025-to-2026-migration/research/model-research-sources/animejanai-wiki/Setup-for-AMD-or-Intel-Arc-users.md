mpv-upscale-2x_animejanai is configured to use TensorRT by default for optimal performance, but TensorRT requires an NVIDIA GPU. Users with AMD or Intel Arc GPUs can use DirectML instead by following these steps: 

1. Download the [latest release](https://github.com/the-database/mpv-upscale-2x_animejanai/releases/latest) if you haven't already. 
1. Extract `mpv-upscale-2x_animejanai-full-package-3.1.0.7z` wherever you wish to run the program from.
2. In the `mpv-upscale-2x_animejanai-v3.1.0` folder, launch `mpvnet.exe`.
3. From the mpv.net window, press `ctrl+E` to launch AnimeJaNaiConfEditor. 
4. Choose the Global Settings tab on the top left, and then change the Upscaling Backend from TensorRT to DirectML.
![image](https://github.com/user-attachments/assets/b9563a29-9c49-4b6f-a643-a7ae91ec312f)
5. Select the profile that you want to run by default on the left panel. Most AMD / Intel Arc users will need to use the Performance profile, since DirectML isn't as fast as TensorRT. Check Set as Default Profile in mpv in order to load this profile by default when launching mpv. 
![image](https://github.com/user-attachments/assets/447c41e8-5405-41d8-933a-d15d2b1f7f16)
6. All changes are saved automatically. Exit AnimeJaNaiConfEditor, restart mpv.net, and play any video to test upscaling, which should be enabled by default. Press `ctrl+J` to check upscaling status and verify that an upscaling model is being applied. Press `ctrl+J` again to hide status. 