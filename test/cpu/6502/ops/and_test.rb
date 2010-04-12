require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502AndTest < Test::Unit::TestCase
  context "AND" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "immediate mode" do
      should "do a bitwise AND of the accumulator and the passed arg, storing the result in the accumulator" do
        @cpu.register[:A] = 0x69
        @cpu.runop(0x29, 0x22)
        assert_equal 0x69 & 0x22, @cpu.register[:A]
      end

      should "set the zero flag if the resulting accumulator is 0" do
        @cpu.register[:A] = 0x69
        @cpu.runop(0x29, 0x00)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the resulting accumulator is not 0" do
        @cpu.register[:A] = 0x07
        @cpu.runop(0x29, 0x04)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the resulting accumulator is set" do
        @cpu.register[:A] = 0x80
        @cpu.runop(0x29, 0x80)
        assert_equal 1, @cpu.flag[:S]
      end

      should "not set the sign flag if bit 7 of the resulting accumulator is set" do
        @cpu.register[:A] = 0x80
        @cpu.runop(0x29, 0x7F)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the correct number of bytes" do
        pc = @cpu.pc
        @cpu.runop(0x29, 0x48)
        assert_equal pc + 2, @cpu.pc
      end
    end
  end
end