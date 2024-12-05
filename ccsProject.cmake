#You can find the correct port just by opening up an example project in code composer studio
#and checking where the project is grabbing the freertos portable files from
set(PORT GCC/ARM_CM3)

#TODO: Add in symlink for windows.
if(${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Linux" OR ${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Darwin")
  #Set this to the install location of the SDK. It's best to install and compile the SDK using code composer studio first.
  set(SDK $ENV{HOME}/ti/simplelink_cc32xx_sdk_7_10_00_13)
  #Name of the link.
  set(SDK_LINK simplelink_cc32xx_sdk_7_10_00_13)
  #Set this to the location of the Code Composer Studio Project you want run. This CMake
  #file will automatically copy over any required files.
  set(CCS_PROJECT $ENV{HOME}/workspace_v12/out_of_box_CC3220SF_LAUNCHXL_freertos_gcc)
  set(CCS_PROJECT_LINK out_of_box_CC3220SF_LAUNCHXL_freertos_gcc)
  #Set this to the sysconfig version you want. For default projects there is usually a Debug and MCU+Image version.
  set(SYSCONFIG_TYPE Debug)

  #execute process runs prior to build system generation. add_custom_command runs during so it can't be used.
  #Creates a symlink to the SDK and reference CCS project.
  execute_process(
  COMMAND
    rm -f ${SDK_LINK}
  COMMAND
    rm -f ${CCS_PROJECT_LINK}
  COMMAND
    ln -T ${SDK} -s ${SDK_LINK}
  COMMAND
    ln -T ${CCS_PROJECT} -s ${CCS_PROJECT_LINK}
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