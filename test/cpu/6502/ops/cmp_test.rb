require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502CmpTest < Test::Unit::TestCase
  context "CMP" do
    setup do
      @cpu = Cpu6502.new
    end

    context "immediate mode" do
      setup do
        @cpu.register[:A] = 0x69
      end

      should "set the carry flag if the value in the accumulator is greater than or equal to the value to compare with" do
        @cpu.runop(0xC9, 0x40)
        assert_equal 1, @cpu.flag[:C]

        @cpu.runop(0xC9, 0x69)
        assert_equal 1, @cpu.flag[:C]
      end

      should "not set the carry flag if the value in the accumulator is less than the value to compare with" do
        @cpu.runop(0xC9, 0x6A)
        assert_equal 0, @cpu.flag[:C]
      end

      should "set the zero flag if the value in the accumulator is equal to the value to be compared" do
        @cpu.runop(0xC9, 0x69)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the values to be compared are not equal" do
        @cpu.runop(0xC9, 0x6A)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.register[:A] = 0XFF
        @cpu.runop(0xC9, 0x7F)
        assert_equal 1, @cpu.flag[:S]
      end
      
      should "not set the sign flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.runop(0xC9, 0x68)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the correct number of bytes" do
        pc = @cpu.pc
        @cpu.runop(0xC9, 0x6A)
        assert_equal pc + 2, @cpu.pc
      end
    end
  end
end