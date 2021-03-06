require File.expand_path('../../../test_helper', File.dirname(__FILE__))

class Cpu6502CliTest < Test::Unit::TestCase
  context "CLI" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0x58
      end

      should_increase_pc_by 1
      should_increase_cycles_by 2

      should "clear the interrupt-disable flag" do
        @cpu.flag[:I] = 1
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:I]
      end
    end
  end
end