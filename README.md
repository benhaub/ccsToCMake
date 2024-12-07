## ccsToCmake
Given a Code Composer Studio project, copy the files necessary to be able to start developing in a CMake environement
from the IDE of your choosing (e.g. VsCode). This will not copy any application level source files. Only the ones neccessary
for board bring-up.

The supported microcontrollers are given by the <partNumber>.cmake files in the repository.
For example, cc32xx simplelink microcontrollers are supported since a cc32xx.cmake file exists.

## Setup steps

Typically you would submodule this into your project. Assuming you've done that and the submodule `ccsToCMake` exists in your project
directory structure...

### 1. Build the project in Code Composer Studio

You need to build it here first so that the sysconfig files are generated.

### 2. Configure ccsProject.cmake to read your CCS project.

Set SDK, SDK_LINK, CCS_PROJECT, CCS_PROJECT_LINK, and SYSCONFIG_TYPE appropriately.
Their main purpose is to create a symbolic link to your CCS project and your SDK inside of your project.

### 3. Configure toolchain.cmake paths

Make sure the path for the compiler is correct. You shouldn't need to change anything else.
If you need extra options related to your software or you want to compile
additional libraries then add add them to your own CMakeLists.txt. The options here restricted to linker options or
compilition options specific to the ABI and hardware.

### 4. include() ccsToCmake/\<partNumber\>.cmake in your project CMakeLists.txt

I recommend something like this if using CC32xx:

```
#Call CMake with -DCC32xx=1
if (CC32xx)
  include(${CMAKE_CURRENT_LIST_DIR}/ccsToCMake/cc32xx.cmake)
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

### 7. Check out the required version of FreeRTOS.

If you're not using FreeRTOS for your project then skip this step.

Texas instruments usually provides a Quick Start Guide for their microcontrollers like [this one](https://software-dl.ti.com/ecs/SIMPLELINK_CC3220_SDK/2_20_00_10/exports/docs/simplelink_mcu_sdk/Quick_Start_Guide.html). It will tell you which version of FreeRTOS is officially supported. Once you know then you must checkout
a version using the available tags in the FreeRTOS submodule otherwise the Source directory will not be populated with any files.

### 8. Copy the source files.

Before you copy over any files, add a stub `main.c`, create a target, and try to compile the project with just one file to make sure all the libraries are being found and linked properly properly. If you get errors, make sure there are no typos in ccsProject.cmake

Copy over all of the *.[ch] and or *.[cpphpp] files to your project directory structure. Add them to your CMakeLists.txt in an way you like.
You can add them all using a one-liner `add_executable`, or you can place them into directories and use `add_subdirectory`.

You may also need to copy over some directories like `userFiles`.

### 9. Building

You need to add the --toolchain option when calling CMake and point it to ccsToCMake/\<partNumber\>.cmake

e.g. `cmake -G Ninja -S build --toolchain ccsToCMake/cc32xx.cmake`