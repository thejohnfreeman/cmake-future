# https://stackoverflow.com/a/10824578/618906
function(add_test_from_target TARGET)
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
endfunction(add_test_from_target TARGET)
