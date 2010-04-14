require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502BrkTest < Test::Unit::TestCase
  context "BRK" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0x00
      end

      should "set the break flag" do
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:B]
      end

      should "increment the pc by two, then push it, high byte first, then the status register contents onto the stack" do
        # bits 7 to 0 are: S V - B D I Z C
        @cpu.pc = 0x1004
        @cpu.flag[:Z] = 1
        @cpu.flag[:C] = 1
        @cpu.runop(@op)
        assert_equal 0x13, @cpu.pull # break set inside the op
        assert_equal 0x04 + 2, @cpu.pull
        assert_equal 0x10, @cpu.pull
      end

      should "set the interrupt disable flag after the status register is pushed onto the stack" do
        @cpu.runop(@op)
        status = @cpu.pull
        assert_equal 0, status & 0x04
        assert_equal 1, @cpu.flag[:I]
      end

      should "load the interrupt vector from 0xFFFE/F into the pc" do
        @cpu.ram[0xFFFE] = 0x34
        @cpu.ram[0xFFFF] = 0x02
        @cpu.runop(@op)
        assert_equal 0x0234, @cpu.pc
      end
    end
  end
end