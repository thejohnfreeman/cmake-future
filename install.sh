#!/usr/bin/env bash

set -o errexit
set -o nounset

# Put everything in a function so that piping to bash fails gracefully if the
# download is incomplete.
main() {
  work_dir="$(mktemp --directory)"
  cleanup() {
    rm -rf "${work_dir}"
  }
  trap cleanup EXIT

  cd "${work_dir}"
  url=https://github.com/thejohnfreeman/cmake-future/archive/master.tar.gz
  curl --location --insecure ${url} | tar --strip-components=1 -xzf -
  mkdir build
  cd build
  cmake ..
  umask 0022
  cmake --build . --target install
}

main
