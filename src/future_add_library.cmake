include(CMakeParseArguments)
include(GNUInstallDirs)

function(future_add_library TARGET)
  add_library(${TARGET} ${ARGN})
  add_library(${PROJECT_NAME}::${TARGET} ALIAS ${TARGET})
  install(
    TARGETS ${TARGET}
    EXPORT ${PROJECT_NAME}-targets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  )
endfunction(future_add_library TARGET)
