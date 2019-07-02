cmake_minimum_required(VERSION 3.11)
project(my_project VERSION 1.0)

set(CMAKE_FIND_PACKAGE_SORT_ORDER NATURAL)
set(CMAKE_FIND_PACKAGE_SORT_DIRECTION DEC)
find_package(future REQUIRED)

# `future_project` requires a `LICENSE` argument.
future_project()
