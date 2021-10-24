require 'elftools'
require 'minitest'
include Minitest::Assertions
class << self
  attr_accessor :assertions
end
self.assertions = 0


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
  $memory = ('\x00'*0x4000).b
end

# write segment ?
def ws(addr, dat)
  puts "0x#{addr.to_i.to_s(16)} #{dat.length}"
  addr -= 0x8000_0000 
  assert addr >= 0 && addr < $memory.length
  $memory = $memory[0..addr] + dat + $memory[(addr+dat.length)..-1]
end

# main
Dir.mkdir('test-cache') unless Dir.exist?('test-cache')
Dir.glob("riscv-tests/isa/rv32ui-p-*") do |x|
  next if x.end_with?('.dump')
  File.open(x, 'rb') do |f|
    reset
    puts "test #{x}"
    e = ELFTools::ELFFile.new(f)
    e.segments.each do |s|
      ws(s.header.p_paddr, s.data)
    end
    next
    #File.open("test-cache/%s" % x.split("/")[-1], "wb") do |g|
    #  g.write('\n'join([binascii.hexlify(memory[i..i+4][::-1]) for i in range(0, $memory.length, 4)]))
    #end
  end
end
