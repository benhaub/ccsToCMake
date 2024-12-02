set(CMAKE_CXX_COMPILER ${tools}/bin/arm-none-eabi-g++)
#See https://cmake.org/cmake/help/latest/variable/CMAKE_TRY_COMPILE_TARGET_TYPE.html
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(CMAKE_C_FLAGS "-std=c99 ${CMAKE_C_FLAGS}")
set(CMAKE_CXX_FLAGS "-std=c++2a ${CMAKE_CXX_FLAGS}")

add_compile_options(
  -ffunction-sections
  -fdata-sections
  -fno-exceptions
  -Wall
  -march=armv7e-m
  -mthumb
  -mfloat-abi=soft
)

add_link_options(
  -nostartfiles
  -static
  -Wl,-T${CMAKE_CURRENT_LIST_DIR}/cc32xxsf_freertos.lds
  -Wl,--gc-sections
  -Wl,-Map,autoFeeder.map
)

link_libraries(
  stdc++
  gcc
  c
  m
  nosys
)
include_directories(${tools}/arm-none-eabi/lib/thumb/v7e-m/nofp/)
