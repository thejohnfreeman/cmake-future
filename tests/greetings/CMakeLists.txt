# 3.12 for --build --parallel.
cmake_minimum_required(VERSION 3.12)
project(greetings VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_FIND_PACKAGE_SORT_ORDER NATURAL)
set(CMAKE_FIND_PACKAGE_SORT_DIRECTION DEC)
find_package(future REQUIRED)

future_add_headers(headers DIRECTORY include)
add_subdirectory(src)
enable_testing()
add_subdirectory(tests)

future_install_project()
