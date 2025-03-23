set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(tools $ENV{HOME}/ti/ccs1281/ccs/tools/compiler/gcc-arm-none-eabi-9-2019-q4-major)
set(CMAKE_C_COMPILER ${tools}/bin/arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER ${tools}/bin/arm-none-eabi-g++)
#See https://cmake.org/cmake/help/latest/variable/CMAKE_TRY_COMPILE_TARGET_TYPE.html
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(CMAKE_C_FLAGS "-std=c2x ${CMAKE_C_FLAGS}")
set(CMAKE_CXX_FLAGS "-std=c++2a ${CMAKE_CXX_FLAGS}")

#The driver lib is built with a hard fp and so anything that links it must also use a hard fp
#cxa_atexit information: https://itanium-cxx-abi.github.io/cxx-abi/abi.html#dso-dtor-motivation
#On an embedded system, there is no need to clean up after the program exits unless you were running
#a multi-process operating system like Linux. Other TI Cortex M4 devices like Cc32xx define _dso_handle
#in startup_cc32xx_gcc.c but don't implement it which effectively does the same thing as this switch.
add_compile_options(
  -mcpu=cortex-m4
  -march=armv7e-m
  -mthumb
  -mfloat-abi=hard
  -mfpu=fpv4-sp-d16
)

include_directories(${tools}/arm-none-eabi/include)
include_directories(${tools}/arm-none-eabi/include/newlib-nano)

#libgcc.a is here
link_directories(${tools}/lib/gcc/arm-none-eabi/9.2.1/thumb/v7e-m+fp/hard)
#The rest of the libs are here.
link_directories(${tools}/arm-none-eabi/lib/thumb/v7e-m+fp/hard)

add_link_options(
  -nostartfiles
  -nodefaultlibs
  -static
  --specs=nano.specs
  -Wl,-T${CMAKE_CURRENT_LIST_DIR}/tm4c123gh6pm.lds
  -Wl,--gc-sections
  -Wl,-Map,tm4c123gh6pm.map
  -Wl,--print-memory-usage
)

link_libraries(
  gcc
  c
  m
  nosys
  stdc++
)