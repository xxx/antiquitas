require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502JmpTest < Test::Unit::TestCase
  context "JMP" do
    setup do
      @cpu = Cpu6502.new
    end

    context "absolute mode" do
      setup do
        @op = 0x4C
      end

      should_increase_cycles_by 3

      should "use the passed-in address as the lsb of the address to jump to" do
        @cpu.ram[0x6960] = 0x20
        @cpu.ram[0x6961] = 0x4A
        @cpu.runop(@op, 0x69, 0x60)
        assert_equal (0x4A << 8) | 0x20, @cpu.pc
      end

      should "emulate the known 6502 bug where the MSB of the address is taken from xx00 if the LSB falls on a page boundary" do
        @cpu.ram[0x23FF] = 0x20
        @cpu.ram[0x2400] = 0x01 # would be correct except for the bug
        @cpu.ram[0x2300] = 0x77 # bugged, but is what we want
        @cpu.runop(@op, 0x23, 0xFF)
        assert_equal (0x77 << 8) | 0x20, @cpu.pc
      end
    end

    context "indirect mode" do
      setup do
        @op = 0x6C
      end

      should_increase_cycles_by 5
      
      should "use the passed-in address as the lsb of the that holds the lsb of the REAL address we will eventually make it to" do
        @cpu.ram[0x6960] = 0x20
        @cpu.ram[0x6961] = 0x4A
        
        @cpu.ram[0x4A20] = 0x3D
        @cpu.ram[0x4A21] = 0x67

        @cpu.runop(@op, 0x69, 0x60)
        assert_equal (0x67 << 8) | 0x3D, @cpu.pc
      end

      should "emulate the known 6502 bug where the MSB of the address is taken from xx00 if the LSB falls on a page boundary" do
        @cpu.ram[0x2305] = 0xFF
        @cpu.ram[0x2306] = 0x10

        @cpu.ram[0x10FF] = 0x20
        @cpu.ram[0x1100] = 0x01 # would be correct except for the bug
        @cpu.ram[0x1000] = 0x77 # bugged, but is what we want

        @cpu.runop(@op, 0x23, 0x05)
        assert_equal (0x77 << 8) | 0x20, @cpu.pc
      end
    end
  end
end