include(CMakeParseArguments)
include(GNUInstallDirs)

find_extension(future_export_sets)

# Should we instead use the PUBLIC_HEADER property of a library target?
# https://cmake.org/cmake/help/latest/command/install.html#installing-targets

function(future_add_headers target)
  # No Boolean options or multi-value parameters.
  # Just two single-value parameters: `DIRECTORY` and `DESTINATION`.
  cmake_parse_arguments(arg "" "DIRECTORY;DESTINATION" "" ${ARGN})
  # Set default arguments.
  if("${arg_DIRECTORY}" STREQUAL "")
    set(arg_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
  endif()
  if("${arg_DESTINATION}" STREQUAL "")
    set(arg_DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
  endif()

  # `DIRECTORY` must be absolute.
  if(NOT IS_ABSOLUTE "${arg_DIRECTORY}")
    set(arg_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${arg_DIRECTORY}")
  endif()

  add_library(${target} INTERFACE)
  add_library(${PROJECT_NAME}::${target} ALIAS ${target})
  target_include_directories(${target}
    INTERFACE
      $<BUILD_INTERFACE:${arg_DIRECTORY}>
      $<INSTALL_INTERFACE:${arg_DESTINATION}>
  )
  future_install(TARGETS ${target} EXPORT ${PROJECT_NAME}_targets)
  install(
    # This trailing slash ensures we install the contents of the directory,
    # not the directory itself.
    DIRECTORY ${arg_DIRECTORY}/
    DESTINATION ${arg_DESTINATION}
    # Do not install CMakeLists.txt.
    FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp"
  )
endfunction()
