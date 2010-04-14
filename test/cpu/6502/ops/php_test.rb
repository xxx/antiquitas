require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502PhpTest < Test::Unit::TestCase
  context "PHP" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0x08
      end

      should "push a copy of the status register onto the stack" do
        @cpu.flag[:Z] = 1
        @cpu.flag[:C] = 1
        @cpu.flag[:I] = 1
        @cpu.runop(@op)
        # bits 7 to 1 are: S V - B D I Z C
        assert_equal 0x07 | 0x20 | 0x10, @cpu.pull # break and unused are always 1
      end

      # bug compatability
      should "set the value of the break flag pushed to 1 whether it is actually currently set or not" do
        @cpu.runop(@op)
        assert_equal 0x10 | 0x20, @cpu.pull # unused always 1
      end

      # moar bug compatability
      should "not change the actual value of the break flag" do
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:B]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(@op)
        assert_equal pc + 1, @cpu.pc
      end
    end
  end
end