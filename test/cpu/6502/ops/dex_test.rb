require File.expand_path('../../../test_helper', File.dirname(__FILE__))

class Cpu6502DexTest < Test::Unit::TestCase
  context "DEX" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0xCA
        @cpu.register[:X] = 0x69
      end

      should_increase_pc_by 1
      should_increase_cycles_by 2

      should "decrement the value in the X register" do
        @cpu.runop(@op)
        assert_equal 0x68, @cpu.register[:X]
      end

      should "roll over if decremented when 0" do
        @cpu.register[:X] = 0x00
        @cpu.runop(@op)
        assert_equal 0xFF, @cpu.register[:X]
      end

      should "set the zero flag if the X register is now zero" do
        @cpu.register[:X] = 0x01
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the X register is not zero" do
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result is set" do
        @cpu.register[:X] = 0x81
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the result is not set" do
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:N]
      end
    end
  end
end