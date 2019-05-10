# https://stackoverflow.com/a/10824578/618906
function(future_add_test_executable TARGET)
  add_executable(${TARGET} ${ARGN})
  add_test(
    NAME ${TARGET}_build
    COMMAND
      ${CMAKE_COMMAND}
        --build ${CMAKE_BINARY_DIR}
        --target ${TARGET}
        --config $<CONFIG>
    )
  add_test(NAME ${TARGET} COMMAND ${TARGET})
  set_tests_properties(${TARGET} PROPERTIES DEPENDS ${TARGET}_build)
endfunction(future_add_test_executable TARGET)
