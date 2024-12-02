#You can find the correct port just by opening up an example project in code composer studio
#and checking where the project is grabbing the freertos portable files from
set(PORT GCC/ARM_CM3)

#TODO: Add in symlink for windows.
if(${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Linux" OR ${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Darwin")
  #Set this to the install location of the SDK. It's best to install and compile the SDK using code composer studio first.
  set(SDK $ENV{HOME}/ti/simplelink_cc32xx_sdk_7_10_00_13)
  #Name of the link. A .link extension will be appended.
  set(SDK_LINK simplelink_cc32xx_sdk_7_10_00_13)
  #Set this to the location of the Code Composer Studio Project you want run. This CMake
  #file will automatically copy over any required files.
  set(CCS_PROJECT $ENV{HOME}/workspace_v12/buttonled_CC3220SF_LAUNCHXL_freertos_gcc)
  #Set this to the sysconfig version you want. For default projects there is usually a Debug and MCU+Image version.
  set(SYSCONFIG_TYPE Debug)

  #execute process runs prior to build system generation. add_custom_command runs during so it can't be used.
  #Creates a symlink to the SDK.
  execute_process(
  COMMAND
    rm -f ${SDK_LINK}
  COMMAND
    ln -T ${SDK} -s ${SDK_LINK}
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_LIST_DIR}
  COMMAND_ECHO
    STDOUT
  COMMAND_ERROR_IS_FATAL
      ANY
  )

  #There is no intermediate shell used for execute_process so special shell variables are not interpreted.
  #Everything is passed as an argument.
  file(GLOB linkerScript ${CCS_PROJECT}/*.lds)
  file(GLOB sysconfigFiles ${CCS_PROJECT}/${SYSCONFIG_TYPE}/syscfg/*[.hc])
  execute_process(
  COMMAND
    cp ${sysconfigFiles} ${CMAKE_CURRENT_LIST_DIR}/sysconfig
  COMMAND
    cp ${linkerScript} ${CMAKE_CURRENT_LIST_DIR}
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_LIST_DIR}
  COMMAND_ECHO
    STDOUT
  COMMAND_ERROR_IS_FATAL
    ANY
  )
else()
message(FATAL_ERROR "Only Linux or MacOS is supported")
endif()

add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/sysconfig)

target_include_directories(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PRIVATE
  ${CMAKE_CURRENT_LIST_DIR}/FreeRTOS/FreeRTOS/Source
  ${CMAKE_CURRENT_LIST_DIR}/FreeRTOS/FreeRTOS/Source/include
  ${CMAKE_CURRENT_LIST_DIR}/FreeRTOS/FreeRTOS/Source/portable/${PORT}
)

#Build the SDK using Code Composer Studio first. Don't want to build it here in case the
#build process changes and then we have to maintain it.
target_compile_options(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PRIVATE
  -L${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/source/ti/devices/cc32xx/driverlib/gcc/Release/
  -L${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/source/ti/drivers/lib/gcc/m4
  -L${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/source/ti/display/lib/gcc/m4
)
target_link_libraries(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PRIVATE
    #Required libraries can be found in the linker file generated by sysconfig.
    ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/source/ti/display/lib/gcc/m4/display_cc32xx.a
    ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/source/ti/drivers/lib/gcc/m4/drivers_cc32xx.a
    ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/source/ti/devices/cc32xx/driverlib/gcc/Release/driverlib.a
)

target_include_directories(${PROJECT_NAME}${EXECUTABLE_SUFFIX} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/kernel/freertos)
target_include_directories(${PROJECT_NAME}${EXECUTABLE_SUFFIX} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/source/)
target_include_directories(${PROJECT_NAME}${EXECUTABLE_SUFFIX} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/source/ti/posix/freertos)
target_include_directories(${PROJECT_NAME}${EXECUTABLE_SUFFIX} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/source/ti/drivers/)
target_include_directories(${PROJECT_NAME}${EXECUTABLE_SUFFIX} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/source/ti/posix/gcc)
target_compile_definitions(${PROJECT_NAME}${EXECUTABLE_SUFFIX} PRIVATE DeviceFamily_CC3220)

#This does not belong here. Should go in CMakeLists.txt
add_custom_command(TARGET ${PROJECT_NAME}${EXECUTABLE_SUFFIX} POST_BUILD
COMMAND
  ${CMAKE_OBJCOPY} ARGS -O binary ${CMAKE_SOURCE_DIR}/customToolchain_build/${PROJECT_NAME}${EXECUTABLE_SUFFIX} ${CMAKE_SOURCE_DIR}/customToolchain_build/${PROJECT_NAME}.bin
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_LIST_DIR}
  COMMENT
    "Stripping executable"
  VERBATIM
)
