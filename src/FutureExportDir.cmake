# This extension exports a variable, `FUTURE_INSTALL_EXPORTDIR`, that is
# the absolute prefix where CMake package configuration files (and their
# corresponding `<PackageName>-targets.cmake` *export* files) should be
# installed. It is on the path where `find_package` searches for package
# configuration files. It differs by platform, but it is derived from the
# installation prefixes held in the variable `CMAKE_SYSTEM_PREFIX_PATH`.
#
# [package configuration file]: https://cmake.org/cmake/help/latest/manual/cmake-packages.7.html#package-configuration-file
# [find_package]: https://cmake.org/cmake/help/latest/command/find_package.html
# [`CMAKE_SYSTEM_PREFIX_PATH`]: https://cmake.org/cmake/help/latest/variable/CMAKE_SYSTEM_PREFIX_PATH.html#variable:CMAKE_SYSTEM_PREFIX_PATH
#
# (CMake has the concept of "package registry" which sounds like it should be
# the preferred location to install package configuration files, but I have
# been told by insiders that it is not encouraged.)
#
# https://cmake.org/cmake/help/v3.14/manual/cmake-packages.7.html#package-registry
#
# We use a switch on platform (`UNIX` and `WIN32`) to choose the right
# installation path. We must set a value that works with the intended usage:
#
#     install(FILES ${PROJECT_NAME}-config.cmake
#       DESTINATION ${FUTURE_INSTALL_EXPORTDIR}/${PROJECT_NAME}-${PROJECT_VERSION}
#     )
#
# This installation path is useful for more than just package configuration
# files; it is necessary for third-party CMake extension modules (like this
# one). `include` searches the built-in modules and `CMAKE_MODULE_PATH`, which
# is empty by default and should be assigned only by projects. There is no
# place to install extension modules where they can be discovered by default,
# i.e. without requiring projects to set `CMAKE_MODULE_PATH`. The only
# alternative import function is `find_package`.

if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  # Unless we join these into the same message, they get separated by a stack
  # trace, which is a bad user experience.
  set(
    msg "CMAKE_INSTALL_PREFIX must be defined to use the ExportDir module.\n"
  )
  if(DEFINED CMAKE_SCRIPT_MODE_FILE)
    set(
      msg ${msg}
      "NOTE: CMAKE_INSTALL_PREFIX is not defined by default when you run "
      "CMake in script mode (-P)."
    )
  endif()
  message(SEND_ERROR ${msg})
  return()
endif()

# Package configuration files (`<package>-config.cmake`) should be installed
# like any other file: under `CMAKE_INSTALL_PREFIX`. We check that the
# `CMAKE_INSTALL_PREFIX` can be found in the `CMAKE_SYSTEM_PREFIX_PATH`; if it
# isn't, then `find_package` won't find our package configuration file.
# TODO: Do we need to search in `CMAKE_PREFIX_PATH` as well?
#
# `CMAKE_SYSTEM_PREFIX_PATH` contains `CMAKE_INSTALL_PREFIX` by default.
# Users should not modify `CMAKE_SYSTEM_PREFIX_PATH`, so if
# `CMAKE_INSTALL_PREFIX` is missing, then someone is misbehaving.
# https://cmake.org/cmake/help/latest/variable/CMAKE_SYSTEM_PREFIX_PATH.html
# TODO: In light of this, do we need this search at all? Right now it serves
# as a sanity check.
list(FIND CMAKE_SYSTEM_PREFIX_PATH "${CMAKE_INSTALL_PREFIX}" INDEX)
if(INDEX LESS 0)
  message(WARNING
    " CMAKE_INSTALL_PREFIX not found in CMAKE_SYSTEM_PREFIX_PATH\n"
    " CMAKE_INSTALL_PREFIX=\"${CMAKE_INSTALL_PREFIX}\"\n"
    " CMAKE_SYSTEM_PREFIX_PATH=\"${CMAKE_SYSTEM_PREFIX_PATH}\""
  )
endif()

set(prefix "${CMAKE_INSTALL_PREFIX}")
if(${UNIX})
  set(prefix "${prefix}/lib/cmake")
endif()
set(FUTURE_INSTALL_EXPORTDIR "${prefix}")

if(UNIX AND NOT IS_DIRECTORY "${FUTURE_INSTALL_EXPORTDIR}")
  string(
    CONCAT msg
    "CMake package directory (${FUTURE_INSTALL_EXPORTDIR}) does not exist.\n"
    "CMake will create it with your umask."
  )
  message(WARNING "${msg}")
endif()

# TODO: Should we just create the directory for them?
