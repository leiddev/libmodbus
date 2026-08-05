cmake_minimum_required(VERSION 3.15)

# ============================================================================
# libmodbus - CMake Build System
# ============================================================================
# Version: 3.2.0
# Minimum CMake: 3.15 (required for VS2022 support)
# ============================================================================

project(libmodbus VERSION 3.2.0 LANGUAGES C)

# ============================================================================
# Build Options
# ============================================================================
option(BUILD_SHARED_LIBS "Build shared library" ON)
option(BUILD_TESTING "Build tests" ON)
option(LIBMODBUS_BUILD_TESTS "Build test programs" ${BUILD_TESTING})

# ============================================================================
# C Standard
# ============================================================================
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# ============================================================================
# Platform Detection
# ============================================================================
set(LIBMODBUS_OS_WINDOWS 0)
set(LIBMODBUS_OS_CYGWIN 0)
set(LIBMODBUS_OS_QNX 0)
set(LIBMODBUS_OS_SUNOS 0)

if(WIN32 AND NOT CYGWIN)
    set(LIBMODBUS_OS_WINDOWS 1)
endif()

if(CYGWIN)
    set(LIBMODBUS_OS_CYGWIN 1)
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "QNX")
    set(LIBMODBUS_OS_QNX 1)
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "SunOS")
    set(LIBMODBUS_OS_SUNOS 1)
endif()

# ============================================================================
# Global Compile Options
# ============================================================================
if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(
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
endif()

# ============================================================================
# Windows Specific
# ============================================================================
if(LIBMODBUS_OS_WINDOWS)
    add_definitions(-DWINVER=0x0501)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)

    if(BUILD_SHARED_LIBS)
        set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
    endif()

    if(MSVC)
        add_compile_options(/W4 /utf-8)
    endif()
endif()

# ============================================================================
# Export compile_commands.json for IDE support
# ============================================================================
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# ============================================================================
# Subdirectories
# ============================================================================
add_subdirectory(src)

if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(tests)
endif()

# ============================================================================
# CMake Config Files for find_package()
# ============================================================================
include(GNUInstallDirs)

include(CMakePackageConfigHelpers)

configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/libmodbusConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/libmodbusConfig.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/libmodbus
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/libmodbusConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(
    FILES
        ${CMAKE_CURRENT_BINARY_DIR}/libmodbusConfig.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/libmodbusConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/libmodbus
)
