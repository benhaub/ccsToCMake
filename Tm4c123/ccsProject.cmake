#You can find the correct port just by opening up an example project in code composer studio
#and checking where the project is grabbing the freertos portable files from.
#For Tm4c123 you must also change the port file under third_party in the CCS project.
set(PORT GCC/ARM_CM4F)
#Regex character class to select the heap scheme. Edit so that it matches all the heap schemes you don't want (inverse).
#For example [13-5], matches heap_1 and then heap_3 to heap_5 inclusive `[3-5]`. heap_2 is the only one not inlcuded so that's what we'll use.
set(HEAP_SCHEME heap_[1-35])

#Follow the guide below to get Tm4c123 and Tm4c129 devices set up on Code Composer Studio.
#https://www.ti.com/lit/an/spma085/spma085.pdf?ts=1742097771637&ref_url=https%253A%252F%252Fdev.ti.com%252F

#TODO: Add in symlink for windows.
if(${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Linux" OR ${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Darwin")
  #Set this to the install location of the SDK. It's best to install and compile the SDK using code composer studio first.
  set(SDK $ENV{HOME}/ti/TivaWare_C_Series-2.2.0.295)
  #Name of the link.
  set(SDK_LINK TivaWare_C_Series-2.2.0.295)
  #Set this to the location of the Code Composer Studio Project you want run. This CMake
  #file will automatically copy over any required files.
  set(CCS_PROJECT $ENV{HOME}/workspace_v12/adc_multi_channel)
  set(CCS_PROJECT_LINK adc_multi_channel)

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

#Grab all the source files for processor and FreeRTOS startup
file(GLOB startupSources LIST_DIRECTORIES false
  ${CMAKE_CURRENT_LIST_DIR}/${CCS_PROJECT_LINK}/tm4c123*.c
)
file(GLOB startupHeaders LIST_DIRECTORIES false
  ${CMAKE_CURRENT_LIST_DIR}/${CCS_PROJECT_LINK}/FreeRTOSConfig.h
)
#Grab any third-party files that have been included by the CCS project. The files are not actaully copied to the project, so just copy the directory structure.
file(GLOB_RECURSE thirdPartyDirectories RELATIVE ${CMAKE_CURRENT_LIST_DIR}/${CCS_PROJECT_LINK} LIST_DIRECTORIES true
  ${CMAKE_CURRENT_LIST_DIR}/${CCS_PROJECT_LINK}/third_party/*
)
#Loop through the third-party directory structure created by the project and grab the relevant files.
foreach (folder in ${thirdPartyDirectories})
  file(GLOB thirdPartySourceFiles LIST_DIRECTORIES true
    ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/${folder}/*[\.c|\.asm]
  )
  list(APPEND thirdPartySources ${thirdPartySourceFiles})

  file(GLOB thirdPartyHeaderFiles LIST_DIRECTORIES true
    ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/${folder}/*[\.h]
  )
  list(APPEND thirdPartyHeaders ${thirdPartyHeaderFiles})
endforeach()

#We grabbed all the heap schemes, so filter out the ones we don't need.
list(FILTER thirdPartySources EXCLUDE REGEX ${HEAP_SCHEME})