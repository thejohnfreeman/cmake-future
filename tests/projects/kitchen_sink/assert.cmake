# A function to make assertions more readable.
function(assert variable)
  set(argn ${ARGN})

  message("ARGC = ${ARGC}")
  message("argn = ${argn}")

  # Subtract 1 to get the size of `ARGN`, then 1 more to get the operator
  # length (all but the expected value).
  math(EXPR oplen "${ARGC} - 1 - 1")
  list(SUBLIST argn 0 "${oplen}" operator)
  list(SUBLIST argn "${oplen}" -1 expected)

  message("oplen = ${oplen}")
  message("expected = ${expected}")
  message("operator = ${operator}")

  # After this conditional, `maybe_not` has either "NOT" or "" and `operator`
  # has the rest of the operator that was passed to us.
  list(GET operator 0 maybe_not)
  if(maybe_not STREQUAL "NOT")
    list(SUBLIST operator 1 -1 operator)
  else()
    set(maybe_not "")
  endif()

  if(${maybe_not} "${${variable}}" ${operator} "${expected}")
    # We cannot double negate, so just leave this branch empty.
  else()
    list(JOIN operator " " operator)
    message(
      SEND_ERROR
      "${variable} has unexpected value: "
      "\"${${variable}}\" NOT ${operator} \"${expected}\""
    )
  endif()
endfunction()

set(actual "1;2;3")
assert(actual STREQUAL "1;2;3")
assert(actual NOT STREQUAL "1;2;3;4;5")
assert(actual NOT STREQUAL "1")
