# DaVinci Video Converter (dvc) for Linux distros.

A bash script that uses ffmpeg to convert H.265 videos to MJPEG format that can be read by Davinci Resolve on Linux. This is a fork of [gohny's davinconv](https://github.com/gohny/davinconv) with added functionality such as the ability to choose where the files are going to be saved using a GUI (zenity).

TODO: check if user has ffmpeg installed, if not, install it.

## Installation
1. Clone this repository: `git clone https://github.com/FelipeFMA/dvc.git`
2. Change into the 'dvc' directory: `cd dvc`
3. Make the script executable: `chmod +x dvc.sh`
4. Run the script: `./dvc.sh`

## Usage
- To convert a single video to MJPEG format, use the `-c` option followed by the file path.
- To convert all videos in the current directory to MJPEG format, use the `-C` option.
- To export converted videos back to H264 format, use the `-e` option followed by the file path.
- To remove all converted videos stored in `$VIDDIR/converted`, use the `-R` option.

For more information and usage examples, refer to the `./dvc.sh -h` message within the script.
