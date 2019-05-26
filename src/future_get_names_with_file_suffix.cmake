# Example
# -------
#
#     get_names_with_file_suffix(test_names ".cpp")
#     foreach(test_name ${test_names})
#       add_executable("${test_name}" EXCLUDE_FROM_ALL "${test_name}.cpp")
#       target_link_libraries("${test_name}"
#         PRIVATE
#           boost::boost
#       )
#       add_test_from_target("${test_name}")
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
