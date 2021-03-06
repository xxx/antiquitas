require File.expand_path('../../../test_helper', File.dirname(__FILE__))

class Cpu6502CldTest < Test::Unit::TestCase
  context "CLD" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0xD8
      end

      should_increase_pc_by 1
      should_increase_cycles_by 2

      should "clear the decimal mode flag" do
        @cpu.flag[:D] = 1
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:D]
      end
    end
  end
end