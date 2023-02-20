#!/bin/bash
set -euo pipefail

function __vim() {
  # https://github.com/neovim/neovim/wiki/Building-Neovim#quick-start
  sudo apt update
  sudo apt-get install ninja-build gettext libtool libtool-bin cmake g++ pkg-config unzip curl doxygen
  git submodule update --init --recursive
  pushd neovim
  make CMAKE_BUILD_TYPE=Release
  sudo make install
  popd
}

function __dots() {
  stow .
}

if [[ -z "__$1" || "$(type -t __$1)" != "function" ]]; then
  echo "Usage: $0 [target]"
  exit 1
else
  set -x
  "__$1"
fi
