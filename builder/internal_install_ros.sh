#!/bin/bash

# Install ROS and supplemental stuff
set -e

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

# shellcheck source=lib/logging.bash
source "${SCRIPT_DIR}/lib/logging.bash"

log_info "Installing gnupg2 to allow key fetching"

apt update
apt install -y gnupg2

log_info "Adding ROS repository"

echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list

log_info "Receiving ROS repository key"

apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

log_info "Installing base ROS packages"

apt update
apt install -y \
  build-essential \
  ros-noetic-ros-base \
  python3-rosdep \
  python3-rosinstall \
  python3-rosinstall-generator \
  python3-wstool

log_info "Initializing rosdep"

rosdep init
