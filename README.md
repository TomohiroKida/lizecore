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

* elftools

```
$ bundle install
```

# note on ELF

ELF is Executable and Linking Format.

* [ELF header]
* [Program header table]
* [Section header table]

```
$ readelf -l [.elf]
$ readelf -S [.elf]
```

# RV32I Instructions

```
 31        25  24 20  19 15  14  12  11        7  6    0
[funct7      ][rs2  ][rs1  ][funct3][rd         ][opcode] R-type
 31               20  19 15  14  12  11        7  6    0
[imm[11:0]          ][rs1  ][funct3][rd         ][opcode] I-type
 31        25  24 20  19 15  14  12  11        7  6    0
[imm[11:5]   ][rs2  ][rs1  ][funct3][imm[4:0]   ][opcode] S-type
 31        25  24 20  19 15  14  12  11        7  6    0
[imm[12|10:5]][rs2  ][rs1  ][funct3][imm[4:1|11]][opcode] B-type
 31                              12  11        7  6    0
[imm[31:12]                        ][rd         ][opcode] U-type
 31                              12  11        7  6    0
[imm[20|10:1|11|19:12]             ][rd         ][opcode] J-type
```

## Load and Store

[] lb
[] lh
[] lw
[] sb
[] sh
[] sw
[] lbu
[] lhu

## Integer Calculate

[] add
[] addi
[] sub
[] and
[] or
[] xor
[] andi
[] ori
[] xori
[] sll
[] sra
[] srl
[] slli
[] srai
[] srli
[] lui
[] auipc
