require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

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

      should "decrement the value in the X register" do
        @cpu.runop(@op)
        assert_equal 0x68, @cpu.register[:X]
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

      should "set the sign flag if bit 7 of the result is set" do
        @cpu.register[:X] = 0x81
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the result is not set" do
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(@op)
        assert_equal pc + 1, @cpu.pc
      end
    end
  end
end