## ccsToCmake
Given a Code Composer Studio project, copy the files necessary to be able to start developing in a CMake environement
from the IDE of your choosing. This will not copy any application level source files. Only the ones neccessary for board bring-up.

The supported microcontrollers are given by the <partNumber>.cmake files in the repository.
For example, cc32xx simplelink microcontrollers are supported since a cc32xx.cmake file exists.

## Setup steps

### 1. Configure the cmake file for your part number

Set SDK, SDK_LINK, CCS_PROJECT and SYSCONFIG_TYPE are set appropriately.
These variables are found at the top of <partNumber>.cmake

### 2. Configure the toolchain paths

Make sure the path for the compiler is correct. Especially make sure the path to Code Composer Studio is correct.
You shouldn't need to change anything else. If you need extra options or to compile additional libraries then add
add them to your own CMakeLists.txt

If your MCU needs to use a different floating point library or use hardware instead the you will no to change -mfloat-abi=soft
to -mfloat-abi=hard. The default is to use software floating point.

### 3. include() <partNumber>.cmake in your project CMakeLists.txt
I reccommend something like this:

```
if (CC32xx)
  include(${CMAKE_CURRENT_LIST_DIR}/ccsToCMake/cc32xx.cmake)
endif()
```

The CC32xx is set by the toolchain CMake file.

### 4. Check out the required version of FreeRTOS.

If you're not using FreeRTOS for your project then skip this step.

Texas instruments usually provides a Quick Start Guide for their microcontrollers like (this one)[https://software-dl.ti.com/ecs/SIMPLELINK_CC3220_SDK/2_20_00_10/exports/docs/simplelink_mcu_sdk/Quick_Start_Guide.html]. It will tell you which version of FreeRTOS is officially supported. Once you know then you must checkout
a version using the available tags in the FreeRTOS submodule otherwise the Source directory will not be populated with any files.

### 4. Building

You need to add the --toolchain option when calling CMake and point it to ccsToCMake/<partNumber>Toolchain.cmake

e.g. `cmake -G Ninja -S build --toolchain ccsToCMake/cc32xxToolchain.cmake`
