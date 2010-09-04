require File.expand_path('../../../test_helper', File.dirname(__FILE__))

class Cpu6502SecTest < Test::Unit::TestCase
  context "SEC" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0x38
      end

      should_increase_pc_by 1
      should_increase_cycles_by 2

      should "set the carry flag" do
        @cpu.flag[:C] = 0
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:C]
      end
    end
  end
end