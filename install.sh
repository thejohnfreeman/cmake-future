#!/usr/bin/env bash

set -o errexit
set -o nounset

# Put everything in a function so that piping to bash fails gracefully if the
# download is incomplete.
main() {
  commit=${1:-master}

  # GNU mktemp (on Linux) has the --directory long option, but BSD mktemp (on
  # OSX) does not.
  work_dir="$(mktemp -d)"
  cleanup() {
    rm -rf "${work_dir}"
  }
  trap cleanup EXIT

  cd "${work_dir}"
  url="https://github.com/thejohnfreeman/cmake-future/archive/${commit}.tar.gz"
  curl --location ${url} | tar --strip-components=1 -xzf -
  mkdir build
  cd build
  cmake ..
  umask 0022
  cmake --build . --target install
}

main "$@"
