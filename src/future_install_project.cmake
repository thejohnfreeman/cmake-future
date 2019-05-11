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

find_package(FutureExportDir REQUIRED)
set(install_project_DIR "${CMAKE_CURRENT_LIST_DIR}")

# TODO: Remember the arguments passed to `project_dependency` and pass them to
# `find_dependency` in the package configuration file.
function(future_add_dependency SCOPE PACKAGE_NAME)
  # One Boolean option: `OPTIONAL`.
  # (One forbidden option: `REQUIRED`. See below.)
  # No single- or multi-value parameters.
  cmake_parse_arguments(ARG "OPTIONAL;REQUIRED" "" "" ${ARGN})

  if(ARG_REQUIRED)
    message(SEND_ERROR "Dependencies are required by default. `REQUIRED` is not an option for ${PACKAGE_NAME}.")
  endif()

  if(ARG_OPTIONAL)
    set(ARG_REQUIRED "")
  else()
    set(ARG_REQUIRED "REQUIRED")
  endif()

  find_package("${PACKAGE_NAME}" ${ARG_REQUIRED} ${ARG_UNPARSED_ARGUMENTS})

  if("${SCOPE}" STREQUAL PUBLIC)
    # TODO: Could we set a property on the project?
    set(PROJECT_DEPENDENCIES ${PROJECT_DEPENDENCIES} "${PACKAGE_NAME}" PARENT_SCOPE)
  elseif("${SCOPE}" STREQUAL PRIVATE)
    # Ok.
  else()
    message(SEND_ERROR "Unknown scope for dependency ${PACKAGE_NAME}: ${SCOPE}")
  endif()
endfunction(future_add_dependency)

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