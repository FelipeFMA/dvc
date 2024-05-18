#! /bin/bash
# https://github.com/FelipeFMA/dvc
# A fork of gohny/davinconv

# A bash script to convert H.265 videos to MJPEG format that can be read by Davinci Resolve.


# Function to check if zenity is installed and install it if not
check_and_install_zenity() {
    if ! command -v zenity &> /dev/null; then
        echo "Zenity is not installed. Attempting to install..."

        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case "$ID" in
                ubuntu|debian)
                    sudo apt-get update && sudo apt-get install -y zenity
                    ;;
                fedora)
                    sudo dnf install -y zenity
                    ;;
                arch|manjaro)
                    sudo pacman -Sy --noconfirm zenity
                    ;;
                *)
                    echo "Unknown distribution. Please install Zenity manually."
                    exit 1
                    ;;
            esac
        else
	    echo "Zenity is required to run this script. Please install Zenity before proceeding."

            exit 1
        fi
    fi
}

check_and_install_zenity

USERNAME=$(whoami)
VIDDIR=$(zenity --file-selection --directory --title="Select the directory to save the videos" 2> /dev/null)

# Check if the user selected a directory
if [ -z "$VIDDIR" ]; then
    echo "No directory selected. Exiting..."
    exit 1
fi

WHEREAMI=$(pwd)

# Create necessary directories if they don't exist
if [ ! -d "$VIDDIR" ]; then
    mkdir -p "$VIDDIR"
    mkdir -p "$VIDDIR"/converted
    mkdir -p "$VIDDIR"/exported
else
    if [ ! -d "$VIDDIR"/converted ]; then
        mkdir -p "$VIDDIR"/converted
    fi
    if [ ! -d "$VIDDIR"/exported ]; then
        mkdir -p "$VIDDIR"/exported
    fi
fi

# Function to display help message
Help() {
    echo
    echo "Usage: $0 [-c|C|e|E|h|R]"
    echo
    echo "Options:"
    echo "   {-c} [file]    - Convert video to the MJPEG codec that can be read by Davinci Resolve."
    echo "   {-C}             - Convert all videos in current directory to the MJPEG codec that can be read by Davinci Resolve."
    echo "   {-e} [file]    - Export converted video back to the H264 codec."
    echo "   {-E}             - Export all converted videos stored in $VIDDIR/converted back to the H264 codec."
    echo "   {-h}             - Display this message."
    echo "   {-R}             - Remove all converted videos stored in $VIDDIR/converted."
    echo
    echo "All converted and exported videos are stored in: $VIDDIR"
    echo
    echo "https://github.com/FelipeFMA/dvc"
}

# Function to convert a single video to MJPEG
Convert() {
    ffmpeg -i "$i" -vcodec mjpeg -q:v 2 -acodec pcm_s16be -q:a 0 -f mov "$VIDDIR"/converted/${i%.*}.mov
}

# Function to convert all videos in the current directory to MJPEG
ConvertAll() {
    for i in *.mp4 *.mkv; do
        ffmpeg -i "$i" -vcodec mjpeg -q:v 2 -acodec pcm_s16be -q:a 0 -f mov "$VIDDIR"/converted/${i%.*}.mov
    done
}

# Function to export a single converted video back to H264
Export() {
    ffmpeg -i "$VIDDIR"/converted/"$i" -c:v libx264 -preset ultrafast -crf 0 "$VIDDIR"/exported/${i%.*}.mp4
}

# Function to export all converted videos back to H264
ExportAll() {
    cd "$VIDDIR"/converted
    for i in *.mov; do
        ffmpeg -i "$i" -c:v libx264 -preset ultrafast -crf 0 "$VIDDIR"/exported/${i%.*}.mp4
    done
    cd "$WHEREAMI"
}

# Function to remove all converted videos
RemoveAll() {
    while true; do
        echo "You are about to remove ALL converted videos stored in $VIDDIR/converted."
        read -p "Do you want to continue? (y/n) " yn
        case $yn in
            [yY] )
                echo
                echo "please wait..."
                echo
                sleep 1
                rm -rf "$VIDDIR"/converted/*
                break;;
            [nN] )
                echo "No changes have been made."
                exit;;
            * )
                echo "Error: please input y or n";;
        esac
    done
}

# Parse command line options
while getopts ":c:Ce:EhR" OPTION; do
    case $OPTION in
        c)
            i=${OPTARG}
            Convert
            exit;;
        C)
            ConvertAll
            exit;;
        e)
            i=${OPTARG}
            Export
            exit;;
        E)
            ExportAll
            exit;;
        h)
            Help
            exit;;
        R)
            RemoveAll
            exit;;
        *)
            echo "Error: Invalid option or argument not provided!"
            echo "For help use: $0 -h"
	    echo
            exit;;
    esac
done

Help
exit

