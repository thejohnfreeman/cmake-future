include(CMakeParseArguments)

set(FUTURE_PROJECT_EXPORT_SET ${PROJECT_NAME}_targets)

# Wrap the built-in `install` function to record exported targets.
function(future_install type)
  if(type STREQUAL TARGETS)
    # cmake_parse_arguments(<prefix> <options> <one-value> <multi-value>)
    cmake_parse_arguments(arg "" "EXPORT" "TARGETS" ${ARGV})
    if(arg_EXPORT)
      set(name FUTURE_EXPORT_SET_${arg_EXPORT})
      get_property(export_set GLOBAL PROPERTY ${name})
      list(APPEND export_set ${arg_TARGETS})
      set_property(GLOBAL PROPERTY ${name} "${export_set}")
    endif()
  endif()
  install(${ARGV})
endfunction()

# Get the list of targets in export set `<name>` and store it in `<variable>`.
function(future_get_export_set variable)
  set(name "${ARGN}")
  if(NOT name)
    set(name ${FUTURE_PROJECT_EXPORT_SET})
  endif()
  get_property(export_set GLOBAL PROPERTY FUTURE_EXPORT_SET_${name})
  set(${variable} "${export_set}" PARENT_SCOPE)
endfunction()
