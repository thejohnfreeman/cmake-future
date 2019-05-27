We define a **package configuration directory (PCD)** as a directory with
a name starting with `${PROJECT_NAME}` and containing these files:

- A **[package configuration file][] (PCF)**, `<PackageName>Config.cmake` or
  `<package-name>-config.cmake`, that imports the export file (see below) and
  defines `<package>_FOUND`.

- A **[package version file][]**, `<PackageName>ConfigVersion.cmake` or
  `<package-name>-config-version.cmake`, that checks the installed version for
  compatibility with the requested version.

- A **[package export file][]**, `<PackageName>Targets.cmake` or
  `<package-name>-targets.cmake`, that defines a target for each installed
  artifact.

[package configuration file]: https://cmake.org/cmake/help/latest/manual/cmake-packages.7.html#package-configuration-file
[package version file]: https://cmake.org/cmake/help/latest/manual/cmake-packages.7.html#package-version-file
[package export file]: https://cmake.org/cmake/help/latest/command/install.html#installing-exports

The `find_package` command searches a path of installation prefixes plus
a [fixed set of
suffixes](https://cmake.org/cmake/help/latest/command/find_package.html#search-procedure)
for PCFs.

When we install a package, we want:

- to keep all of the installed files within a PCD,
- to suffix the PCD with the version of the package (yielding the name
  `${PROJECT_NAME}-${PROJECT_VERSION}`), and
- to install the PCD in a place that it will be found (by default) by
  `find_package` commands in other projects, with no special intervention from
  the user.

We will assemble our PCD in the build directory (`CMAKE_BINARY_DIR`) and then
copy it into place with `install(DIRECTORY)`. For this last step, we want
a variable that we can pass as the `DESTINATION` argument to the
`install(DIRECTORY)` command: **`FUTURE_INSTALL_PACKAGEDIR`**.

    install(
      DIRECTORY "${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${PROJECT_VERSION}"
      DESTINATION "${FUTURE_INSTALL_PACKAGEDIR}"
    )

`FUTURE_INSTALL_PACKAGEDIR` needs to be **a relative path that can be
sandwiched between an installation prefix and
`${PROJECT_NAME}-${PROJECT_VERSION}` to yield one of the paths on the default
search path for `find_package`**.

Because we use a PCD and `find_package` is looking for the PCF *inside* of it,
**we must restrict ourselves to one of the paths searched by `find_package`
ending in `/<name>*/`**.

The default search path for `find_package` has changed over different
versions of CMake:

- Before 3.7, there was no common suffix to an installation prefix that
  `find_package` would search on both Unix and Windows.
- After 3.7, there are three (long) common suffixes.

If we don't want a version check, **we should restrict ourselves to one of the
paths searched both before and after version 3.7.**

We want to choose a path for each platform that feels conventional:

- On Windows, that is `<prefix>`.
- On Unix, that is `<prefix>/lib/cmake`.

Thus, we use a switch on platform (`UNIX` and `WIN32`) to choose **the right
value for `FUTURE_INSTALL_PACKAGEDIR`**:

- On Windows, it is `.`.
- On Unix, it is `lib/cmake`.

This installation path is useful for more than just package configuration
files; it is necessary for third-party CMake extension modules (like this
one). `include` searches the built-in modules and `CMAKE_MODULE_PATH`, which
is empty by default and should be assigned only by projects. There is no
place to install extension modules where they can be discovered by default,
i.e. without requiring projects to set `CMAKE_MODULE_PATH`. The only
alternative import function is `find_package`.

NOTE (A): CMake has the concept of "[package registry][]" which sounds like it
should be the preferred location to install package configuration
files/directories, but I have been told by insiders that it is discouraged.

[package registry]: https://cmake.org/cmake/help/v3.14/manual/cmake-packages.7.html#package-registry

NOTE (B): The default `CMAKE_INSTALL_PREFIX` has changed over different
versions of CMake, too, but it does not matter because `find_package` searches
relative to the prefix.

- Before 3.7, `CMAKE_INSTALL_PREFIX` was `C:\Program Files` on Windows.
- After 3.7, it became `C:\Program Files\${PROJECT_NAME}`.
