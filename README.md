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


### `add_test_from_target`

```cmake
enable_testing()
add_executable(my_test EXCLUDE_FROM_ALL ...)
add_test_from_target(my_test) # instead of add_test(my_test)
```

Like `add_test`, this will add an executable target as a test, but unlike
`add_test`, it will add an additional "test" that rebuilds the target if its
dependencies have changed. Inspired by [this answer on Stack
Overflow](https://stackoverflow.com/a/10824578/618906).


### `get_names_with_file_suffix`

```cmake
get_names_with_file_suffix(MY_TESTS ".cpp")
foreach(MY_TEST ${MY_TESTS})
  add_executable(${MY_TEST} EXCLUDE_FROM_ALL ${MY_TEST}.cpp)
  target_link_libraries(${MY_TEST}
    PRIVATE
      gtest::gtest
  )
  add_test_from_target(${MY_TEST})
endforeach(MY_TEST ${MY_TESTS})
```

This will search the current source directory for files with the given suffix,
extract their filenames (minus the suffix), and collect them in a list
variable of the given name.


### `ExportDir`

This extension is named `ExportDir` (modeled after
[`GNUInstallDirs`](https://cmake.org/cmake/help/latest/module/GNUInstallDirs.html)),
but its export is a variable named `CMAKE_INSTALL_EXPORTDIR`. Its value is one
of the name-based paths searched by
[`find_package`](https://cmake.org/cmake/help/latest/command/find_package.html)
on your platform, i.e. a path to a directory containing subdirectories named
for installed packages.

```cmake
install(EXPORT ${PROJECT_NAME}-targets
    FILE ${PROJECT_NAME}-targets.cmake
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION "${CMAKE_INSTALL_EXPORTDIR}/${PROJECT_NAME}-${PROJECT_VERSION}"
)
```

(This example is based on [this pattern for writing package
exports](https://unclejimbo.github.io/2018/06/08/Modern-CMake-for-Library-Developers/#Install-and-Export-the-Target).)
