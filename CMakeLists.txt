# https://cliutils.gitlab.io/modern-cmake/chapters/intro/newcmake.html
cmake_minimum_required(VERSION 3.1)
# No languages, not even C/C++, the defaults.
project(future VERSION 1.0.2 LANGUAGES)

add_subdirectory(src)
# Use properties of targets instead of setting variables that cross scope
# boundaries.
get_target_property(PACKAGE_NAMES packages MANUALLY_ADDED_DEPENDENCIES)

# We need to install our extensions as packages into a location searched by
# `find_package`. The exact path depends on the platform. We use a switch on
# platform (`UNIX` and `WIN32`) to choose the right installation path. In
# fact, we package that switch as one of the extensions that we install, and
# we just import it here.
include(src/FutureExportDir.cmake)

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
  COMMAND
    "${CMAKE_COMMAND}"
    "-DCMAKE_PREFIX_PATH=${CMAKE_INSTALL_PREFIX}"
    "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}"
    .
  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/test"
)
