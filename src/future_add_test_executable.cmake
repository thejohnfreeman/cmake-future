# https://stackoverflow.com/a/56448477/618906
function(future_add_test_executable target)
  add_executable(${target} ${ARGN})
  add_test(NAME ${target} COMMAND ${target})
  set_tests_properties(
    ${target} PROPERTIES FIXTURES_REQUIRED ${target}_fixture
  )

  add_test(
    NAME ${target}_build
    COMMAND
      ${CMAKE_COMMAND}
      --build ${CMAKE_BINARY_DIR}
      --config $<CONFIG>
      --target ${target}
  )
  set_tests_properties(
    ${target}_build PROPERTIES FIXTURES_SETUP ${target}_fixture
  )
endfunction()
