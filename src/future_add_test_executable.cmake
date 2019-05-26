# https://stackoverflow.com/a/10824578/618906
function(future_add_test_executable target)
  add_executable(${target} ${ARGN})
  add_test(
    NAME ${target}_build
    COMMAND
      ${CMAKE_COMMAND}
        --build ${CMAKE_BINARY_DIR}
        --target ${target}
        --config $<CONFIG>
    )
  add_test(NAME ${target} COMMAND ${target})
  set_tests_properties(${target} PROPERTIES DEPENDS ${target}_build)
endfunction()
