require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502PlpTest < Test::Unit::TestCase
  context "PLP" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0x28
      end

      should "pull a value from the stack and set the status flags accordingly" do
        @cpu.push(0x83)
        @cpu.runop(@op)
        # bits 7 to 1 are: S V - B D I Z C
        assert_equal 1, @cpu.flag[:S]
        assert_equal 0, @cpu.flag[:V]
        assert_equal 0, @cpu.flag[:B]
        assert_equal 0, @cpu.flag[:D]
        assert_equal 0, @cpu.flag[:I]
        assert_equal 1, @cpu.flag[:Z]
        assert_equal 1, @cpu.flag[:C]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(@op)
        assert_equal pc + 1, @cpu.pc
      end
    end
  end
end