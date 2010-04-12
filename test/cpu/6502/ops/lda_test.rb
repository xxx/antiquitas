require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502LdaTest < Test::Unit::TestCase
  context "LDA" do
    setup do
      @cpu = Cpu6502.new
    end

    context "immediate mode" do
      should "load the accumulator with arg" do
        @cpu.runop(0xA9, 69)
        assert_equal 69, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator is zero" do
        @cpu.runop(0xA9, 0)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator is not zero" do
        @cpu.runop(0xA9, 4)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the accumulator is set" do
        @cpu.runop(0xA9, -1)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the accumulator is not set" do
        @cpu.runop(0xA9, 1)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for the op" do
        pc = @cpu.pc
        @cpu.runop(0xA9, 1)
        assert_equal pc + 2, @cpu.pc
      end

    end
  end
end