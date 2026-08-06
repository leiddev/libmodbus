# ============================================================================
# libmodbus - Source Library
# ============================================================================

# ============================================================================
# System Checks
# ============================================================================
include(CheckIncludeFile)
include(CheckFunctionExists)
include(CheckCSourceCompiles)

# Check for system headers
check_include_file("arpa/inet.h" HAVE_ARPA_INET_H)
check_include_file("byteswap.h" HAVE_BYTESWAP_H)
check_include_file("errno.h" HAVE_ERRNO_H)
check_include_file("fcntl.h" HAVE_FCNTL_H)
check_include_file("limits.h" HAVE_LIMITS_H)
check_include_file("netdb.h" HAVE_NETDB_H)
check_include_file("netinet/in.h" HAVE_NETINET_IN_H)
check_include_file("netinet/ip.h" HAVE_NETINET_IP_H)
check_include_file("netinet/tcp.h" HAVE_NETINET_TCP_H)
check_include_file("sys/ioctl.h" HAVE_SYS_IOCTL_H)
check_include_file("sys/socket.h" HAVE_SYS_SOCKET_H)
check_include_file("sys/time.h" HAVE_SYS_TIME_H)
check_include_file("sys/types.h" HAVE_SYS_TYPES_H)
check_include_file("termios.h" HAVE_TERMIOS_H)
check_include_file("time.h" HAVE_TIME_H)
check_include_file("unistd.h" HAVE_UNISTD_H)
check_include_file("linux/serial.h" HAVE_LINUX_SERIAL_H)

# Check for Windows headers
if(WIN32)
    check_include_file("winsock2.h" HAVE_WINSOCK2_H)
endif()

# Check for functions
check_function_exists(accept4 HAVE_ACCEPT4)
check_function_exists(gai_strerror HAVE_GAI_STRERROR)
check_function_exists(getaddrinfo HAVE_GETADDRINFO)
check_function_exists(gettimeofday HAVE_GETTIMEOFDAY)
check_function_exists(inet_pton HAVE_INET_PTON)
check_function_exists(inet_ntop HAVE_INET_NTOP)
check_function_exists(select HAVE_SELECT)
check_function_exists(socket HAVE_SOCKET)
check_function_exists(strerror HAVE_STRERROR)
check_function_exists(strlcpy HAVE_STRLCPY)

# Check for struct termios2 (Linux specific)
if(HAVE_TERMIOS_H AND HAVE_SYS_IOCTL_H)
    check_c_source_compiles("
        #include <asm/termbits.h>
        int main() {
            struct termios2 t;
            return 0;
        }
    " HAVE_STRUCT_TERMIOS2)
endif()

# Check for RS-485 support (Linux)
if(HAVE_SYS_IOCTL_H)
    check_c_source_compiles("
        #include <sys/ioctl.h>
        int main() { return TIOCSRS485; }
    " HAVE_DECL_TIOCSRS485)

    check_c_source_compiles("
        #include <sys/ioctl.h>
        int main() { return TIOCM_RTS; }
    " HAVE_DECL_TIOCM_RTS)
endif()

# Check for Cygwin
check_c_source_compiles("
    int main() { return __CYGWIN__; }
" HAVE_DECL___CYGWIN__)

# ============================================================================
# Version Variables
# ============================================================================
set(LIBMODBUS_VERSION_MAJOR 3)
set(LIBMODBUS_VERSION_MINOR 2)
set(LIBMODBUS_VERSION_MICRO 0)

# ============================================================================
# Generate config.h
# ============================================================================
configure_file(
    ${CMAKE_SOURCE_DIR}/config.h.in
    ${CMAKE_CURRENT_BINARY_DIR}/config.h
)

# ============================================================================
# Version header generation
# ============================================================================
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/modbus-version.h.in
    ${CMAKE_CURRENT_BINARY_DIR}/modbus-version.h
)

# ============================================================================
# Source Files
# ============================================================================
set(LIBMODBUS_SOURCES
    modbus.c
    modbus-data.c
    modbus-rtu.c
    modbus-tcp.c
)

# ============================================================================
# Public Headers
# ============================================================================
set(LIBMODBUS_PUBLIC_HEADERS
    modbus.h
    modbus-rtu.h
    modbus-tcp.h
    ${CMAKE_CURRENT_BINARY_DIR}/modbus-version.h
)

# ============================================================================
# Private Headers
# ============================================================================
set(LIBMODBUS_PRIVATE_HEADERS
    modbus-private.h
    modbus-rtu-private.h
    modbus-tcp-private.h
)

# ============================================================================
# Create Library
# ============================================================================
add_library(modbus ${LIBMODBUS_SOURCES}
    ${LIBMODBUS_PUBLIC_HEADERS}
    ${LIBMODBUS_PRIVATE_HEADERS}
)

add_library(libmodbus::libmodbus ALIAS modbus)

# ============================================================================
# Include Directories
# ============================================================================
target_include_directories(modbus
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:include>
    PRIVATE
        ${CMAKE_CURRENT_BINARY_DIR}
)

# Include config.h for all sources
target_compile_options(modbus PRIVATE
    $<$<C_COMPILER_ID:GNU,Clang,AppleClang>:-include>
    $<$<C_COMPILER_ID:GNU,Clang,AppleClang>:${CMAKE_CURRENT_BINARY_DIR}/config.h>
    $<$<C_COMPILER_ID:MSVC>:/FI${CMAKE_CURRENT_BINARY_DIR}/config.h>
)

# ============================================================================
# Compile Definitions
# ============================================================================
target_compile_definitions(modbus PRIVATE
    DLLBUILD
    SYSCONFDIR="${CMAKE_INSTALL_SYSCONFDIR}"
    LIBEXECDIR="${CMAKE_INSTALL_LIBEXECDIR}"
)

# ============================================================================
# Platform-Specific Libraries
# ============================================================================
if(LIBMODBUS_OS_WINDOWS)
    if(BUILD_SHARED_LIBS)
        target_link_libraries(modbus PRIVATE ws2_32)
    else()
        target_link_libraries(modbus PRIVATE ws2_32 wsock32)
    endif()
endif()

if(LIBMODBUS_OS_QNX)
    target_link_libraries(modbus PRIVATE socket)
endif()

if(LIBMODBUS_OS_SUNOS)
    target_link_libraries(modbus PRIVATE nsl socket)
endif()

# ============================================================================
# Version Information (SOVERSION)
# ============================================================================
# The library version is 3.2.0, corresponding to libtool's 6:0:1
# SOVERSION 6 matches the libtool CURRENT version
set_target_properties(modbus PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION 6
    PUBLIC_HEADER "${LIBMODBUS_PUBLIC_HEADERS}"
)

# ============================================================================
# Installation
# ============================================================================
include(GNUInstallDirs)

install(
    TARGETS modbus
    EXPORT libmodbusTargets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/modbus
)

install(
    EXPORT libmodbusTargets
    FILE libmodbusTargets.cmake
    NAMESPACE libmodbus::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/libmodbus
)

# ============================================================================
# pkg-config File
# ============================================================================
configure_file(
    ${CMAKE_SOURCE_DIR}/libmodbus.pc.in
    ${CMAKE_CURRENT_BINARY_DIR}/libmodbus.pc
    @ONLY
)

install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/libmodbus.pc
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
)

# ============================================================================
# Export targets for find_package()
# ============================================================================
export(TARGETS modbus FILE ${CMAKE_CURRENT_BINARY_DIR}/libmodbusTargets.cmake)
