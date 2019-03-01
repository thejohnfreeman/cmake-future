# Third-party CMake extension modules must be imported with `find_package`, not
# `include`. `include` searches the built-in modules and `CMAKE_MODULE_PATH`,
# which is empty by default and should be assigned only by projects.
#
# The path searched by `find_package` differs by platform:
# https://cmake.org/cmake/help/latest/command/find_package.html
# But it is derived from the installation prefixes held in the variable
# `CMAKE_SYSTEM_PREFIX_PATH`:
# https://cmake.org/cmake/help/latest/variable/CMAKE_SYSTEM_PREFIX_PATH.html#variable:CMAKE_SYSTEM_PREFIX_PATH
#
# We use a switch on platform (`UNIX` and `WIN32`) to choose the right
# installation path. We must set a value that works with the intended usage:
#
#     install(FILES ${PROJECT_NAME}-config.cmake
#       DESTINATION ${CMAKE_INSTALL_EXPORTDIR}/${PROJECT_NAME}-${PROJECT_VERSION}
#     )
#
list(GET CMAKE_SYSTEM_PREFIX_PATH 0 PREFIX)
if(${UNIX})
  set(PREFIX "${PREFIX}/lib/cmake")
endif()
set(CMAKE_INSTALL_EXPORTDIR "${PREFIX}")
