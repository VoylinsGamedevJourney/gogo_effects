# GoGo Effects
![Godot v4.5.1+](https://img.shields.io/badge/Godot-v4.5.1%2B-478cbf?logo=godot-engine&logoColor=white)
![License](https://img.shields.io/badge/License-GPLv3-red)
![Status](https://img.shields.io/badge/Status-Beta-yellow)

**GoGo Effects** is a GDExtension for Godot 4.5+ that allows you to record and export videos of Godot projects to video files. The main use-case for this is to create animations or cutscenes. Exporting Godot projects to videos in a faster way compared to the build in way to create videos from inside Godot.

Powered by the core encoding engine of **[GoZen](https://github.com/VoylinsGamedevJourney/GoZen)** which utilizes FFmpeg.

## Installation & Downloads
### Pre-compiled binaries
To support development and save your time not having to compile GoGo Effects by yourself, you can get the pre-compiled GDExtension from following sources:
* **Ko-fi**: Coming soon!
* **Itch.io**: Coming soon!

### Building from source
GoGo Effects is open source, if you prefer to compile it yoursel you can:
_Build instructions coming soon_

## Usage
1. **Add the Node:** Add the `GoGoEffects` node to your scene;
2. **Configure the export settings:** Set your desired settings of how and where you want the encoded video to appear;
3. **Control via code:** Call the functions from your own scripts to handle recording, or use an animation player which calls the necessary functions and does your required animations.

The GoGoEffects node has documentation comments which can be read from inside of Godot when using the `F1` menu.

## ⚠️ Current limitations
* **Audio:** Currently GoGo Effects is video only. Audio recording is planned for a future release, but is undecided when at this point in time;
* **Formats:** There are some formats not supported, but if support is requested for a specific format you can let me know through creating an issue in this repo;
* **Platforms:** At this moment, Linux and Windows are the only platforms supported. MacOS support will come once I can get my hands on some Mac hardware and once I can figure out how to do it;

## License and credits
**GoGo Effects** is licensed under the **GPL v3** license. [Read more here.](./LICENSE)

FFmpeg is being used with the `--enable-gpl3` flag.
> This software uses libraries from the FFmpeg project under the LGPLv2.1 Other libraries used may come with their own specific licenses so be sure to check before forking the project and/or using code from this project to see if it can be used with your project license.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/voylin)
