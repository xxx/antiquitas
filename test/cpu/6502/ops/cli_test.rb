require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

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

      should "clear the interrupt-disable flag" do
        @cpu.flag[:I] = 1
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:I]
      end
    end
  end
end