require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502NopTest < Test::Unit::TestCase
  context "NOP" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0xEA
      end

      should "increase the pc by the number of bytes for the op" do
        pc = @cpu.pc
        @cpu.runop(@op)
        assert_equal pc + 1, @cpu.pc
      end
    end
  end
end