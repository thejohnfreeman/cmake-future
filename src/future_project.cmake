# Because CMake requires a naked, literal, direct call to `project` in the
# top-level `CMakeLists.txt`, we cannot offer our own replacement.
# Instead, we offer a complement.

function(future_project)
  # cmake_parse_arguments(prefix options one_value multi_value args...)
  cmake_parse_arguments(arg "" "LICENSE;REPOSITORY_URL" "AUTHORS" ${ARGN})

  if(NOT arg_LICENSE)
    message(SEND_ERROR "A license is required.")
  endif()

  if(NOT arg_REPOSITORY_URL)
    set(arg_REPOSITORY_URL "${CMAKE_PROJECT_HOMEPAGE_URL}")
  endif()

  set(${PROJECT_NAME}_FOUND TRUE PARENT_SCOPE)

  set(PROJECT_LICENSE "${arg_LICENSE}" PARENT_SCOPE)
  set(PROJECT_REPOSITORY_URL "${arg_REPOSITORY_URL}" PARENT_SCOPE)
  set(PROJECT_AUTHORS "${arg_AUTHORS}" PARENT_SCOPE)

  if(PROJECT_NAME STREQUAL CMAKE_PROJECT_NAME)
    # This is the top-level project. These need to be cache variables so they
    # can be accessible by an autorecipe after the project is configured.
    set(CMAKE_PROJECT_LICENSE "${arg_LICENSE}"
      CACHE STRING "License")
    set(CMAKE_PROJECT_REPOSITORY_URL "${arg_REPOSITORY_URL}"
      CACHE STRING "Repository")
    set(CMAKE_PROJECT_AUTHORS "${arg_AUTHORS}"
      CACHE STRING "Authors")
  endif()
endfunction()
