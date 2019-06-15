# Because CMake requires a naked, literal, direct call to `project` in the
# top-level `CMakeLists.txt`, we cannot offer our own replacement.
# Instead, we offer a complement.

function(future_project)
  # cmake_parse_arguments(prefix options one_value multi_value args...)
  cmake_parse_arguments(arg "" "LICENSE" "AUTHORS" ${ARGN})
  if(NOT arg_LICENSE)
    message(SEND_ERROR "A license is required.")
  endif()
  # These need to be cache variables so they can be accessible by an
  # autorecipe after the project is configured.
  set(PROJECT_LICENSE "${arg_LICENSE}" CACHE STRING "License")
  set(PROJECT_AUTHORS "${arg_AUTHORS}" CACHE STRING "Authors")
endfunction()
