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

# Package configuration directories should be installed like any other file:
# under `CMAKE_INSTALL_PREFIX`. We check that the `CMAKE_INSTALL_PREFIX` can
# be found in the `CMAKE_SYSTEM_PREFIX_PATH`; if it isn't, then `find_package`
# won't find our package configuration file.
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

set(packagedir "lib/cmake")
if(WIN32)
  set(packagedir ".")
endif()
set(
  FUTURE_INSTALL_PACKAGEDIR
  "${packagedir}"
  CACHE STRING
  "`DESTINATION` to `install` package configuration directories."
)
set(
  FUTURE_INSTALL_FULL_PACKAGEDIR
  "${CMAKE_INSTALL_PREFIX}/${FUTURE_INSTALL_PACKAGEDIR}"
  CACHE STRING
  "Absolute path corresponding to `FUTURE_INSTALL_PACKAGEDIR`."
)

# We only want to diagnose this problem once, not every time this module is
# included. Use a global flag to track whether it has been diagnosed already.
get_property(diagnosed GLOBAL PROPERTY FUTURE_INSTALL_PACKAGEDIR_DIAGNOSED)
if(
    NOT diagnosed
    AND UNIX
    AND NOT IS_DIRECTORY "${FUTURE_INSTALL_FULL_PACKAGEDIR}"
)
  string(
    CONCAT msg
    "CMake package directory (${FUTURE_INSTALL_FULL_PACKAGEDIR}) does not exist.\n"
    "CMake will create it with your umask."
  )
  message(WARNING "${msg}")
  set_property(GLOBAL PROPERTY FUTURE_INSTALL_PACKAGEDIR_DIAGNOSED TRUE)
endif()

# TODO: Should we just create the directory for them?
