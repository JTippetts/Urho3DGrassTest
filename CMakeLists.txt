# Set CMake minimum version and CMake policy required by UrhoCommon module
cmake_minimum_required (VERSION 3.2.3)
if (COMMAND cmake_policy)
    # Libraries linked via full path no longer produce linker search paths
    cmake_policy (SET CMP0003 NEW)
    # INTERFACE_LINK_LIBRARIES defines the link interface
    cmake_policy (SET CMP0022 NEW)
    # Disallow use of the LOCATION target property - so we set to OLD as we still need it
    cmake_policy (SET CMP0026 OLD)
    # MACOSX_RPATH is enabled by default
    cmake_policy (SET CMP0042 NEW)
    # Honor the visibility properties for SHARED target types only
    cmake_policy (SET CMP0063 OLD)
endif ()

IF( ${CMAKE_COMPILER_IS_GNUCXX} )
  ADD_DEFINITIONS(-static-libgcc -static-libstdc++)
  SET(CMAKE_CXX_LINK_EXECUTABLE "${CMAKE_CXX_LINK_EXECUTABLE}
-static-libgcc -static-libstdc++")
ENDIF( ${CMAKE_COMPILER_IS_GNUCXX} )

# Set project name
project (GrassTest)
# Set CMake modules search path
set (CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/CMake/Modules)
# Include UrhoCommon.cmake module after setting project name
include (UrhoCommon)

# Define target name
set (TARGET_NAME GrassTest)
# Define source files
define_source_files (EXTRA_CPP_FILES)
# Setup target with resource copying
setup_main_executable ()
