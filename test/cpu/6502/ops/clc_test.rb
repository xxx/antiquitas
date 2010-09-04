require File.expand_path('../../../test_helper', File.dirname(__FILE__))

class Cpu6502ClcTest < Test::Unit::TestCase
  context "CLC" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0x18
      end

      should_increase_pc_by 1
      should_increase_cycles_by 2

      should "clear the carry flag" do
        @cpu.flag[:C] = 1
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:C]
      end
    end
  end
end