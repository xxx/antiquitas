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

    context "zeropage mode" do
      should "do a bitwise AND of the accumulator and the value at the memory location of the passed arg, storing the result in the accumulator" do
        @cpu.register[:A] = 0x69
        @cpu.ram[0x22] = 0x12
        @cpu.runop(0x25, 0x22)
        assert_equal 0x69 & 0x12, @cpu.register[:A]
      end

      should "set the zero flag if the resulting accumulator is 0" do
        @cpu.register[:A] = 0x69
        @cpu.ram[0x22] = 0x00
        @cpu.runop(0x25, 0x22)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the resulting accumulator is not 0" do
        @cpu.register[:A] = 0x07
        @cpu.ram[0x22] = 0x04
        @cpu.runop(0x25, 0x22)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the resulting accumulator is set" do
        @cpu.register[:A] = 0x80
        @cpu.ram[0x22] = 0x80
        @cpu.runop(0x25, 0x22)
        assert_equal 1, @cpu.flag[:S]
      end

      should "not set the sign flag if bit 7 of the resulting accumulator is set" do
        @cpu.register[:A] = 0x80
        @cpu.ram[0x22] = 0x7F
        @cpu.runop(0x25, 0x22)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the correct number of bytes" do
        pc = @cpu.pc
        @cpu.runop(0x25, 0x48)
        assert_equal pc + 2, @cpu.pc
      end
    end

    context "zeropagex mode" do
      setup do
        @cpu.register[:X] = 0x04
      end

      should "do a bitwise AND of the accumulator and the value at the memory location of the passed arg, storing the result in the accumulator" do
        @cpu.register[:A] = 0x69
        @cpu.ram[0x22] = 0x12
        @cpu.runop(0x35, 0x1E)
        assert_equal 0x69 & 0x12, @cpu.register[:A]
      end

      should "set the zero flag if the resulting accumulator is 0" do
        @cpu.register[:A] = 0x69
        @cpu.ram[0x22] = 0x00
        @cpu.runop(0x35, 0x1E)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the resulting accumulator is not 0" do
        @cpu.register[:A] = 0x07
        @cpu.ram[0x22] = 0x04
        @cpu.runop(0x35, 0x1E)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the resulting accumulator is set" do
        @cpu.register[:A] = 0x80
        @cpu.ram[0x22] = 0x80
        @cpu.runop(0x35, 0x1E)
        assert_equal 1, @cpu.flag[:S]
      end

      should "not set the sign flag if bit 7 of the resulting accumulator is set" do
        @cpu.register[:A] = 0x80
        @cpu.ram[0x22] = 0x7F
        @cpu.runop(0x35, 0x1E)
        assert_equal 0, @cpu.flag[:S]
      end

      should "correct any overflow in the resulting address to stay on the zero page" do
        @cpu.register[:A] = 0x10
        @cpu.register[:X] = 0xFF
        @cpu.ram[0xFE] = 0x33
        @cpu.runop(0x35, 0xFE)
        assert_equal 0x10 & 0x33, @cpu.register[:A]
      end

      should "increase the pc by the correct number of bytes" do
        pc = @cpu.pc
        @cpu.runop(0x35, 0x1E)
        assert_equal pc + 2, @cpu.pc
      end
    end
  end
end