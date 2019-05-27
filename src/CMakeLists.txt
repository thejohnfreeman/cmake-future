include(CMakePackageConfigHelpers)

find_extension(future_get_names_with_file_suffix)
find_extension(FutureInstallDirs)

# Every `.cmake` file is an extension. Get a list of their names.
future_get_names_with_file_suffix(package_names ".cmake")

add_custom_target(packages ALL)

# Install every extension as a package.
foreach(package_name ${package_names})
  set(
    package_configuration_directory
    "${CMAKE_BINARY_DIR}/cmake/${package_name}-${PROJECT_VERSION}"
  )
  string(TOLOWER ${package_name} package_name_lower)
  set(input "${CMAKE_CURRENT_SOURCE_DIR}/${package_name}.cmake")
  set(output "${package_configuration_directory}/${package_name_lower}-config.cmake")
  add_custom_command(
    OUTPUT "${output}"
    COMMAND
      "${CMAKE_COMMAND}"
      "-Dinput=${input}"
      "-Doutput=${output}"
      "-Dpackage_name=${package_name}"
      "-DPROJECT_VERSION=${PROJECT_VERSION}"
      -P add_package.cmake
    # `configure_file` will not touch its destination unless the output is
    # different. We want to update the build time unconditionally.
    COMMAND "${CMAKE_COMMAND}" -E touch "${output}"
    DEPENDS
      "${input}"
      "${CMAKE_SOURCE_DIR}/cmake/package-config.cmake.in"
      "${CMAKE_SOURCE_DIR}/cmake/add_package.cmake"
    # Let the `add_package` module assume it is working in its directory.
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/cmake"
  )
  add_custom_target(${package_name} DEPENDS "${output}")
  add_dependencies(packages ${package_name})
  # The package version file is always created with mode 0644. We only need to
  # re-generate it when the project version changes, and CMake implicitly
  # tracks a dependency between it and this `CMakeLists.txt`.
  write_basic_package_version_file(
    "${package_configuration_directory}/${package_name_lower}-config-version.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
  )
  install(
    DIRECTORY "${package_configuration_directory}"
    DESTINATION "${FUTURE_INSTALL_PACKAGEDIR}"
  )
endforeach()

# Special case: the template for `install_project`.
install(
  FILES package-config.cmake.in.in
  DESTINATION "${FUTURE_INSTALL_PACKAGEDIR}/future_install_project-${PROJECT_VERSION}"
  RENAME package-config.cmake.in
)
