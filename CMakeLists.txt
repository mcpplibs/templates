cmake_minimum_required(VERSION 4.0.2)

# https://github.com/Kitware/CMake/blob/master/Help/dev/experimental.rst
set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "a9e1cf81-9932-4810-974b-6eccaf14e457")
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_MODULE_STD 1)

project(mcpplibs-templates VERSION 1.0.0 LANGUAGES CXX)

# Library target
add_library(mcpplibs-templates STATIC)

target_sources(mcpplibs-templates
    PUBLIC
        FILE_SET CXX_MODULES FILES
        src/templates.cppm
)

# Test executable
add_executable(tests tests/main.cpp)
target_link_libraries(tests PRIVATE mcpplibs-templates)

# Enable testing
enable_testing()
add_test(NAME mcpplibs-templates-test COMMAND tests)