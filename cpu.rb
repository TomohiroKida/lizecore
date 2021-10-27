require 'elftools'
require 'minitest'
include Minitest::Assertions
class << self
  attr_accessor :assertions
end
self.assertions = 0

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

# write segment ?
def ws(addr, dat)
  puts "#{addr} #{dat.size}"
  addr -= 0x80000000 
  assert addr >= 0 && addr < $memory.size
  $memory = $memory[0, addr] + dat + $memory[(addr+dat.size)..-1]
end

def step

  # *** Fetch ***
  # *** Decode ***
  # *** Execute ***
  # *** Write back ***

  return false
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
        (0..$memory.size-1).step(4).map { |i| ($memory[i..i+3].reverse).unpack("H*") }.join("\n")
      )
    end
    inscnt = 0
    while step() do
      inscnt += 1
    end
    puts "  ran #{inscnt} instructions"
  end
end
