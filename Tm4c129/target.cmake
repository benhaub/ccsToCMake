#TODO: Add in symlink for windows.
if(${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Linux" OR ${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Darwin")
  #Set this to the install location of the SDK. It's best to install and compile the SDK using code composer studio first.
  set(SDK $ENV{HOME}/ti/TivaWare_C_Series-2.2.0.295)
  #Name of the link.
  set(SDK_LINK TivaWare_C_Series-2.2.0.295)

  #execute process runs prior to build system generation. add_custom_command runs during so it can't be used.
  #Creates a symlink to the SDK and reference CCS project.
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

else()
  message(FATAL_ERROR "Only Linux or MacOS is supported")
endif()

#You can find the correct port just by opening up an example project in code composer studio
#and checking where the project is grabbing the freertos portable files from.
set(PORT GCC/ARM_CM4F)
set(HEAP_SCHEME heap_4)

#Add local sources
target_sources(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PRIVATE FILE_SET headers TYPE HEADERS BASE_DIRS ${CMAKE_CURRENT_LIST_DIR} FILES
  ${CMAKE_CURRENT_LIST_DIR}/FreeRTOSConfig.h
  #Auto generated sysconfig pinmux file
  ${CMAKE_CURRENT_LIST_DIR}/pinout.h
)
target_sources(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PRIVATE
  ${CMAKE_CURRENT_LIST_DIR}/tm4c1294ncpdt_startup_ccs_gcc.c
  ${CMAKE_CURRENT_LIST_DIR}/pinout.c
)

#Add sources from the SDK
target_sources(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PRIVATE
  ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/third_party/FreeRTOS/Source/croutine.c
  ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/third_party/FreeRTOS/Source/event_groups.c
  ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/third_party/FreeRTOS/Source/list.c
  ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/third_party/FreeRTOS/Source/queue.c
  ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/third_party/FreeRTOS/Source/tasks.c
  ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/third_party/FreeRTOS/Source/timers.c
  ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/third_party/FreeRTOS/Source/portable/${PORT}/port.c
  ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/utils/uartstdio.c
  ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/third_party/FreeRTOS/Source/portable/MemMang/${HEAP_SCHEME}.c
)

target_include_directories(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PRIVATE
  ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/third_party/FreeRTOS/Source/include
  ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/third_party/FreeRTOS/Source/portable
  ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/third_party/FreeRTOS/Source/portable/${PORT}
  ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/utils
)

target_include_directories(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}
)

target_link_directories(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/driverlib/gcc
)
#The order in which you link libraries matters!
target_link_libraries(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PRIVATE
    driver
)

target_compile_definitions(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PRIVATE
    PART_TM4C1294NCPDT
)