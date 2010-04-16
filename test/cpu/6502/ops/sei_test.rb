require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502SeiTest < Test::Unit::TestCase
  context "SEI" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0x78
      end

      should_increase_pc_by 1
      should_increase_cycles_by 2

      should "set the interrupt-disable flag" do
        @cpu.flag[:I] = 0
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:I]
      end
    end
  end
end