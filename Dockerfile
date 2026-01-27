FROM ros:humble-ros-base-jammy

RUN sudo apt-get update && sudo apt-get upgrade -y
RUN sudo apt-get install -y software-properties-common
RUN sudo add-apt-repository universe
RUN sudo add-apt-repository ppa:lely/ppa

RUN apt-get update && apt-get install -y \
    python3-colcon-common-extensions \
    build-essential \
    liblely-coapp-dev \
    liblely-co-tools \
    liblely-tap-dev \
    python3-dcf-tools \
    pkg-config \
    can-utils \
    cmake \
    apt-utils

WORKDIR /home/can_ws/src
COPY . ros2_canopen

WORKDIR /home/can_ws/
RUN . /opt/ros/humble/setup.sh \
    && rosdep init && rosdep update \
    && rosdep install --from-paths src --ignore-src -r -y \
    && colcon build -DCMAKE_BUILD_TYPE=Release \
    && . install/setup.sh
