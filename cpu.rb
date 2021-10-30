#!/usr/bin/ruby
require 'elftools'
require 'minitest'
include Minitest::Assertions
class << self
  attr_accessor :assertions
end
self.assertions = 0

PC = 32

$regnames = \
  ["x0", "ra", "sp", "gp", "tp"] +\
  [*0..2].map { |i| "t#{i}" } + ["s0", "s1"] +\
  [*0..7].map { |i| "a#{i}" } +\
  [*2..11].map { |i| "s#{i}" } +\
  [*3..6].map { |i| "t#{i}" } + ["PC"]
p $regnames

class Regfile
  attr_accessor :regs
  def initialize()
    @regs = [0] * 33
  end
  def [](key)
    @regs[key]
  end
  def []=(key, value)
    return if key == 0 # x0 / zero
    @regs[key] = value & 0xFFFF_FFFF
  end
end

$regfile = nil
$memory = nil
def reset
  $regfile = Regfile.new
  # 16kb at 0x8000_0000
  $memory = "\x00"*0x4000
end

# RV32I Base Instruction Set
$ops = {
  LUI: 0b0110111,    # load upper immediate
  LOAD: 0b0000011,
  STORE: 0b0100011,

  AUIPC: 0b0010111, # add upper immediate to pc
  BRANCH: 0b1100011,
  JAL: 0b1101111,
  JALR: 0b1100111,

  IMM: 0b0010011,
  OP: 0b0110011,

  MISC: 0b0001111,
  SYSTEM: 0b1110011,
}.freeze

# write segment ?
def ws(addr, dat)
  p "#{addr.to_i.to_s(2)} #{dat.size}"
  addr -= 0x8000_0000 
  assert addr >= 0 && addr < $memory.size
  $memory = $memory[0, addr] + dat + $memory[(addr+dat.size)..-1]
end

def r32(addr)
  addr -= 0x8000_0000
  if addr < 0 || addr >= $memory.size
    raise "#{addr}"
  end
  return $memory[addr..addr+4-1].unpack("<I")[0] # littele endian unsigned int DWORD
end

def sign_extend(x, l)
  if x >> (l-1) == 1
    return -((1 << l) - x)
  else
    return x
  end
end

def step
  # *** Fetch ***
  ins = r32($regfile[PC])
  p ins.to_s(2)

  # *** Decode ***
  gibi = lambda { |s, e| return (ins >> e) & ((1 << (s-e+1))-1) }
  opcode = $ops.key(gibi.call(6, 0))
  funct3 = gibi.call(14, 12)
  funct7 = gibi.call(31, 25)

  # immidiate
  imm_i = sign_extend(gibi.call(31, 20), 12)
  imm_s = sign_extend(gibi.call(31, 25)<<5 | gibi.call(11, 7), 12)
  imm_b = sign_extend((gibi.call(31, 31)<<12) | (gibi.call(7, 7)<<11) | (gibi.call(30, 25)<<5)  | (gibi.call(11, 8)<<1), 13)
  imm_u = sign_extend(gibi.call(31, 12)<<12, 32)
  imm_j = sign_extend((gibi.call(31, 31)<<20) | (gibi.call(19, 12)<<12) | (gibi.call(20, 20)<<11) | (gibi.call(30, 21)<<1), 21)

  # register write set up
  rd = gibi.call(11, 7)
  # register reads
  rs1 = gibi.call(19, 15)
  rs2 = gibi.call(24, 20)
  vs1 = $regfile[rs1]
  vs2 = $regfile[rs2]
  vpc = $regfile[PC]
  
  p "opcode #{opcode}"
  #p "rd #{rd.to_s(2)}"
  #p "rs1 #{rs1.to_s(2)}"
  #p "rs2 #{rs2.to_s(2)}"
  #p "funct3 #{funct3.to_s(2)}"
  #p "funct7 #{funct7.to_s(2)}"
  #p "imm_i #{imm_i.to_s(2)}"
  #p "imm_s #{imm_s.to_s(2)}"
  #p "imm_b #{imm_b.to_s(2)}"
  #p "imm_u #{imm_u.to_s(2)}"
  #p "imm_j #{imm_j.to_s(2)}"

  # *** Execute ***
  # *** Write back ***

  return true
end

# main
Dir.mkdir("test-cache") unless Dir.exist?("test-cache")
Dir.glob("riscv-tests/isa/rv32ui-p-*") do |x|
  next if x.end_with?(".dump")
  next unless x == "riscv-tests/isa/rv32ui-p-and"
  File.open(x, "rb") do |f|
    reset
    puts "test #{x}"
    e = ELFTools::ELFFile.new(f)
    e.segments.each do |s| 
      ws(s.header.p_paddr, s.data) 
    end
    File.open("test-cache/%s" % x.split("/")[-1], "wb") do |g|
      g.write(
        (0..$memory.size-1).step(4).map { |i| ($memory[i..i+4-1].reverse).unpack("H*") }.join("\n")
      )
    end
    $regfile[PC] = 0x8000_0000
    inscnt = 0
    while step() && inscnt < 10 do
      inscnt += 1
    end
    puts "  ran #{inscnt} instructions"
  end
end
