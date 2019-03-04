# We want to encapsulate the 80% case that has been described in multiple
# CMake tutorials:
#
# https://pabloariasal.github.io/2018/02/19/its-time-to-do-cmake-right/
# https://unclejimbo.github.io/2018/06/08/Modern-CMake-for-Library-Developers/
# https://cliutils.gitlab.io/modern-cmake/chapters/install/installing.html
#
# Users of this extension need to add their dependencies with
# `project_dependency` (named in the fashion of `target_<property>`) instead
# of `find_package`, and finish their installation with `install_project`.

find_package(ExportDir)
set(install_project_DIR "${CMAKE_CURRENT_LIST_DIR}")

function(project_dependency PACKAGE_NAME)
  find_package("${PACKAGE_NAME}" ${ARGN})
  set(PACKAGES_FOUND ${PACKAGES_FOUND} "${PACKAGE_NAME}" PARENT_SCOPE)
endfunction(project_dependency PACKAGE_NAME)

function(install_project)
  set(
    PROJECT_EXPORT_DIR
    "${CMAKE_INSTALL_EXPORTDIR}/${PROJECT_NAME}-${PROJECT_VERSION}"
  )

  install(
    EXPORT ${PROJECT_NAME}-targets
    FILE ${PROJECT_NAME}-targets.cmake
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION "${PROJECT_EXPORT_DIR}"
  )

  include(CMakePackageConfigHelpers)

  configure_package_config_file(
    ${install_project_DIR}/package-config.cmake.in
    ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-config.cmake
    INSTALL_DESTINATION "${PROJECT_EXPORT_DIR}"
  )

  write_basic_package_version_file(
    ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
  )

  install(
    FILES
      ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-config.cmake
      ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake
    DESTINATION "${PROJECT_EXPORT_DIR}"
  )
endfunction(install_project)