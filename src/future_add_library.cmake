include(GNUInstallDirs)

find_extension(future_export_sets)

function(future_add_library target)
  add_library(${target} ${ARGN})
  add_library(${PROJECT_NAME}::${target} ALIAS ${target})
  future_install(
    TARGETS ${target}
    EXPORT ${FUTURE_DEFAULT_EXPORT_SET}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  )
endfunction()
