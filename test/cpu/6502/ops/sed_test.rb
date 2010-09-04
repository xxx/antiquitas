require File.expand_path('../../../test_helper', File.dirname(__FILE__))

class Cpu6502SedTest < Test::Unit::TestCase
  context "SED" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0xF8
      end

      should_increase_pc_by 1
      should_increase_cycles_by 2
      
      should "set the decimal mode flag" do
        @cpu.flag[:D] = 0
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:D]
      end
    end
  end
end