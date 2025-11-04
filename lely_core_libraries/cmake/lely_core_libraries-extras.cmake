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
    get_filename_component(YAML_NAME_WE ${YAML_PATH} NAME_WE) # Name without extension
    
    # Define absolute paths
    set(INPUT_YAML ${CMAKE_CURRENT_SOURCE_DIR}/${YAML_PATH})
    set(OUTPUT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/${YAML_DIR}) # Output is placed next to the input YAML
    set(TEMP_YAML_PROCESSED ${OUTPUT_DIR}/${YAML_NAME_WE}.processed.yml)

    # Create a unique, deterministic target name based on the path
    string(REPLACE "/" "_" TARGET_PATH_FLAT "${YAML_DIR}")
    set(TARGET_NAME "generate_${TARGET_PATH_FLAT}_${YAML_NAME_WE}")
    
    # Define Custom Target
    add_custom_target(${TARGET_NAME} ALL
        # 1. Ensure output directory exists (idempotent)
        COMMAND mkdir -p ${OUTPUT_DIR}
        
        # 2. Preprocess the YAML file: substitute @BUS_CONFIG_PATH@, writing to a temporary file
        COMMAND sed 's|@BUS_CONFIG_PATH@|${OUTPUT_DIR}|g' ${INPUT_YAML} > ${TEMP_YAML_PROCESSED}
        
        # 3. Run dcfgen on the processed file. Output goes to OUTPUT_DIR
        COMMAND dcfgen -v -d ${OUTPUT_DIR}/ -rS ${TEMP_YAML_PROCESSED}
        
        # 4. Clean up temporary files
        COMMAND rm -f ${TEMP_YAML_PROCESSED}
        
        WORKING_DIRECTORY ${OUTPUT_DIR}
        COMMENT "Generating DCF files for ${YAML_PATH}"
        DEPENDS ${INPUT_YAML} # Dependency on the input YAML file
    )
endmacro()

macro(cogen_dcf YAML_PATH)

    if(NOT COGEN_SCRIPT_PATH)
        message(FATAL_ERROR "Could not find COGEN_SCRIPT_PATH variable set by cogen_tools package.")
    endif()

    find_program(PYTHON_EXECUTABLE python3 REQUIRED) # Find the Python interpreter

    # Extract path components
    get_filename_component(YAML_FILENAME ${YAML_PATH} NAME)
    get_filename_component(YAML_DIR ${YAML_PATH} DIRECTORY)
    get_filename_component(YAML_NAME_WE ${YAML_PATH} NAME_WE) # Name without extension
    
    # Define absolute paths
    set(INPUT_YAML ${CMAKE_CURRENT_SOURCE_DIR}/${YAML_PATH})
    set(OUTPUT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/${YAML_DIR}) # Output is placed next to the input YAML
    set(TEMP_YAML_COGEN ${OUTPUT_DIR}/${YAML_NAME_WE}.cogen_temp.yml)
    set(TEMP_YAML_PROCESSED ${OUTPUT_DIR}/${YAML_NAME_WE}.processed.yml)

    # Create a unique, deterministic target name based on the path
    string(REPLACE "/" "_" TARGET_PATH_FLAT "${YAML_DIR}")
    set(TARGET_NAME "cogen_${TARGET_PATH_FLAT}_${YAML_NAME_WE}")

    message(STATUS "COGEN_SCRIPT_PATH = ${COGEN_SCRIPT_PATH}")
    # Define Custom Target
    add_custom_target(${TARGET_NAME} ALL
        # 1. Ensure output directory exists (idempotent)
        COMMAND mkdir -p ${OUTPUT_DIR}

        # 2. Run cogen on the original YAML file, writing to a temporary file
        COMMAND ${PYTHON_EXECUTABLE} ${COGEN_SCRIPT_PATH} --input-file ${INPUT_YAML} --output-file ${TEMP_YAML_COGEN}

        # 3. Preprocess the cogen output to substitute @BUS_CONFIG_PATH@, writing to final temp file
        COMMAND sed 's|@BUS_CONFIG_PATH@|${OUTPUT_DIR}|g' "${TEMP_YAML_COGEN}" > "${TEMP_YAML_PROCESSED}"
        
        # 4. Run dcfgen on the processed file (Quoting dcfgen arguments)
        COMMAND dcfgen -v -d "${OUTPUT_DIR}/" -rS "${TEMP_YAML_PROCESSED}"
        
        # 5. Clean up temporary files (Use CMake -E remove -f for safety)
        COMMAND rm -f "${TEMP_YAML_COGEN}" "${TEMP_YAML_PROCESSED}"
        
        WORKING_DIRECTORY ${OUTPUT_DIR}
        COMMENT "Generating DCF files using cogen for ${YAML_PATH}"
        DEPENDS ${INPUT_YAML} # Dependency on the input YAML file
    )
endmacro()