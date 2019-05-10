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

find_package(FutureExportDir)
set(install_project_DIR "${CMAKE_CURRENT_LIST_DIR}")

# TODO: Remember the arguments passed to `project_dependency` and pass them to
# `find_dependency` in the package configuration file.
function(future_project_dependency PACKAGE_NAME)
  find_package("${PACKAGE_NAME}" ${ARGN})
  set(PROJECT_DEPENDENCIES ${PROJECT_DEPENDENCIES} "${PACKAGE_NAME}" PARENT_SCOPE)
endfunction(future_project_dependency PACKAGE_NAME)

function(future_project_dev_dependency PACKAGE_NAME)
  find_package("${PACKAGE_NAME}" ${ARGN})
endfunction(future_project_dev_dependency PACKAGE_NAME)

function(future_install_project)
  set(PROJECT_SLUG "${PROJECT_NAME}-${PROJECT_VERSION}")
  set(PROJECT_EXPORT_DIR "${CMAKE_BINARY_DIR}/${PROJECT_SLUG}")

  install(
    EXPORT ${PROJECT_NAME}-targets
    FILE ${PROJECT_NAME}-targets.cmake
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION "${PROJECT_EXPORT_DIR}"
  )

  include(CMakePackageConfigHelpers)

  configure_package_config_file(
    ${install_project_DIR}/package-config.cmake.in
    ${PROJECT_EXPORT_DIR}/${PROJECT_NAME}-config.cmake
    INSTALL_DESTINATION "${CMAKE_INSTALL_EXPORTDIR}/${PROJECT_SLUG}"
  )

  write_basic_package_version_file(
    ${PROJECT_EXPORT_DIR}/${PROJECT_NAME}-config-version.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
  )

  install(
    DIRECTORY "${PROJECT_EXPORT_DIR}"
    DESTINATION "${CMAKE_INSTALL_EXPORTDIR}"
  )
endfunction(future_install_project)
