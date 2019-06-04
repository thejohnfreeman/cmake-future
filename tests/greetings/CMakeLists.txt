# future_add_test_executable requires 3.7.
cmake_minimum_required(VERSION 3.7)
project(greetings VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_FIND_PACKAGE_SORT_ORDER NATURAL)
set(CMAKE_FIND_PACKAGE_SORT_DIRECTION DEC)
find_package(future REQUIRED)

future_add_headers(headers DIRECTORY include)
add_subdirectory(src)
enable_testing()
add_subdirectory(tests)

future_install_project()
