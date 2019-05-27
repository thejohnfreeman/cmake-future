# Example
# -------
#
#     get_names_with_file_suffix(tests ".cpp")
#     foreach(test ${tests})
#       add_executable(${test} EXCLUDE_FROM_ALL ${test}.cpp)
#       target_link_libraries(${test} doctest::doctest)
#       add_test_from_target(${test})
#     endforeach()
#
function(future_get_names_with_file_suffix variable suffix)
  set(names "")
  file(GLOB paths "*${suffix}")
  foreach(path ${paths})
    get_filename_component(filename "${path}" NAME)
    string(REPLACE "${suffix}" "" name "${filename}")
    list(APPEND names "${name}")
  endforeach()
  set(${variable} "${names}" PARENT_SCOPE)
endfunction()
