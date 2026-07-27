# ROS2 CANopen

## Overview

This project provides a ROS2 stack for interfacing with CANopen devices. Specifically, it provides a ROS2 wrapper around the Lely CANopen library.
This stack enables communication with CANopen devices using different operation modes, such as service based, managed service based, and ros2_control based operation.
It allows control of CANopen devices such as motor drives, I/O modules, and sensors, and provides a flexible and modular architecture for integrating CANopen devices into ROS2-based robotic systems.

This repository is a fork of the original [ROS2-CANopen project](https://github.com/ros-industrial/ros2_canopen).
This modified version provides a few improvements on the usability and reliability of the original stack.
The master branch is compatible with ROS2 Humble distribution only.

## Installation

Install the CAN dependencies:
```bash
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:lely/ppa
sudo apt-get update
sudo apt-get install liblely-coapp-dev liblely-co-tools liblely-tap-dev python3-dcf-tools pkg-config can-utils
```

Clone the repository into your ROS2 workspace src folder:
```bash
cd ~/ros2_ws/src
git clone git@github.com:LeoBoticsHub/ros2_canopen.git
```

Build the workspace:
```bash
cd ~/ros2_ws
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release
```

***Note:** Master branch works with ROS2 **Humble** distributions.

## Status

| Build Process | Status |
|---------------|--------|
| Industrial CI Build | [![Industrial CI](https://github.com/LeoBoticsHub/ros2_canopen/actions/workflows/master.yml/badge.svg)](https://github.com/LeoBoticsHub/ros2_canopen/actions/workflows/master.yml) |
| Documentation Build | [![Documentation](https://github.com/LeoBoticsHub/ros2_canopen/actions/workflows/master_documentation.yml/badge.svg)](https://github.com/LeoBoticsHub/ros2_canopen/actions/workflows/master_documentation.yml) |


## Documentation

The documentation consists of two parts: a manual and an api reference.
The documentation is built for Humble (master branch) and hosted on github pages.

* Manual: [https://leoboticshub.github.io/ros2_canopen/](https://leoboticshub.github.io/ros2_canopen/)
* API reference: [https://leoboticshub.github.io/ros2_canopen/api/](https://leoboticshub.github.io/ros2_canopen/api)

## Features

These are some of the features this stack implements. For further information please refer to the documentation.

* **YAML-Bus configuration**
  This canopen stack enables you to configure the bus using a YAML file. In this file you define the nodes that are connected to the bus by specifying their node id, the corresponding EDS file and the driver to run for the node. You can also specify further parameters that overwrite EDS parameters or are inputs to the driver.
* **Service based operation**
  The stack can be operated using standard ROS2 nodes. In this case the device container will load the drivers for master and slave nodes. Each driver will be visible as a
  node and expose a ROS 2 interface. All drivers are brought up when the device manager is launched.
* **Managed service based operation**
  The stack can be operated using managed ROS2 nodes. In
  this case the device container will load the drivers for master and slave nodes based on the bus configuration. Each driver will be a lifecycle node and expose a ROS 2 interface. The lifecycle manager can be used to bring all
  device up and down in the correct sequence.
* **ROS2 control based operation**
  Currently, multiple ros2_control interfaces are available. These can be used for controlling CANopen devices. The interfaces are:
  * `canopen_ros2_control/CANopenSystem`
  * `canopen_ros2_control/CIA402System`
  * `canopen_ros2_control/RobotSystem`
* **CANopen drivers**
  Currently, the following drivers are available:
    * `ProxyDriver`
    * `Cia402Driver`

## Examples

In the `canopen_tests` package, you can find multiple examples that demonstrate how to use the stack in different ways.
Each `config` subfolder contains the bus configuration file in YAML format, and the corresponding electronic datasheets (EDS) for the nodes.

The launch files demonstrate how to launch the canopen ros2 driver depending on the type of operation to be performed, the type of canopen protocol, and the ros2 node type (lifecycle or standard). 
These are useful starting points for your own applications.

The `urdf` folder contains simple robot descriptions that can be used with the ros2_control examples. They are fundamental to
understand how to setup a robot relying on the ros2 canopen driver as hardware interface actuators using ros2_control.

## Testing

To test stack after it was built from source you should first setup a virtual can network.
```bash
sudo modprobe vcan
sudo ip link add dev vcan0 type vcan
sudo ip link set vcan0 txqueuelen 1000
sudo ip link set up vcan0
```

Then you can launch a managed example
```bash
ros2 launch canopen_tests cia402_lifecycle_setup.launch.py
ros2 lifecycle set /lifecycle_manager configure
ros2 lifecycle set /lifecycle_manager activate
```

Or you can launch a standard example
```bash
ros2 launch canopen_tests cia402_setup.launch.py
```

Or you can launch a ros2_control example
```bash
ros2 launch canopen_tests robot_control_setup.launch.py
```
