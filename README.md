# cmake-future

[![Travis: build on Linux and OSX](https://travis-ci.org/thejohnfreeman/cmake-future.svg?branch=master)](https://travis-ci.org/thejohnfreeman/cmake-future)
[![AppVeyor: build on Windows](https://ci.appveyor.com/api/projects/status/github/thejohnfreeman/cmake-future?branch=master&svg=true)](https://ci.appveyor.com/project/thejohnfreeman/cmake-future)

A collection of extensions (functions and special variables) that I think
should be included in CMake.


## Install

Both installation scripts accept a Git commit-ish (e.g. hash, branch, or tag)
as a parameter. With Bash, it is a positional parameter; with Powershell, it
must be an environment variable. You can see how to pass these parameters in
the one-liners below. If not given, the default value is `master`. This lets
you fix the version you want to install, which can be handy, e.g., in
a continuous integration environment.


### Linux and OSX

You'll need `sudo` to install these extensions in the right place. You can
read [the script](https://github.com/thejohnfreeman/cmake-future/blob/master/install.sh)
to see that it's very short and not dangerous.

```sh
$ curl -L https://raw.githubusercontent.com/thejohnfreeman/cmake-future/master/install.sh \
  | sudo env "PATH=$PATH" bash -s -- master
```

### Windows

You'll need Administrator privileges to install these extensions in the right
place. You can read [the
script](https://github.com/thejohnfreeman/cmake-future/blob/master/install.ps)
to see that it's very short and not dangerous.

```powershell
> Invoke-RestMethod https://raw.githubusercontent.com/thejohnfreeman/cmake-future/master/install.ps `
  | powershell -Command "`$env:commit = 'master'; powershell -Command -"
```

### From source

```sh
mkdir build
cd build
cmake ..
sudo cmake --build . --target install
```


## Use

After installation, each extension can be imported separately by name with
`find_package(<name>)`, or you can import all of them at once with
`find_package(future)`. Extensions are semantically versioned, so you can make
sure you get the latest version you have installed by using [the version sort
capability](https://cmake.org/cmake/help/v3.7/command/find_package.html)
added to `find_package` [in CMake
3.7](https://blog.kitware.com/cmake-3-7-0-rc3-is-now-ready/):

```
set(CMAKE_FIND_PACKAGE_SORT_ORDER NATURAL)
set(CMAKE_FIND_PACKAGE_SORT_DIRECTION DEC)
find_package(future)
```


<a id="conventions" />

## Conventions

These extensions respect and embody a few popular conventions that the
[community](https://www.youtube.com/watch?v=eC9-iRN2b04)
[seems](https://pabloariasal.github.io/2018/02/19/its-time-to-do-cmake-right/)
to
[consider](https://unclejimbo.github.io/2018/06/08/Modern-CMake-for-Library-Developers/)
best practices. In the spirit of ["convention over
configuration"](https://en.wikipedia.org/wiki/Convention_over_configuration),
they try to minimize boilerplate, which helps newcomers get up and running
sooner and helps experienced users avoid common pitfalls.

- All targets should be
  [aliased](https://cmake.org/cmake/help/latest/command/add_library.html#alias-libraries)
  and exported under a **Project
  [Namespace](https://stackoverflow.com/a/48526017/618906)** called
  `${PROJECT_NAME}::`. That way, target `b` that depends on target `a` can use
  the same syntax (`target_link_libraries(b project::a)`) whether `b` is in
  the same project or in another project.
- All exported targets should be added to the **Default Export Set** called
  `${PROJECT_NAME}_targets`.


## Modules

The section headings below link to their corresponding module file so that you
can double-check its implementation.


### [`future_project`](./src/future_project.cmake)

```cmake
future_project(LICENSE <license> [AUTHORS <author>...])
```

```cmake
future_project(
  LICENSE "ISC"
  AUTHORS "John Freeman <jfreeman08@gmail.com>"
)
```

Sets cache variables for common project metadata that is not set by
[`project`][project]. These variables are used by my Conan
[autorecipe][autorecipes] to set the corresponding attributes on the package.

[project]: https://cmake.org/cmake/help/latest/command/project.html
[autorecipes]: https://github.com/thejohnfreeman/autorecipes

Because CMake requires the top-level `CMakeLists.txt` to contain a literal,
direct call to the `project` command, no extension can substitute for it.
Instead, this command complements it.


### [`future_export_sets`](./src/future_export_sets.cmake)

```cmake
${FUTURE_DEFAULT_EXPORT_SET}
future_install(...)
future_get_export_set(<variable> [<name>])
```

```cmake
future_get_export_set(export_set ${FUTURE_DEFAULT_EXPORT_SET})
```

This extension exports a few pieces:

- A variable `FUTURE_DEFAULT_EXPORT_SET` with the value
  `${PROJECT_NAME}_targets`. The sibling extensions `future_add_headers` and
  `future_add_library` will add their installed targets to this export set.
  The sibling extension `future_install_project` uses this export set for the
  package's [export
  file](https://cmake.org/cmake/help/latest/command/install.html#export).
- A function `future_install` that wraps the built-in
  [`install`](https://cmake.org/cmake/help/latest/command/install.html) but
  records the targets added to each export set. You only need to use this
  function for the `future_install(TARGETS <target>... EXPORT <export-set>)`
  form, but it won't hurt to use it for every form. (This function cannot be
  named `install` because it is presently impossible to safely call an
  overridden function.)
- A function `future_get_export_set` that will get the list of targets in the
  export set `<name>` and store it in `<variable>`.


### [`future_add_headers`](./src/future_add_headers.cmake)

```cmake
future_add_headers(<name> [DIRECTORY <dir>] [DESTINATION <dir>])
```

```cmake
future_add_headers(${PROJECT_NAME}_headers DIRECTORY include)
```

- Adds an `INTERFACE` library target called `<name>` for the headers in
  `DIRECTORY` (which defaults to `CMAKE_CURRENT_SOURCE_DIR`)
- Aliases the library in the [Project Namespace](#conventions).
- Adds the library to the [Default Export Set](#conventions).
- Installs the headers at `DESTINATION` (default
  [`CMAKE_INSTALL_INCLUDEDIR`](https://cmake.org/cmake/help/latest/module/GNUInstallDirs.html#result-variables)).


### [`future_add_library`](./src/future_add_library.cmake)

```cmake
future_add_library(<name> [...])
```

```cmake
future_add_library(${PROJECT_NAME} a.cpp b.cpp)
target_link_libraries(${PROJECT_NAME} PUBLIC fmt::fmt)
```

- Adds a library target called `<name>`, passing any remaining arguments to
  [`add_library`](https://cmake.org/cmake/help/latest/command/add_library.html).
- Aliases the library in the [Project Namespace](#conventions).
- Adds the library to the [Default Export Set](#conventions).
- Installs the library to destinations according to
  [`GNUInstallDirs`](https://cmake.org/cmake/help/latest/module/GNUInstallDirs.html).


### [`future_add_test_executable`](./src/future_add_test_executable.cmake)

```cmake
future_add_test_executable(<name> [...])
```

```cmake
enable_testing() # Do not forget this!
future_add_test_executable(my_test EXCLUDE_FROM_ALL my_test.cpp)
```

Like `add_executable` plus `add_test`, this will add an executable target
called `<name>` as a test, but unlike `add_test`, it will add a test fixture
that rebuilds the target if its dependencies have changed. Inspired by
[this answer on Stack Overflow](https://stackoverflow.com/a/10824578/618906).
With this, you will never run out-of-date tests. Remaining arguments are
passed through to
[`add_executable`](https://cmake.org/cmake/help/latest/command/add_executable.html).


### [`future_get_names_with_file_suffix`](./src/future_get_names_with_file_suffix.cmake)

```cmake
future_get_names_with_file_suffix(<variable> <suffix>)
```

```cmake
future_get_names_with_file_suffix(tests ".cpp")
foreach(test ${tests})
  future_add_test_executable(${test} EXCLUDE_FROM_ALL ${test}.cpp)
  target_link_libraries(${test} doctest::doctest)
endforeach()
```

This will search the current source directory for files with the given suffix,
extract their filenames (minus the suffix), and collect them as a list in the
given `<variable>`.


### [`future_get_targets`](./src/future_get_targets.cmake)

```cmake
future_get_targets(<variable> [<directory>])
```

Get a list of all the targets defined in `<directory>` or its subdirectories
and store it in `<variable>`. If no `<directory>` is given, the current
directory will be used. The list does not include any [Imported
Targets](https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#imported-targets)
or [Alias
Targets](https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#alias-targets).
This is built on top of
[`BUILDSYSTEM_TARGETS`](https://cmake.org/cmake/help/latest/prop_dir/BUILDSYSTEM_TARGETS.html)
and thus subject to all of the same limitations.


### [`FutureInstallDirs`](./src/FutureInstallDirs.cmake)

```cmake
${FUTURE_INSTALL_PACKAGEDIR}
${FUTURE_INSTALL_FULL_PACKAGEDIR}
```

This extension is modeled after
[`GNUInstallDirs`](https://cmake.org/cmake/help/latest/module/GNUInstallDirs.html),
and it exports "missing" variables.
Like `GNUInstallDirs`, there are two versions of each variable:

- `FUTURE_INSTALL_<dir>`: A relative path suitable as the `DESTINATION`
  argument to an
  [`install`](https://cmake.org/cmake/help/latest/command/install.html)
  command.

- `FUTURE_INSTALL_FULL_<dir>`: An absoluate path constructed by appending the
  corresponding `FUTURE_INSTALL_<dir>` to `CMAKE_INSTALL_PREFIX`.

where `<dir>` is one of:

- `PACKAGEDIR`: A relative path that can be sandwiched between the default
  `CMAKE_INSTALL_PREFIX` and a directory name starting with `${PROJECT_NAME}`
  to yield one of the paths on the default search path for `find_package`.
  ([Read more.](./src/FUTURE_INSTALL_PACKAGEDIR.md))

```cmake
install(
  EXPORT ${PROJECT_NAME}_targets
  FILE ${PROJECT_NAME}-targets.cmake
  NAMESPACE ${PROJECT_NAME}::
  DESTINATION "${FUTURE_INSTALL_PACKAGEDIR}/${PROJECT_NAME}-${PROJECT_VERSION}"
)
```

(This example is based on [this pattern for writing package
exports](https://unclejimbo.github.io/2018/06/08/Modern-CMake-for-Library-Developers/#Install-and-Export-the-Target).)


### [`future_install_project`](./src/future_install_project.cmake)

```cmake
future_add_dependency([PUBLIC|PRIVATE] <name> [OPTIONAL] [...])
future_install_project()
```

```cmake
future_add_dependency(PUBLIC Boost)
future_add_dependency(PRIVATE doctest)

future_add_library(my_library my_library.cpp)
target_link_libraries(my_library PUBLIC Boost::Boost)

future_add_test_executable(my_test my_test.cpp)
target_link_libraries(my_test
  ${PROJECT_NAME}::my_library
  doctest::doctest
)

future_install_project()
```

This module has a few functions to help you install your project according to
the [best practices of Modern
CMake](https://unclejimbo.github.io/2018/06/08/Modern-CMake-for-Library-Developers/#Install-and-Export-the-Target).

- `future_add_dependency` works like `find_package`. `PUBLIC` dependencies
  are imported by your package configuration file (using
  [`find_dependency`](https://cmake.org/cmake/help/latest/module/CMakeFindDependencyMacro.html)),
  so that your dependents will transitively import them. `PRIVATE`
  dependencies are not. Good candidates for `PRIVATE` dependencies are
  build-time-only dependencies like test
  frameworks. Dependencies are required by default; you can pass `OPTIONAL` if
  you want CMake to continue even when the dependency cannot be found. All
  remaining arguments will be passed through to
  [`find_package`](https://cmake.org/cmake/help/latest/command/find_package.html).

- You should add all your dependencies near the beginning of your top-level
  `CMakeLists.txt`, much like you where you would put `#include`s or `import`
  statements in a program, and for the same reasons. Before calling the next
  and last function, remember to add any targets you want to the [Default
  Export Set](#conventions) (`${PROJECT_NAME}_targets`).

- `future_install_project` installs your project. It creates a [package
  configuration
  file](https://cmake.org/cmake/help/latest/manual/cmake-packages.7.html#config-file-packages);
  a [package version
  file](https://cmake.org/cmake/help/latest/module/CMakePackageConfigHelpers.html#generating-a-package-version-file)
  (using the `SameMajorVersion` policy to approximate [semantic
  versioning](https://semver.org/)); and an [export
  file](https://cmake.org/cmake/help/latest/command/install.html#export) for
  the Default Export Set (scoped to the [Project Namespace](#conventions)).
