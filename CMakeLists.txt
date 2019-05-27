# https://cliutils.gitlab.io/modern-cmake/chapters/intro/newcmake.html
cmake_minimum_required(VERSION 3.1)
# No languages, not even C/C++, the defaults.
project(future VERSION 2.0.0 LANGUAGES)

macro(find_extension name)
  include("${CMAKE_SOURCE_DIR}/src/${name}.cmake")
endmacro()

add_subdirectory(src)
# Use properties of targets instead of setting variables that cross scope
# boundaries.
get_target_property(package_names packages MANUALLY_ADDED_DEPENDENCIES)

# We need to install our extensions as packages into a location searched by
# `find_package`. The exact path depends on the platform. We use a switch on
# platform (`UNIX` and `WIN32`) to choose the right installation path. In
# fact, we package that switch as one of the extensions that we install, and
# we just import it here.
find_extension(FutureInstallDirs)

# Create a meta package named after this project that imports every extension
# using `find_dependency`. We build a string that has a `find_dependency` line
# for every extension, then we use `configure_file` to write those lines to
# a new file.
set(
  package_configuration_directory
  "${CMAKE_BINARY_DIR}/cmake/${PROJECT_NAME}-${PROJECT_VERSION}"
)
set(text "include(CMakeFindDependencyMacro)\n")

foreach(package_name ${package_names})
  # `find_dependency` forwards the arguments from the `find_package` call that
  # found this package configuration file.
  # https://cmake.org/cmake/help/latest/module/CMakeFindDependencyMacro.html
  string(
    APPEND text
    "find_dependency(${package_name} ${PROJECT_VERSION} EXACT REQUIRED)\n"
  )
endforeach()

set(package_name ${PROJECT_NAME})
configure_file(
  cmake/package-config.cmake.in
  "${package_configuration_directory}/${PROJECT_NAME}-config.cmake"
  @ONLY
)

write_basic_package_version_file(
  "${package_configuration_directory}/${PROJECT_NAME}-config-version.cmake"
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion
)

# Install the meta package.
install(
  DIRECTORY "${package_configuration_directory}"
  DESTINATION "${FUTURE_INSTALL_PACKAGEDIR}"
)

# The same file, plus a line that finds the meta package, can serve as
# a `CMakeLists.txt` for a project to test that our installation worked.
string(
  CONCAT text
  "cmake_minimum_required(VERSION 3.0)\n"
  "project(test LANGUAGES)\n"
  "${text}"
  "find_package(${PROJECT_NAME} ${PROJECT_VERSION} EXACT REQUIRED)\n"
)
file(WRITE "${CMAKE_BINARY_DIR}/test/CMakeLists.txt" "${text}")

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
