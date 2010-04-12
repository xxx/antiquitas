require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502BrkTest < Test::Unit::TestCase
  context "BRK" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      should "set the break flag" do
        @cpu.runop(0x00)
        assert_equal 1, @cpu.flag[:B]
      end

      should "push the program counter, high byte first, then the status register contents onto the stack" do
        @cpu.pc = to16bit(0x10, 0x04)
        @cpu.register[:SR] = 0x19
        @cpu.runop(0x00)
        assert_equal 0x19, @cpu.pull
        assert_equal 0x04 + 1, @cpu.pull # add 1 because of @pc increment
        assert_equal 0x10, @cpu.pull
      end

      should "load the interrupt vector from 0xFFFE/F into the pc" do
        @cpu.ram[0xFFFE] = 0x34
        @cpu.ram[0xFFFF] = 0x02
        @cpu.runop(0x00)
        assert_equal to16bit(0x34, 0x02), @cpu.pc
      end
    end
  end
end