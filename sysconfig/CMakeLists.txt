#Copy the files from the Code Composer project sysconfig
target_sources(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PRIVATE FILE_SET headers TYPE HEADERS BASE_DIRS ${CMAKE_CURRENT_LIST_DIR} FILES
  FreeRTOSConfig.h
  ti_drivers_config.h
)

target_sources(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PRIVATE
  ti_drivers_config.c
  ti_freertos_config.c
  ti_freertos_portable_config.c
)

target_include_directories(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PRIVATE
  ${CMAKE_CURRENT_LIST_DIR}
)
