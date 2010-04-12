require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502TxaTest < Test::Unit::TestCase
  context "TXA" do
    setup do
      @cpu = Cpu6502.new
    end

    context "implied mode" do
      should "transfer the contents of the X register to the accumulator" do
        @cpu.register = {:A => 0, :X => 69}
        @cpu.runop(0x8A)
        assert_equal 69, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator is zero" do
        @cpu.register = {:A => 69, :X => 0}
        @cpu.runop(0x8A)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator is not zero" do
        @cpu.register = {:A => 0, :X => 69}
        @cpu.runop(0x8A)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the accumulator is set" do
        @cpu.register = {:A => 0, :X => -1}
        @cpu.runop(0x8A)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the accumulator is not set" do
        @cpu.register = {:A => 0, :X => 69}
        @cpu.runop(0x8A)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for the op" do
        pc = @cpu.pc
        @cpu.runop(0x8A)
        assert_equal pc + 1, @cpu.pc
      end
    end
  end
end