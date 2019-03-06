# https://cliutils.gitlab.io/modern-cmake/chapters/intro/newcmake.html
cmake_minimum_required(VERSION 3.1)
# No languages, not even C/C++, the defaults.
project(future VERSION 1.0.2 LANGUAGES)

include(${CMAKE_SOURCE_DIR}/get_names_with_file_suffix.cmake)
# We need to install our extensions as packages into a location searched by
# `find_package`. The exact path depends on the platform. We use a switch on
# platform (`UNIX` and `WIN32`) to choose the right installation path. In
# fact, we package that switch as one of the extensions that we install, and
# we just import it here.
include(${CMAKE_SOURCE_DIR}/ExportDir.cmake)

# Every `.cmake` file is an extension. Get a list of their names.
get_names_with_file_suffix(PACKAGE_NAMES ".cmake")

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
      -P add_package.cmake
    # `configure_file` will not touch its destination unless the output is
    # different. We want to update the build time unconditionally.
    COMMAND "${CMAKE_COMMAND}" -E touch "${OUTPUT}"
    DEPENDS "${INPUT}" cmake/package-config.cmake.in cmake/add_package.cmake
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
  )
  add_custom_target(${PACKAGE_NAME} DEPENDS "${OUTPUT}")
  add_dependencies(packages ${PACKAGE_NAME})
  # The package version file is always created with mode 0644. We only need to
  # re-generate it when the project version changes, and CMake implicitly
  # tracks a dependency between it and this `CMakeLists.txt`.
  write_basic_package_version_file(
    "${PACKAGE_EXPORT_DIR}/${PACKAGE_NAME_LOWER}-config-version.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
  )
  install(
    DIRECTORY "${PACKAGE_EXPORT_DIR}"
    DESTINATION "${CMAKE_INSTALL_EXPORTDIR}"
  )
endforeach(PACKAGE_NAME ${PACKAGE_NAMES})

# Special case: the template for `install_project`.
install(
  FILES package-config.cmake.in.in
  DESTINATION "${CMAKE_INSTALL_EXPORTDIR}/install_project-${PROJECT_VERSION}"
  RENAME package-config.cmake.in
)

# Create a meta package named after this project that imports every extension
# using `find_dependency`. We build a string that has a `find_dependency` line
# for every extension, then we use `configure_file` to write those lines to
# a new file.
set(
  PROJECT_EXPORT_DIR
  "${CMAKE_BINARY_DIR}/cmake/${PROJECT_NAME}-${PROJECT_VERSION}"
)
set(TEXT "include(CMakeFindDependencyMacro)\n")
foreach(PACKAGE_NAME ${PACKAGE_NAMES})
  # `find_dependency` forwards the arguments from the `find_package` call that
  # found this package configuration file.
  # https://cmake.org/cmake/help/latest/module/CMakeFindDependencyMacro.html
  string(
    APPEND TEXT
    "find_dependency(${PACKAGE_NAME} ${PROJECT_VERSION} EXACT REQUIRED)\n"
  )
endforeach(PACKAGE_NAME ${PACKAGE_NAMES})
set(PACKAGE_NAME ${PROJECT_NAME})
configure_file(
  cmake/package-config.cmake.in
  "${PROJECT_EXPORT_DIR}/${PROJECT_NAME}-config.cmake"
  @ONLY
)

write_basic_package_version_file(
  "${PROJECT_EXPORT_DIR}/${PROJECT_NAME}-config-version.cmake"
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY AnyNewerVersion
)

# Install the meta package.
install(
  DIRECTORY "${PROJECT_EXPORT_DIR}"
  DESTINATION "${CMAKE_INSTALL_EXPORTDIR}"
)

# The same file, plus a line that finds the meta package, can serve as
# a `CMakeLists.txt` for a project to test that our installation worked.
string(
  CONCAT TEXT
  "cmake_minimum_required(VERSION 3.0)\n"
  "project(test LANGUAGES)\n"
  "${TEXT}"
  "find_package(${PROJECT_NAME} ${PROJECT_VERSION} EXACT REQUIRED)\n"
)
file(WRITE "${CMAKE_BINARY_DIR}/test/CMakeLists.txt" "${TEXT}")

enable_testing()

# Add a test that tries to import all of our extensions.
add_test(
  NAME find_packages
  COMMAND "${CMAKE_COMMAND}" .
  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/test"
)
