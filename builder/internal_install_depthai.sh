#!/bin/bash

# Script adapted from https://docs.luxonis.com/en/latest/_static/install_dependencies.sh
# (the official docs suggest piping it from a curl output to a bash shell, which I'm not
# very comfortable with. Bonus points for the docs using http instead of https)

#!/bin/bash
#
#   Luxonis DepthAI dependency install script
#

set -e


SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

# shellcheck source=lib/logging.bash
source "${SCRIPT_DIR}/lib/logging.bash"

readonly linux_pkgs=(
    python3
    python3-pip
# FIXME: "installing" (updating) udev seems to trigger update-initramfs,
# which fails in our chroot.
#    udev
    cmake
    git
    python3-numpy
)

readonly ubuntu_pkgs=(
    "${linux_pkgs[@]}"
    libusb-1.0-0-dev
    # https://docs.opencv.org/master/d7/d9f/tutorial_linux_install.html
    build-essential
    libgtk2.0-dev
    pkg-config
    libavcodec-dev
    libavformat-dev
    libswscale-dev
    python-dev
    libtbb2
    libtbb-dev
    libjpeg-dev
    libpng-dev
    libtiff-dev
    libdc1394-22-dev
    # https://stackoverflow.com/questions/55313610
    ffmpeg
    libsm6
    libxext6
    libgl1-mesa-glx
)

readonly ubuntu_arm_pkgs=(
    "${ubuntu_pkgs[@]}"
    # https://stackoverflow.com/a/53402396/5494277
    libhdf5-dev
    libhdf5-serial-dev
    libatlas-base-dev
    # https://github.com/EdjeElectronics/TensorFlow-Object-Detection-on-the-Raspberry-Pi/issues/18#issuecomment-433953426
    libilmbase-dev
    libopenexr-dev
    libgstreamer1.0-dev
)

log_info "Installing DepthAI dependencies"

apt-get update
apt-get install -y "${ubuntu_arm_pkgs[@]}"
python3 -m pip install --upgrade pip

# Allow all users to read and write to Myriad X devices
echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="03e7", MODE="0666"' | tee /etc/udev/rules.d/80-movidius.rules

# Install DepthAI Python libs
python3 -m pip install depthai
