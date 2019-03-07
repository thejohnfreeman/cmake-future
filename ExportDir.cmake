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

if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  # Unless we join these into the same message, they get separated by a stack
  # trace, which is a bad user experience.
  set(
    MSG "CMAKE_INSTALL_PREFIX must be defined to use the ExportDir module.\n"
  )
  if(DEFINED CMAKE_SCRIPT_MODE_FILE)
    set(
      MSG ${MSG}
      "NOTE: CMAKE_INSTALL_PREFIX is not defined by default when you run "
      "CMake in script mode (-P)."
    )
  endif(DEFINED CMAKE_SCRIPT_MODE_FILE)
  message(SEND_ERROR ${MSG})
  return()
endif(NOT DEFINED CMAKE_INSTALL_PREFIX)

# Package configuration files (`<package>-config.cmake`) should be installed
# like any other file: under `CMAKE_INSTALL_PREFIX`. We check that the
# `CMAKE_INSTALL_PREFIX` can be found in the `CMAKE_SYSTEM_PREFIX_PATH`; if it
# isn't, then `find_package` won't find our package configuration file.
list(FIND CMAKE_SYSTEM_PREFIX_PATH "${CMAKE_INSTALL_PREFIX}" INDEX)
if(INDEX LESS 0)
  message(WARNING
    " CMAKE_INSTALL_PREFIX not found in CMAKE_SYSTEM_PREFIX_PATH\n"
    " CMAKE_INSTALL_PREFIX=\"${CMAKE_INSTALL_PREFIX}\"\n"
    " CMAKE_SYSTEM_PREFIX_PATH=\"${CMAKE_SYSTEM_PREFIX_PATH}\""
  )
endif(INDEX LESS 0)

set(PREFIX "${CMAKE_INSTALL_PREFIX}")
if(${UNIX})
  set(PREFIX "${PREFIX}/lib/cmake")
endif()
set(CMAKE_INSTALL_EXPORTDIR "${PREFIX}")
