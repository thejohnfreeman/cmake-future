# https://cliutils.gitlab.io/modern-cmake/chapters/intro/newcmake.html
cmake_minimum_required(VERSION 3.1)
# No languages, not even C/C++, the defaults.
project(future VERSION 1.0.1 LANGUAGES)

include(${CMAKE_SOURCE_DIR}/get_names_with_file_suffix.cmake)
# We need to install our extensions as packages into a location searched by
# `find_package`. The exact path depends on the platform. We use a switch on
# platform (`UNIX` and `WIN32`) to choose the right installation path. In
# fact, we package that switch as one of the extensions that we install, and
# we just import it here.
include(${CMAKE_SOURCE_DIR}/ExportDir.cmake)

# Every `.cmake` file is an extension. Get a list of their names.
get_names_with_file_suffix(PACKAGE_NAMES ".cmake")

# Install every extension as a package.
foreach(PACKAGE_NAME ${PACKAGE_NAMES})
  string(TOLOWER "${PACKAGE_NAME}-config.cmake" FILENAME)
  install(
    FILES
      "${PACKAGE_NAME}.cmake"
    DESTINATION
      "${CMAKE_INSTALL_EXPORTDIR}/${PACKAGE_NAME}-${PROJECT_VERSION}"
    RENAME
      "${FILENAME}"
  )
endforeach(PACKAGE_NAME ${PACKAGE_NAMES})

# Create a meta package named after this project that imports every extension
# using `find_dependency`. We build a string that has a `find_dependency` line
# for every extension, then we use `configure_file` to write those lines to
# a new file.
set(LINES "include(CMakeFindDependencyMacro)\n")
foreach(PACKAGE_NAME ${PACKAGE_NAMES})
  # `find_dependency` forwards the arguments from the `find_package` call that
  # found this package configuration file.
  # https://cmake.org/cmake/help/latest/module/CMakeFindDependencyMacro.html
  string(APPEND LINES "find_dependency(${PACKAGE_NAME})\n")
endforeach(PACKAGE_NAME ${PACKAGE_NAMES})
configure_file(
  "${PROJECT_NAME}-config.cmake.in"
  "${PROJECT_NAME}-config.cmake"
  @ONLY
)

# Install the meta package.
install(
  FILES
    "${CMAKE_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
  DESTINATION
    "${CMAKE_INSTALL_EXPORTDIR}/${PROJECT_NAME}-${PROJECT_VERSION}"
)

# The same file, plus a line that finds the meta package, can serve as
# a `CMakeLists.txt` for a project to test that our installation worked.
string(APPEND LINES "find_package(${PROJECT_NAME} REQUIRED)\n")
configure_file(
  "${PROJECT_NAME}-config.cmake.in"
  "CMakeLists.test.txt"
  @ONLY
)

enable_testing()

# Add a test that tries to import all of our extensions.
add_test(NAME find_packages
  COMMAND "${CMAKE_COMMAND}" -P "${CMAKE_BINARY_DIR}/CMakeLists.test.txt"
)
