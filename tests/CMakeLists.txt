# ============================================================================
# libmodbus - Test Suite
# ============================================================================

# ============================================================================
# Unit-test.h generation
# ============================================================================
check_include_file("inttypes.h" HAVE_INTTYPES_H)
check_include_file("stdint.h" HAVE_STDINT_H)

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/unit-test.h.in
    ${CMAKE_CURRENT_BINARY_DIR}/unit-test.h
)

# ============================================================================
# Test programs
# ============================================================================
set(TEST_PROGRAMS
    bandwidth-server-one
    bandwidth-server-many-up
    bandwidth-client
    random-test-server
    random-test-client
    unit-test-server
    unit-test-client
    proxy-test-server
    proxy-test-client
    version
)

# ============================================================================
# Create Test Executables
# ============================================================================
foreach(program ${TEST_PROGRAMS})
    string(REPLACE "-" "_" program_underscore ${program})
    add_executable(${program} ${program}.c)
    target_link_libraries(${program} PRIVATE libmodbus::libmodbus)
    target_include_directories(${program} PRIVATE
        ${CMAKE_SOURCE_DIR}/src
        ${CMAKE_BINARY_DIR}/src
        ${CMAKE_CURRENT_BINARY_DIR}
    )
    target_compile_definitions(${program} PRIVATE
        SYSCONFDIR="${CMAKE_INSTALL_SYSCONFDIR}"
        LIBEXECDIR="${CMAKE_INSTALL_LIBEXECDIR}"
    )

    # Set output directory for executables
    set_target_properties(${program} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )
endforeach()

# ============================================================================
# Unit Test Script (for CTest)
# ============================================================================
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/unit-tests.sh.in
    ${CMAKE_CURRENT_BINARY_DIR}/unit-tests.sh
    @ONLY
)

# Copy proxy-tests.sh if it exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/proxy-tests.sh)
    configure_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/proxy-tests.sh
        ${CMAKE_CURRENT_BINARY_DIR}/proxy-tests.sh
        COPYONLY
    )
endif()

# ============================================================================
# CTest Configuration
# ============================================================================
include(CTest)

if(BUILD_TESTING)
    # Add unit-tests.sh as a test
    add_test(
        NAME unit-test
        COMMAND ${CMAKE_CURRENT_BINARY_DIR}/unit-tests.sh
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )

    # Set test environment
    set_tests_properties(unit-test PROPERTIES
        ENVIRONMENT "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/src:${LD_LIBRARY_PATH}"
        TIMEOUT 60
    )
endif()

# ============================================================================
# Installation of Test Scripts
# ============================================================================
install(
    PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/unit-tests.sh
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    COMPONENT tests
)

if(EXISTS ${CMAKE_CURRENT_BINARY_DIR}/proxy-tests.sh)
    install(
        PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/proxy-tests.sh
        DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
        COMPONENT tests
    )
endif()
