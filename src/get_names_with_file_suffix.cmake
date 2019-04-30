# Example
# -------
#
#     get_names_with_file_suffix(TEST_NAMES ".cpp")
#     foreach(TEST_NAME ${TEST_NAMES})
#       add_executable("${TEST_NAME}" EXCLUDE_FROM_ALL "${TEST_NAME}.cpp")
#       target_link_libraries("${TEST_NAME}"
#         PRIVATE
#           boost::boost
#       )
#       add_test_from_target("${TEST_NAME}")
#     endforeach(TEST_NAME ${TEST_NAMES})
#
function(get_names_with_file_suffix VAR SUFFIX)
  set(NAMES "")
  file(GLOB PATHS "*${SUFFIX}")
  foreach(PATH ${PATHS})
    get_filename_component(FILENAME "${PATH}" NAME)
    string(REPLACE "${SUFFIX}" "" NAME "${FILENAME}")
    list(APPEND NAMES "${NAME}")
  endforeach(PATH ${PATHS})
  set(${VAR} "${NAMES}" PARENT_SCOPE)
endfunction(get_names_with_file_suffix VAR SUFFIX)
