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

function __pyenv() {
  # https://devguide.python.org/getting-started/setup-building/#linux
  sudo apt update
  sudo apt install -y --no-install-recommends \
    build-essential \
    gdb \
    lcov \
    pkg-config \
    libbz2-dev \
    libffi-dev \
    libgdbm-dev \
    libgdbm-compat-dev \
    liblzma-dev \
    libncurses5-dev \
    libreadline6-dev \
    libsqlite3-dev \
    libssl-dev \
    lzma \
    lzma-dev \
    tk-dev \
    uuid-dev \
    zlib1g-dev

  # https://github.com/pyenv/pyenv#basic-github-checkout
  git submodule update --init --recursive
  bash ./pyenv-installer/bin/pyenv-installer
  source ~/.bashrc
  pyenv install 3.10.10
  pyenv global 3.10.10
  pip install --upgrade pip
  pip install ipython pipenv
}

function __dots() {
  stow home
}

function __cli() {
  sudo add-apt-repository ppa:git-core/ppa -y
  sudo apt update
  sudo apt install --no-install-recommends -y \
    bat \
    git
}

if [[ -z "__$1" || "$(type -t __$1)" != "function" ]]; then
  echo "Usage: $0 [target]"
  exit 1
else
  set -x
  "__$1"
fi
