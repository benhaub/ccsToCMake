## ccsToCmake
Given a Code Composer Studio project, copy the files necessary to be able to start developing in a CMake environement
from the IDE of your choosing (e.g. VsCode). This will not copy any application level source files. Only the ones neccessary
for board bring-up.

The supported microcontrollers are given by the `./<partNumber>` folder in the repository.
For example, Cc32xx simplelink microcontrollers are supported since a `Cc32xx/target.cmake` file exists.

Since the CMake code add new files within this respository, you may want to add `ignore = dirty` or `ignore = all`
to your `.gitmodules`.

## Setup steps

Typically you would submodule this into your project. Assuming you've done that and the submodule `ccsToCMake` exists in your project
directory structure...

### 1. Build the project in Code Composer Studio

Skip this step if your project does not use sysconfig (e.g. Tm4c123)

Use the Sysconfig editor in any way you'd like to add or remove configurations. Build the project in Code Composer Studio so that all the
files are generated. For reasons in which I can't comprehend, The Sysconfig tool only allows you to partially change the FreeRTOSConfig.h file meaning if you change anything not offered by the sysconfig tool it will be overwritten on your next build. The only solution is to tell Sysconfig not to regenerate the file. The instructions to do so are here:
https://e2e.ti.com/support/wireless-connectivity/bluetooth-group/bluetooth/f/bluetooth-forum/1201607/cc2340r5-how-to-change-a-config-in-freertosconfig-h-with-simplelink_cc23xx_sdk_6_40_00_21_eng.

### 2. Configure ccsProject.cmake to read your CCS project.

Set SDK, SDK_LINK, CCS_PROJECT, CCS_PROJECT_LINK, and SYSCONFIG_TYPE appropriately.
Their main purpose is to create a symbolic link to your CCS project and your SDK inside of your project.

### 3. Configure toolchain.cmake paths

Make sure the path for the compiler is correct. You shouldn't need to change anything else.
If you need extra options related to your software or you want to compile
additional libraries then add add them to your own CMakeLists.txt. The options here restricted to linker options or
compilition options specific to the ABI and hardware.

### 4. include() ccsToCmake/\<partNumber\>/target.cmake in your project CMakeLists.txt

I recommend something like this if using CC32xx:

```
#Call CMake with -DCC32xx=1
if (Cc32xx)
  include(${CMAKE_CURRENT_LIST_DIR}/ccsToCMake/Cc32xx/target.cmake)
endif()
```

### 5. Strip the executable

Since these cmake files should not make any assumptions about where you have chosen to place your `.elf` executable,
you will need to add this into your CMakeLists.txt. Something like this should work:

```
add_custom_command(TARGET ${PROJECT_NAME}${EXECUTABLE_SUFFIX} POST_BUILD
COMMAND
  ${CMAKE_OBJCOPY} ARGS -O binary ${CMAKE_SOURCE_DIR}/customToolchain_build/${PROJECT_NAME}${EXECUTABLE_SUFFIX} ${CMAKE_SOURCE_DIR}/customToolchain_build/${PROJECT_NAME}.bin
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_LIST_DIR}
  COMMENT
    "Stripping executable"
  VERBATIM
)
```

### 6. Define a CMake target in the form ${PROJECT_NAME}${EXECUTABLE_SUFFIX}
Your CMakeLists.txt must also define a target using the two variables PROJECT_NAME and EXECUTABLE_SUFFIX.
The target can not be an INTERFACE. One way to do this:

```
project(ccsExample LANGUAGES C CXX)
set(EXECUTABLE_SUFFIX .elf)

add_executable(${PROJECT_NAME}${EXECUTABLE_SUFFIX} main.c)
```

### 7 (Optional). Update the version of FreeRTOS.

If you're not using FreeRTOS for your project then skip this step.

Texas instruments usually provides a Quick Start Guide for their microcontrollers like [this one](https://software-dl.ti.com/ecs/SIMPLELINK_CC3220_SDK/2_20_00_10/exports/docs/simplelink_mcu_sdk/Quick_Start_Guide.html). It will tell you which version of FreeRTOS is officially supported. This version will be checked out by default but you may update to a different version using the available tags in the FreeRTOS submodule otherwise the Source directory will not be populated with any files.

### 8. Copy the source files.

Before you copy over any files, add a stub `main.c`, create a target, and try to compile the project with just one file to make sure all the libraries are being found and linked properly properly. If you get errors, make sure there are no typos in ccsProject.cmake

Copy over all of the *.[ch] and or *.[cpphpp] files to your project directory structure. Add them to your CMakeLists.txt in an way you like.
You can add them all using a one-liner `add_executable`, or you can place them into directories and use `add_subdirectory`.

You may also need to copy over some directories like `userFiles`.

### 9. Building

You need to add the --toolchain option when calling CMake and point it to ccsToCMake/\<partNumber\>/target.cmake

e.g. `cmake -G Ninja -S build --toolchain ccsToCMake/Cc32xx/target.cmake`
