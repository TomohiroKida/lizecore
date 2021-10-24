#!/bin/bash

# arch -x86_64 /usr/local/bin/brew install riscv-gnu-toolchain
# arch -x86_64 /usr/local/bin/brew reinstall riscv-gcc

git clone https://github.com/riscv/riscv-tests
cd riscv-tests
git submodule update --init --recursive
autoconf
./configure
make -j
make install

