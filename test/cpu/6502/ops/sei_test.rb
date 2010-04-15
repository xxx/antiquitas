require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502SeiTest < Test::Unit::TestCase
  context "SEI" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0x78
      end

      should "set the interrupt-disable flag" do
        @cpu.flag[:I] = 0
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:I]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(@op)
        assert_equal pc + 1, @cpu.pc
      end
    end
  end
end