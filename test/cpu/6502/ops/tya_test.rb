require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502TyaTest < Test::Unit::TestCase
  context "TYA" do
    setup do
      @cpu = Cpu6502.new
    end

    context "implied mode" do
      setup do
        @op = 0x98
      end

      should "transfer the contents of the Y register to the accumulator" do
        @cpu.register = {:A => 0, :Y => 69}
        @cpu.runop(@op)
        assert_equal 69, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator is zero" do
        @cpu.register = {:A => 69, :Y => 0}
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator is not zero" do
        @cpu.register = {:A => 0, :Y => 69}
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the accumulator is set" do
        @cpu.register = {:A => 0, :Y => -1}
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the accumulator is not set" do
        @cpu.register = {:A => 0, :Y => 69}
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for the op" do
        pc = @cpu.pc
        @cpu.runop(@op)
        assert_equal pc + 1, @cpu.pc
      end
    end
  end
end