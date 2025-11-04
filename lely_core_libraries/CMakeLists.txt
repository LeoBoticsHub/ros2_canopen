cmake_minimum_required(VERSION 3.8)
project(lely_core_libraries)

find_package(ament_cmake REQUIRED)
find_package(ament_cmake_python REQUIRED)
find_package(PkgConfig REQUIRED) # required to find lely-core libraries

# Find System-Installed Lely Libraries using pkg-config
# If the check passes, the libraries are found on the system
set(LELY_CORE_LIBRARIES
	liblely-can
	liblely-co
	liblely-coapp
	liblely-ev
	liblely-io2
	liblely-libc
	liblely-tap
	liblely-util
)
pkg_check_modules(LELY_CANOPEN REQUIRED ${LELY_CORE_LIBRARIES})

# Include the CMake extras file
set(lely_core_cmake_DIR ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
include("cmake/lely_core_libraries-extras.cmake" NO_POLICY_SCOPE)

# Install the CMake files for downstream packages
install(
    DIRECTORY cmake
    DESTINATION share/${PROJECT_NAME}
)

ament_python_install_package(cogen)

# install the entry-point script in lib directory for other packages to find
install(PROGRAMS
	cogen/cogen.py
	DESTINATION lib/${PROJECT_NAME}
)

# process the template file: replace @CMAKE_INSTALL_PREFIX@ with the correct path
configure_file(
    cmake/cogen_py_script_path.cmake.in
    "${CMAKE_CURRENT_BINARY_DIR}/cogen_py_script_path.cmake"
    @ONLY
)

# Export the required header directories and library names
ament_export_libraries(lely-can lely-co lely-coapp lely-ev lely-io2 lely-libc lely-tap lely-util)
ament_package(
    CONFIG_EXTRAS
    "cmake/lely_core_libraries-extras.cmake" # lely_core_libraries-extras: macros 
	"${CMAKE_CURRENT_BINARY_DIR}/cogen_py_script_path.cmake" # cogen_script_path
)
