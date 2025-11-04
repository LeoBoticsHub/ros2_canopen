cmake_minimum_required(VERSION 3.8)
project(canopen_tests)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# find dependencies
find_package(ament_cmake REQUIRED)
find_package(lely_core_libraries REQUIRED)

# generate DCF files from YAML bus description files
generate_dcf("config/simple/bus.yaml")
generate_dcf("config/canopen_system/bus.yaml")
cogen_dcf("config/cia402_system/bus.yaml")
cogen_dcf("config/cia402_namespaced_system/bus.yaml")
cogen_dcf("config/cia402/bus.yaml")
generate_dcf("config/cia402_lifecycle/bus.yaml")
cogen_dcf("config/cia402_diagnostics/bus.yaml")
generate_dcf("config/simple_lifecycle/bus.yaml")
cogen_dcf("config/simple_diagnostics/bus.yaml")
generate_dcf("config/robot_control/bus.yaml")

# install manually also the config folder
install(DIRECTORY
  launch rviz urdf launch_tests config
  DESTINATION share/${PROJECT_NAME}
)

if(BUILD_TESTING)
  if(CANOPEN_ENABLED)
    find_package(launch_testing_ament_cmake REQUIRED)
    add_launch_test(launch_tests/test_proxy_driver.py)
    add_launch_test(launch_tests/test_proxy_lifecycle_driver.py)
  endif()
endif()

ament_package()
