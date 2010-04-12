require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502CpxTest < Test::Unit::TestCase
  context "CPX" do
    setup do
      @cpu = Cpu6502.new
    end

    context "immediate mode" do
      setup do
        @cpu.register = {:X => 0x30}
      end

      should "set the carry flag if the value in the X register is the same or greater than the passed value" do
        @cpu.runop(0xE0, 0x30)
        assert_equal 1, @cpu.flag[:C]

        @cpu.runop(0xE0, 0)
        assert_equal 1, @cpu.flag[:C]
      end

      should "clear the carry flag if the value in the X register is less than the passed value" do
        @cpu.runop(0xE0, 0x40)
        assert_equal 0, @cpu.flag[:C]
      end

      should "set the zero flag if the value in the X register is the same as the passed value" do
        @cpu.runop(0xE0, 0x30)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the value in the X register is not the same as the passed value" do
        @cpu.runop(0xE0, 0)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag of the value if the result of X minus the value is negative" do
        @cpu.runop(0xE0, 0x40)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag of the value if the result of X minus the value is not negative" do
        @cpu.runop(0xE0, 0x30)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for the op" do
        pc = @cpu.pc
        @cpu.runop(0xE0, 0x30)
        assert_equal pc + 2, @cpu.pc
      end
    end
  end
end