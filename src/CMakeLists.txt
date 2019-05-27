find_extension(future_get_names_with_file_suffix)
find_extension(FutureExportDir)

# Every `.cmake` file is an extension. Get a list of their names.
future_get_names_with_file_suffix(PACKAGE_NAMES ".cmake")

include(CMakePackageConfigHelpers)

add_custom_target(packages ALL)

# Install every extension as a package.
foreach(PACKAGE_NAME ${PACKAGE_NAMES})
  set(
    PACKAGE_EXPORT_DIR
    "${CMAKE_BINARY_DIR}/cmake/${PACKAGE_NAME}-${PROJECT_VERSION}"
  )
  string(TOLOWER ${PACKAGE_NAME} PACKAGE_NAME_LOWER)
  set(INPUT "${CMAKE_CURRENT_SOURCE_DIR}/${PACKAGE_NAME}.cmake")
  set(OUTPUT "${PACKAGE_EXPORT_DIR}/${PACKAGE_NAME_LOWER}-config.cmake")
  add_custom_command(
    OUTPUT "${OUTPUT}"
    COMMAND
      "${CMAKE_COMMAND}"
      "-DINPUT=${INPUT}"
      "-DOUTPUT=${OUTPUT}"
      "-DPACKAGE_NAME=${PACKAGE_NAME}"
      "-DPROJECT_VERSION=${PROJECT_VERSION}"
      -P add_package.cmake
    # `configure_file` will not touch its destination unless the output is
    # different. We want to update the build time unconditionally.
    COMMAND "${CMAKE_COMMAND}" -E touch "${OUTPUT}"
    DEPENDS
      "${INPUT}"
      "${CMAKE_SOURCE_DIR}/cmake/package-config.cmake.in"
      "${CMAKE_SOURCE_DIR}/cmake/add_package.cmake"
    # Let the `add_package` module assume it is working in its directory.
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/cmake"
  )
  add_custom_target(${PACKAGE_NAME} DEPENDS "${OUTPUT}")
  add_dependencies(packages ${PACKAGE_NAME})
  # The package version file is always created with mode 0644. We only need to
  # re-generate it when the project version changes, and CMake implicitly
  # tracks a dependency between it and this `CMakeLists.txt`.
  write_basic_package_version_file(
    "${PACKAGE_EXPORT_DIR}/${PACKAGE_NAME_LOWER}-config-version.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
  )
  install(
    DIRECTORY "${PACKAGE_EXPORT_DIR}"
    DESTINATION "${FUTURE_INSTALL_EXPORTDIR}"
  )
endforeach(PACKAGE_NAME ${PACKAGE_NAMES})

# Special case: the template for `install_project`.
install(
  FILES package-config.cmake.in.in
  DESTINATION "${FUTURE_INSTALL_EXPORTDIR}/future_install_project-${PROJECT_VERSION}"
  RENAME package-config.cmake.in
)
