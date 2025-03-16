#Add the sysconfig generated source files. These are set in ccsProject.cmake
target_sources(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PRIVATE
    ${sysconfigCSource}
    ${sysconfigCxxSource}
)

target_include_directories(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PUBLIC
  ${CMAKE_CURRENT_LIST_DIR}/FreeRTOS/FreeRTOS/Source/include
  ${CMAKE_CURRENT_LIST_DIR}/FreeRTOS/FreeRTOS/Source/portable/${PORT}
)

target_link_directories(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PUBLIC
    ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/source
)
#The order in which you link libraries matters!
target_link_libraries(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PUBLIC
    #These can't be relative are else cmake will try to look for libraries with the proper "lib" prefix.
    #e.g. It will try to look for libdriverlib.a and libti_utils_build_linker.cmd.genlibs
    ${CMAKE_CURRENT_LIST_DIR}/${CCS_PROJECT_LINK}/${SYSCONFIG_TYPE}/syscfg/ti_utils_build_linker.cmd.genlibs
    ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/source/ti/devices/cc32xx/driverlib/gcc/Release/driverlib.a
)

target_include_directories(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PUBLIC
    ${CMAKE_CURRENT_LIST_DIR}/${CCS_PROJECT_LINK}/${SYSCONFIG_TYPE}
    ${CMAKE_CURRENT_LIST_DIR}/${CCS_PROJECT_LINK}/${SYSCONFIG_TYPE}/syscfg
)

target_include_directories(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PUBLIC
    ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/source/
    ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/source/ti/posix/gcc
    ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/kernel/freertos
    ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/source/ti/posix/freertos
    ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/source/ti/drivers/
)

target_compile_definitions(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PUBLIC
    DeviceFamily_CC3220
    _REENT_SMALL
)