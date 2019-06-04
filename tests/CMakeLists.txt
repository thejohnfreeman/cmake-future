# It is tedious to write tests in CMake/CTest, so projects generally just
# use it to start another test framework, like googletest or doctest.
# We defer to pytest.

# In order to choose our own `CMAKE_INSTALL_PREFIX` for the tests,
# we must configure in yet another directory.
set(build_dir "${CMAKE_CURRENT_BINARY_DIR}/build")
# Our test installation runs from this directory, so just create it now.
make_directory("${build_dir}")

set(install_dir "${CMAKE_CURRENT_BINARY_DIR}/prefix")

# If we want to rebuild and reinstall whenever we test, instead of only once
# whenever the project is configured, we need to use fixtures.

add_custom_command(
  OUTPUT "${install_dir}"
  # Our installation expects this directory to exist.
  COMMAND "${CMAKE_COMMAND}" -E make_directory "${install_dir}/lib/cmake"
  COMMAND "${CMAKE_COMMAND}"
    "-DCMAKE_INSTALL_PREFIX=${install_dir}"
    "${CMAKE_SOURCE_DIR}"
  COMMAND "${CMAKE_COMMAND}" --build . --target install
  WORKING_DIRECTORY "${build_dir}"
)
add_custom_target(test_install DEPENDS "${install_dir}")

add_test(
  NAME test_install
  COMMAND
    "${CMAKE_COMMAND}" --build "${CMAKE_BINARY_DIR}" --target test_install
)
set_tests_properties(test_install PROPERTIES FIXTURES_SETUP install_fixture)

add_test(
  NAME pytest
  COMMAND pytest
  WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
)
set_property(
  TEST pytest
  APPEND PROPERTY ENVIRONMENT
  "CMAKE_PREFIX_PATH=${install_dir}"
)
set_tests_properties(pytest PROPERTIES FIXTURES_REQUIRED install_fixture)

# A project that just depends on the metapackage can test that our
# installation worked.
string(
  CONCAT text
  "cmake_minimum_required(VERSION 3.0)\n"
  "project(test LANGUAGES)\n"
  "find_package(${PROJECT_NAME} ${PROJECT_VERSION} EXACT REQUIRED)\n"
)
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/find_package/CMakeLists.txt" "${text}")

add_test(
  NAME find_package
  COMMAND "${CMAKE_COMMAND}" "-DCMAKE_PREFIX_PATH=${install_dir}" .
  WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/find_package"
)
set_tests_properties(find_package PROPERTIES FIXTURES_REQUIRED install_fixture)
