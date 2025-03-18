target_sources(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PRIVATE FILE_SET headers TYPE HEADERS BASE_DIRS ${CMAKE_CURRENT_LIST_DIR} FILES
  ${startupHeaders}
)
#Add the sysconfig generated source files. These are set in ccsProject.cmake
target_sources(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PRIVATE
  ${startupSources}
  ${thirdPartySourceFiles}
)

target_include_directories(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PRIVATE
  ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/third_party/FreeRTOS/Source/include
  ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/third_party/FreeRTOS/Source/portable
  ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}/third_party/FreeRTOS/Source/portable/${PORT}
)

get_target_property(Includes ${PROJECT_NAME}${EXECUTABLE_SUFFIX} INCLUDE_DIRECTORIES)
message(STATUS "Includes: ${Includes}")

target_include_directories(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/${SDK_LINK}
)

target_include_directories(${PROJECT_NAME}${EXECUTABLE_SUFFIX}
PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/${CCS_PROJECT_LINK}
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
    PART_TM4C123GH6PM
)