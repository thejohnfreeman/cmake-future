# We want to encapsulate the 80% case that has been described in multiple
# CMake tutorials:
#
# https://pabloariasal.github.io/2018/02/19/its-time-to-do-cmake-right/
# https://unclejimbo.github.io/2018/06/08/Modern-CMake-for-Library-Developers/
# https://cliutils.gitlab.io/modern-cmake/chapters/install/installing.html

find_extension(FutureExportDir)

set(extension_dir "${CMAKE_CURRENT_LIST_DIR}")

# TODO: Remember the arguments passed to `future_add_dependency` and pass them to
# `find_dependency` in the package configuration file.
function(future_add_dependency scope package_name)
  # cmake_parse_arguments(prefix options one_value multi_value args...)
  cmake_parse_arguments(arg "OPTIONAL;REQUIRED" "" "" ${ARGN})

  if(arg_REQUIRED)
    message(SEND_ERROR "Dependencies are required by default. `REQUIRED` is not an option for ${package_name}.")
  endif()

  if(arg_OPTIONAL)
    set(arg_REQUIRED "")
  else()
    set(arg_REQUIRED "REQUIRED")
  endif()

  find_package("${package_name}" ${arg_REQUIRED} ${arg_UNPARSED_ARGUMENTS})

  if("${SCOPE}" STREQUAL PUBLIC)
    # TODO: Could we set a property on the project?
    set(PROJECT_DEPENDENCIES ${PROJECT_DEPENDENCIES} "${PACKAGE_NAME}" PARENT_SCOPE)
  elseif("${SCOPE}" STREQUAL PRIVATE)
    # Ok.
  else()
    message(SEND_ERROR "Unknown scope for dependency ${package_name}: ${scope}")
  endif()
endfunction()

function(future_install_project)
  set(project_slug "${PROJECT_NAME}-${PROJECT_VERSION}")
  # The export directory is where we install the package configuration file,
  # version file, and an export file. There is a final "install" destination,
  # chosen by the user, and an intermediate "build" destination, in the build
  # directory (inappropriately named `CMAKE_BINARY_DIR`), where we assemble
  # files for installation.
  set(cmake_build_exportdir "${CMAKE_BINARY_DIR}/${project_slug}")

  install(
    EXPORT ${PROJECT_NAME}_targets
    FILE ${PROJECT_NAME}-targets.cmake
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION "${cmake_build_exportdir}"
  )

  include(CMakePackageConfigHelpers)

  configure_package_config_file(
    "${extension_dir}/package-config.cmake.in"
    "${cmake_build_exportdir}/${PROJECT_NAME}-config.cmake"
    INSTALL_DESTINATION "${FUTURE_INSTALL_EXPORTDIR}/${project_slug}"
  )

  write_basic_package_version_file(
    ${cmake_build_exportdir}/${PROJECT_NAME}-config-version.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
  )

  install(
    DIRECTORY "${cmake_build_exportdir}"
    DESTINATION "${FUTURE_INSTALL_EXPORTDIR}"
  )
endfunction()
