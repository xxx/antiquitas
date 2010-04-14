require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502ClvTest < Test::Unit::TestCase
  context "CLV" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0xB8
      end

      should "clear the overflow flag" do
        @cpu.flag[:V] = 1
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:V]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(@op)
        assert_equal pc + 1, @cpu.pc
      end
    end
  end
end