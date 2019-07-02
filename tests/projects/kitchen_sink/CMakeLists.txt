# This project is named the kitchen sink because it is a dumping ground for
# many different tests. If a test needs an isolated special case, then it
# should get its own project, but if it "should" work in all cases, then this
# is a great place to put it and test all the incidental interactions with
# other modules and tests.

cmake_minimum_required(VERSION 3.11)
project(my_project VERSION 1.0)

include(assert.cmake)

set(CMAKE_FIND_PACKAGE_SORT_ORDER NATURAL)
set(CMAKE_FIND_PACKAGE_SORT_DIRECTION DEC)
find_package(future REQUIRED)

if(NOT future_FOUND)
  message(SEND_ERROR "`future_FOUND` is not truthy")
endif()

future_project(
  LICENSE ISC
  REPOSITORY_URL "https://example.com"
  AUTHORS "John Freeman <jfreeman08@gmail.com>"
)

if(NOT my_project_FOUND)
  message(SEND_ERROR "`my_project_FOUND` is not truthy")
endif()
assert(PROJECT_LICENSE STREQUAL ISC)
assert(CMAKE_PROJECT_LICENSE STREQUAL ISC)
assert(PROJECT_REPOSITORY_URL STREQUAL "https://example.com")
assert(CMAKE_PROJECT_REPOSITORY_URL STREQUAL "https://example.com")
assert(PROJECT_AUTHORS STREQUAL "John Freeman <jfreeman08@gmail.com>")
assert(CMAKE_PROJECT_AUTHORS STREQUAL "John Freeman <jfreeman08@gmail.com>")

add_library(my_lib_private INTERFACE)
future_add_library(my_lib INTERFACE)

future_install_project()

## Queries and assertions below.

future_get_targets(actual)
assert(actual STREQUAL "my_lib_private;my_lib")

future_get_export_set(actual ${FUTURE_PROJECT_EXPORT_SET})
assert(actual STREQUAL "my_lib")
