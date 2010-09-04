require File.expand_path('../../../test_helper', File.dirname(__FILE__))

class Cpu6502ClvTest < Test::Unit::TestCase
  context "CLV" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0xB8
      end

      should_increase_pc_by 1
      should_increase_cycles_by 2

      should "clear the overflow flag" do
        @cpu.flag[:V] = 1
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:V]
      end
    end
  end
end