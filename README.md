# lizecore

riscv-tests/

# Get Start

## 

- riscv-gnu-toolchain

M1 AppleSilicon is not supported riscv-gnu-toolchain.
You need Rosetta2.

```
$ arch -x86-64 /usr/local/bin/brew tap riscv/riscv
$ arch -x86-64 /usr/local/bin/brew install riscv-gnu-toolchain
$ arch -x86_64 /usr/local/bin/brew reinstall riscv-gcc
$ PATH=$PATH:/usr/local/opt/riscv-gnu-toolchain/bin
```

## ruby library

```
$ gem install elftools
```

# note on ELF

ELF is Executable and Linking Format.

* [ELF header]
* [Program header table]
* [Section header table]
