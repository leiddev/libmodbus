# ============================================================================
# libmodbus - CMake Utility Module
# ============================================================================
# Common functions and macros for libmodbus CMake builds
# ============================================================================

# ----------------------------------------------------------------------------
# Function: libmodbus_add_compile_warnings
# Adds compiler warning flags for the given target
# ----------------------------------------------------------------------------
function(libmodbus_add_compile_warnings target)
    if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
        target_compile_options(${target} PRIVATE
            -Wall
            -Wextra
            -Wmissing-declarations
            -Wmissing-prototypes
            -Wnested-externs
            -Wpointer-arith
            -Wsign-compare
            -Wchar-subscripts
            -Wstrict-prototypes
            -Wshadow
            -Wformat-security
        )
    elseif(MSVC)
        target_compile_options(${target} PRIVATE
            /W4
            /utf-8
        )
    endif()
endfunction()

# ----------------------------------------------------------------------------
# Function: libmodbus_find_optional_library
# Finds an optional library and sets a cache variable
# ----------------------------------------------------------------------------
function(libmodbus_find_optional_library result name)
    find_library(${result} ${name} ${ARGN})
    if(${result})
        set(${result} ${${result}} CACHE STRING "Path to ${name} library")
        message(STATUS "Found ${name}: ${${result}}")
    else()
        set(${result} "" CACHE STRING "Path to ${name} library (not found)")
        message(STATUS "${name} not found")
    endif()
endfunction()

# ----------------------------------------------------------------------------
# Function: libmodbus_check_function
# Checks if a function exists and sets a compile definition
# ----------------------------------------------------------------------------
function(libmodbus_check_function func var)
    include(CheckFunctionExists)
    check_function_exists(${func} ${var})
    if(${var})
        set(${var} 1 CACHE BOOL "")
        message(STATUS "Function ${func} found")
    else()
        set(${var} 0 CACHE BOOL "")
        message(STATUS "Function ${func} not found")
    endif()
endfunction()

# ----------------------------------------------------------------------------
# Function: libmodbus_check_include
# Checks if a header exists and sets a compile definition
# ----------------------------------------------------------------------------
function(libmodbus_check_include header var)
    include(CheckIncludeFile)
    check_include_file(${header} ${var})
    if(${var})
        set(${var} 1 CACHE BOOL "")
        message(STATUS "Header ${header} found")
    else()
        set(${var} 0 CACHE BOOL "")
        message(STATUS "Header ${header} not found")
    endif()
endfunction()
