#!/bin/bash

# Utility script to download and build LLVM & clang
#
# Copyright Contributors to the Open Shading Language project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/AcademySoftwareFoundation/OpenShadingLanguage

# Exit the whole script if any command fails.
set -ex

echo "Building LLVM"
uname


if [[ `uname` == "Linux" ]] ; then
    LLVM_VERSION=${LLVM_VERSION:=8.0.0}
    LLVM_INSTALL_DIR=${LLVM_INSTALL_DIR:=${PWD}/llvm-install}
    if [[ "$GITHUB_WORKFLOW" != "" ]] ; then
        LLVM_DISTRO_NAME=${LLVM_DISTRO_NAME:=ubuntu-18.04}
    elif [[ "$TRAVIS_DIST" == "trusty" ]] ; then
        LLVM_DISTRO_NAME=${LLVM_DISTRO_NAME:=ubuntu-14.04}
    elif [[ "$TRAVIS_DIST" == "xenial" ]] ; then
        LLVM_DISTRO_NAME=${LLVM_DISTRO_NAME:=ubuntu-16.04}
    elif [[ "$TRAVIS_DIST" == "bionic" ]] ; then
        LLVM_DISTRO_NAME=${LLVM_DISTRO_NAME:=ubuntu-18.04}
    else
        LLVM_DISTRO_NAME=${LLVM_DISTRO_NAME:=error}
    fi
    LLVMTAR=clang+llvm-${LLVM_VERSION}-x86_64-linux-gnu-${LLVM_DISTRO_NAME}.tar.xz
    echo LLVMTAR = $LLVMTAR
    if [[ ${LLVM_VERSION} == "12.0.0" ]]; then
      echo "deb http://apt.llvm.org/focal/ llvm-toolchain-focal-12 main" | sudo tee -a /etc/apt/sources.list
      echo "deb-src http://apt.llvm.org/focal/ llvm-toolchain-focal-12 main" | sudo tee -a /etc/apt/sources.list
      wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add -
      sudo apt-get update
      sudo apt-get install libllvm-12-ocaml-dev libllvm12 llvm-12 llvm-12-dev llvm-12-runtime clang-12 clang-tools-12 libclang-common-12-dev libclang-12-dev libclang1-12 clang-format-12 clangd-12 libfuzzer-12-dev lldb-12 lld-12 libc++-12-dev libc++abi-12-dev libomp-12-dev
      export LLVM_DIRECTORY=/usr
      export LLVM_INCLUDES=/usr/include/llvm
      export LLVM_LIBRARIES=/usr/lib
      export LLVM_ROOT=/usr
    else
      LLVM_MAJOR_VERSION=$(echo $LLVM_VERSION | sed 's/\..*$//')
      if (($LLVM_MAJOR_VERSION > 10)); then
          # new
          curl --location https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VERSION}/${LLVMTAR} -o $LLVMTAR
      else
          curl --location http://releases.llvm.org/${LLVM_VERSION}/${LLVMTAR} -o $LLVMTAR
      fi
      ls -l $LLVMTAR
      tar xf $LLVMTAR
      rm -f $LLVMTAR
      echo "Installed ${LLVM_VERSION} in ${LLVM_INSTALL_DIR}"
      mkdir -p $LLVM_INSTALL_DIR && true
      mv clang+llvm*/* $LLVM_INSTALL_DIR
      export LLVM_DIRECTORY=$LLVM_INSTALL_DIR
      export PATH=${LLVM_INSTALL_DIR}/bin:$PATH
      ls -a $LLVM_DIRECTORY
    fi
fi
