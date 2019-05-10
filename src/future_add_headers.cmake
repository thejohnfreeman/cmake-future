include(CMakeParseArguments)
include(GNUInstallDirs)

# Should we instead use the PUBLIC_HEADER property of a library target?
# https://cmake.org/cmake/help/latest/command/install.html#installing-targets

function(future_add_headers TARGET)
  # No Boolean options or multi-value parameters.
  # Just two single-value parameters: `DIRECTORY` and `DESTINATION`.
  cmake_parse_arguments(ARG "" "DIRECTORY;DESTINATION" "" ${ARGN})
  # Set default arguments.
  if("${ARG_DIRECTORY}" STREQUAL "")
    set(ARG_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
  endif()
  if("${ARG_DESTINATION}" STREQUAL "")
    set(ARG_DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
  endif()

  # `DIRECTORY` must be absolute.
  if(NOT IS_ABSOLUTE "${ARG_DIRECTORY}")
    set(ARG_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${ARG_DIRECTORY}")
  endif()

  add_library(${TARGET} INTERFACE)
  add_library(${PROJECT_NAME}::${TARGET} ALIAS ${TARGET})
  target_include_directories(${TARGET}
    INTERFACE
      $<BUILD_INTERFACE:${ARG_DIRECTORY}>
      $<INSTALL_INTERFACE:${ARG_DESTINATION}>
  )
  install(TARGETS ${TARGET} EXPORT ${PROJECT_NAME}-targets)
  install(
    # This trailing slash ensures we install the contents of the directory,
    # not the directory itself.
    DIRECTORY ${ARG_DIRECTORY}/
    DESTINATION ${ARG_DESTINATION}
    # Do not install CMakeLists.txt.
    FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp"
  )
endfunction(future_add_headers TARGET)
