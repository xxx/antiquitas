require File.expand_path('../../../test_helper', File.dirname(__FILE__))

class Cpu6502CTxsTest < Test::Unit::TestCase
  context "TXS" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0x9A
      end

      should_increase_pc_by 1
      should_increase_cycles_by 2

      should "transfer the value in the X register to the stack pointer" do
        @cpu.register[:X] = 0x69
        @cpu.runop(@op)
        assert_equal 0x69, @cpu.register[:S]
      end

      should "not change the value of the X register" do
        @cpu.register[:X] = 0x40
        x = @cpu.register[:X]
        @cpu.runop(@op)
        assert_equal x, @cpu.register[:X]
      end

      should "not alter any flags" do
        @cpu.register[:X] = 0x00
        @cpu.flag[:Z] = 0
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:Z]
      end
    end
  end
end