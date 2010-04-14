require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502PhaTest < Test::Unit::TestCase
  context "PHA" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0x48
      end

      should "push a copy of the accumulator onto the stack" do
        @cpu.register[:A] = 0x69
        @cpu.runop(@op)
        assert_equal 0x69, @cpu.pull
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(@op)
        assert_equal pc + 1, @cpu.pc
      end
    end
  end
end