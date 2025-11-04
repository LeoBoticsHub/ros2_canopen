#   Copyright (c) 2023 Christoph Hellmann Santos
#                      Błażej Sowa
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

macro(generate_dcf YAML_PATH)

    # Extract path components
    get_filename_component(YAML_FILENAME ${YAML_PATH} NAME)
    get_filename_component(YAML_DIR ${YAML_PATH} DIRECTORY)
    get_filename_component(YAML_NAME_WE ${YAML_PATH} NAME_WE)
	
	# if file name = bus.yml, then log a warning message
	if(YAML_FILENAME STREQUAL "bus.yml")
		message(WARNING "The input YAML file is named 'bus.yml'. The utility generates an output file with the same name, so this may lead to overwriting the input file. Consider renaming the input YAML file.")
	endif()

    # Define Absolute Paths and Target Directories
    set(INPUT_YAML "${CMAKE_CURRENT_SOURCE_DIR}/${YAML_PATH}")
    set(BIN_OUTPUT_DIR "${CMAKE_BINARY_DIR}/${YAML_DIR}")
    set(BIN_FINAL_YAML "${BIN_OUTPUT_DIR}/bus.yml")
    set(INSTALL_CONFIG_PATH ${CMAKE_INSTALL_PREFIX}/share/${PROJECT_NAME}/${YAML_DIR})

    # Create a unique, deterministic target name
    string(REPLACE "/" "_" TARGET_PATH_FLAT "${YAML_DIR}")
    set(TARGET_NAME "generate_${TARGET_PATH_FLAT}_${YAML_NAME_WE}")

    # Define Custom Target
    add_custom_target(${TARGET_NAME} ALL
        # create bin output directory
        COMMAND mkdir -p "${BIN_OUTPUT_DIR}"

        # preprocess the YAML file: substitute @BUS_CONFIG_PATH@
        COMMAND sed 's|@BUS_CONFIG_PATH@|${INSTALL_CONFIG_PATH}|g' ${INPUT_YAML} > ${BIN_FINAL_YAML}

        # run dcfgen on the processed file
        COMMAND dcfgen -v -d "${BIN_OUTPUT_DIR}/" -rS "${BIN_FINAL_YAML}"

        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${YAML_DIR}"
        COMMENT "Generating DCF files for ${YAML_PATH}"
        DEPENDS "${INPUT_YAML}"
    )

	# install cmake bin output directory to share config directory
	install(DIRECTORY
		${BIN_OUTPUT_DIR}/
		DESTINATION share/${PROJECT_NAME}/${YAML_DIR}
	)
endmacro()

macro(cogen_dcf YAML_PATH)

    if(NOT COGEN_SCRIPT_PATH)
        message(FATAL_ERROR "Could not find COGEN_SCRIPT_PATH variable set by lely_core_libraries package")
    endif()

    find_program(PYTHON_EXECUTABLE python3 REQUIRED) # Find the Python interpreter

    # Extract path components
    get_filename_component(YAML_FILENAME ${YAML_PATH} NAME)
    get_filename_component(YAML_DIR ${YAML_PATH} DIRECTORY)
    get_filename_component(YAML_NAME_WE ${YAML_PATH} NAME_WE)

	# Sanity check: Warn if input YAML is named bus.yml
	if(YAML_FILENAME STREQUAL "bus.yml")
		message(WARNING "The input YAML file is named 'bus.yml'. The utility generates an output file with the same name, so this may lead to overwriting the input file. Consider renaming the input YAML file.")
	endif()

    # Define absolute paths
    set(INPUT_YAML ${CMAKE_CURRENT_SOURCE_DIR}/${YAML_PATH})
    set(BIN_OUTPUT_DIR ${CMAKE_BINARY_DIR}/${YAML_DIR})
	set(BIN_FINAL_YAML "${BIN_OUTPUT_DIR}/bus.yml")
    set(INSTALL_CONFIG_PATH ${CMAKE_INSTALL_PREFIX}/share/${PROJECT_NAME}/${YAML_DIR})
    set(TEMP_YAML_COGEN ${BIN_OUTPUT_DIR}/${YAML_NAME_WE}.cogen_temp.yml)
    set(TEMP_YAML_PROCESSED ${BIN_OUTPUT_DIR}/${YAML_NAME_WE}.processed.yml)

    # Create a unique, deterministic target name based on the path
    string(REPLACE "/" "_" TARGET_PATH_FLAT "${YAML_DIR}")
    set(TARGET_NAME "cogen_${TARGET_PATH_FLAT}_${YAML_NAME_WE}")

    message(STATUS "COGEN_SCRIPT_PATH = ${COGEN_SCRIPT_PATH}")

	# create custom target
	add_custom_target(${TARGET_NAME} ALL
		# create bin output directory
        COMMAND mkdir -p "${BIN_OUTPUT_DIR}"

        # run cogen on the original YAML file, writing to a temporary file
        COMMAND ${PYTHON_EXECUTABLE} ${COGEN_SCRIPT_PATH} --input-file ${INPUT_YAML} --output-file ${TEMP_YAML_COGEN}

        # preprocess the cogen output to substitute @BUS_CONFIG_PATH@, writing to final temp file
        COMMAND sed 's|@BUS_CONFIG_PATH@|${INSTALL_CONFIG_PATH}|g' ${TEMP_YAML_COGEN} > ${TEMP_YAML_PROCESSED}

        # run dcfgen on the processed file
        COMMAND dcfgen -v -d "${BIN_OUTPUT_DIR}/" -rS "${TEMP_YAML_PROCESSED}"

        # clean up temporary files
        COMMAND rm -f "${TEMP_YAML_COGEN}" "${TEMP_YAML_PROCESSED}"

        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${YAML_DIR}"
        COMMENT "Generating DCF files using cogen for ${YAML_PATH}"
        DEPENDS ${INPUT_YAML} # Dependency on the input YAML file
    )
endmacro()
