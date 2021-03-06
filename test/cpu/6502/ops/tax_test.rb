require File.expand_path('../../../test_helper', File.dirname(__FILE__))

class Cpu6502CTaxTest < Test::Unit::TestCase
  context "TAX" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0xAA
      end

      should_increase_pc_by 1
      should_increase_cycles_by 2

      should "transfer the value in the accumulator to the X register" do
        @cpu.register[:A] = 0x69
        @cpu.runop(@op)
        assert_equal 0x69, @cpu.register[:X]
      end

      should "set the zero flag if the transferred value is 0" do
        @cpu.register[:A] = 0x00
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the transferred value is not 0" do
        @cpu.register[:A] = 0x50
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if the transferred value has bit 7 set" do
        @cpu.register[:A] = 0x80
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if the transferred value does not have bit 7 set" do
        @cpu.register[:A] = 0x08
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:N]
      end
    end
  end
end