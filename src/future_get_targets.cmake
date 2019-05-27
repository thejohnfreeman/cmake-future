function(future_get_targets variable)
  set(directory ${ARGN})

  get_property(targets DIRECTORY ${directory} PROPERTY BUILDSYSTEM_TARGETS)

  get_property(subdirectories DIRECTORY ${directory} PROPERTY SUBDIRECTORIES)
  foreach(subdirectory ${subdirectories})
    future_get_targets(subtargets ${subdirectory})
    list(APPEND targets ${subtargets})
  endforeach()

  set(${variable} "${targets}" PARENT_SCOPE)
endfunction()
