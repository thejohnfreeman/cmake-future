include(CMakeParseArguments)
include(GNUInstallDirs)

function(future_add_library target)
  add_library(${target} ${ARGN})
  add_library(${PROJECT_NAME}::${target} ALIAS ${target})
  install(
    TARGETS ${target}
    EXPORT ${PROJECT_NAME}_targets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  )
endfunction()
