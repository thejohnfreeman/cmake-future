# We want to encapsulate the 80% case that has been described in multiple
# CMake tutorials:
#
# https://pabloariasal.github.io/2018/02/19/its-time-to-do-cmake-right/
# https://unclejimbo.github.io/2018/06/08/Modern-CMake-for-Library-Developers/
# https://cliutils.gitlab.io/modern-cmake/chapters/install/installing.html

include(CMakeParseArguments)

find_extension(FutureInstallDirs)
find_extension(future_export_sets)

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

  if("${scope}" STREQUAL PUBLIC)
    get_property(dependencies GLOBAL PROPERTY FUTURE_PROJECT_DEPENDENCIES)
    list(APPEND dependencies ${package_name})
    set_property(GLOBAL PROPERTY FUTURE_PROJECT_DEPENDENCIES "${dependencies}")
  elseif("${scope}" STREQUAL PRIVATE)
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
  set(package_configuration_directory "${CMAKE_BINARY_DIR}/${project_slug}")

  install(
    EXPORT ${FUTURE_DEFAULT_EXPORT_SET}
    FILE ${PROJECT_NAME}-targets.cmake
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION "${package_configuration_directory}"
  )

  include(CMakePackageConfigHelpers)

  get_property(dependencies GLOBAL PROPERTY FUTURE_PROJECT_DEPENDENCIES)
  future_get_export_set(components ${FUTURE_DEFAULT_EXPORT_SET})
  # list(TRANSFORM PREPEND) is in 3.11. Let's try to support 3.7 for now.
  foreach(target ${components})
    set(targets ${targets} ${PROJECT_NAME}::${target})
  endforeach()
  configure_package_config_file(
    "${extension_dir}/package-config.cmake.in"
    "${package_configuration_directory}/${PROJECT_NAME}-config.cmake"
    INSTALL_DESTINATION "${FUTURE_INSTALL_PACKAGEDIR}/${project_slug}"
  )

  write_basic_package_version_file(
    ${package_configuration_directory}/${PROJECT_NAME}-config-version.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
  )

  install(
    DIRECTORY "${package_configuration_directory}"
    DESTINATION "${FUTURE_INSTALL_PACKAGEDIR}"
  )
endfunction()
