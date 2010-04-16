require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502PhaTest < Test::Unit::TestCase
  context "PHA" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0x48
      end

      should_increase_pc_by 1
      should_increase_cycles_by 3

      should "push a copy of the accumulator onto the stack" do
        @cpu.register[:A] = 0x69
        @cpu.runop(@op)
        assert_equal 0x69, @cpu.pull
      end
    end
  end
end