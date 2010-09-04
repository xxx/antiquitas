require File.expand_path('../../../test_helper', File.dirname(__FILE__))

class Cpu6502PlpTest < Test::Unit::TestCase
  context "PLP" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0x28
      end
      
      should_increase_pc_by 1
      should_increase_cycles_by 4
      
      should "pull a value from the stack and set the status flags accordingly" do
        @cpu.push(0x83)
        @cpu.runop(@op)
        # bits 7 to 0 are: N V - B D I Z C
        assert_equal 1, @cpu.flag[:N]
        assert_equal 0, @cpu.flag[:V]
        assert_equal 0, @cpu.flag[:B]
        assert_equal 0, @cpu.flag[:D]
        assert_equal 0, @cpu.flag[:I]
        assert_equal 1, @cpu.flag[:Z]
        assert_equal 1, @cpu.flag[:C]
      end

      should "discard the popped value of the break flag regardless of what it is" do
        @cpu.push(0x10)
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:B]
      end
    end
  end
end