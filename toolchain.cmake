include(${CMAKE_CURRENT_LIST_DIR}/ccsProject.cmake)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(tools $ENV{HOME}/ti/ccs1281/ccs/tools/compiler/gcc-arm-none-eabi-9-2019-q4-major)
set(CMAKE_C_COMPILER ${tools}/bin/arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER ${tools}/bin/arm-none-eabi-g++)
#See https://cmake.org/cmake/help/latest/variable/CMAKE_TRY_COMPILE_TARGET_TYPE.html
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(CMAKE_C_FLAGS "-std=c99 ${CMAKE_C_FLAGS}")
set(CMAKE_CXX_FLAGS "-std=c++2a ${CMAKE_CXX_FLAGS}")

#CCS_PROJECT_SYMLINK is set in ccsProject.cmake
file(GLOB linkerScript ${CMAKE_CURRENT_LIST_DIR}/${CCS_PROJECT_LINK}/*.lds)

add_compile_options(
  -march=armv7e-m
  -mthumb
  -mfloat-abi=soft
)

add_link_options(
  -nostartfiles
  -static
  -specs=nano.specs
  -Wl,-T${linkerScript}
  -Wl,--gc-sections
  -Wl,-Map,cc32xx.map
)

link_libraries(
  stdc++
  gcc
  c
  m
  nosys
)
include_directories(${tools}/arm-none-eabi/lib/thumb/v7e-m/nofp/)
include_directories(${tools}/arm-none-eabi/include/newlib-nano)
