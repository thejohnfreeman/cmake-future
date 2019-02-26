# Third-party CMake extension modules must be imported with `find_package`, not
# `include`. `include` searches the built-in modules and `CMAKE_MODULE_PATH`,
# which is empty by default and should be assigned only by projects.
#
# The path searched by `find_package` differs by platform:
# https://cmake.org/cmake/help/v3.6/command/find_package.html
# We use a switch on platform (`UNIX` and `WIN32`) to choose the right
# installation path. We must set a value that works with the intended usage:
#
#     install(FILES ${PROJECT_NAME}-config.cmake
#       DESTINATION ${CMAKE_INSTALL_EXPORTDIR}/${PROJECT_NAME}-${PROJECT_VERSION}
#     )
#
if(${UNIX})
  include(GNUInstallDirs)
  set(CMAKE_INSTALL_EXPORTDIR ${CMAKE_INSTALL_LIBDIR}/cmake)
elseif(${WIN32})
  set(CMAKE_INSTALL_EXPORTDIR ${CMAKE_INSTALL_PREFIX})
else()
  message("unknown platform; CMAKE_INSTALL_EXPORTDIR not set")
endif()
