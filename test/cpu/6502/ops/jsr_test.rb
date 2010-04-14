require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502JsrTest < Test::Unit::TestCase
  context "JSR" do
    setup do
      @cpu = Cpu6502.new
    end

    context "absolute mode" do
      setup do
        @op = 0x20
      end

      should "push the current pc - 1 (after incrementing it for this op) onto the stack" do
        @cpu.pc = 2100
        @cpu.runop(@op, 0x40, 0x25)
        low_end = @cpu.pull
        high_end = @cpu.pull
        assert_equal 2102, (high_end << 8) | low_end
      end

      should "set the program counter to the passed 16-bit memory address" do
        @cpu.runop(@op, 0x40, 0x25)
        assert_equal to16bit(0x40, 0x25), @cpu.pc
      end
    end
  end
end