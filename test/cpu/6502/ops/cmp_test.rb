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

    context "zeropage mode" do
      setup do
        @cpu.register[:A] = 0x69
      end

      should "set the carry flag if the value in the accumulator is greater than or equal to the value to compare with" do
        @cpu.ram[0x50] = 0x40
        @cpu.ram[0x51] = 0x69
        @cpu.runop(0xC5, 0x50)
        assert_equal 1, @cpu.flag[:C]

        @cpu.runop(0xC5, 0x51)
        assert_equal 1, @cpu.flag[:C]
      end

      should "not set the carry flag if the value in the accumulator is less than the value to compare with" do
        @cpu.ram[0x24] = 0x6A
        @cpu.runop(0xC5, 0x24)
        assert_equal 0, @cpu.flag[:C]
      end

      should "set the zero flag if the value in the accumulator is equal to the value to be compared" do
        @cpu.ram[0x24] = 0x69
        @cpu.runop(0xC5, 0x24)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the values to be compared are not equal" do
        @cpu.ram[0x24] = 0x6A
        @cpu.runop(0xC5, 0x24)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.ram[0x24] = 0x7F
        @cpu.register[:A] = 0XFF
        @cpu.runop(0xC5, 0x24)
        assert_equal 1, @cpu.flag[:S]
      end

      should "not set the sign flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.ram[0x24] = 0x68
        @cpu.runop(0xC5, 0x24)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the correct number of bytes" do
        pc = @cpu.pc
        @cpu.runop(0xC5, 0x6A)
        assert_equal pc + 2, @cpu.pc
      end
    end

    context "zeropagex mode" do
      setup do
        @cpu.register[:A] = 0x69
        @cpu.register[:X] = 0x04
      end

      should "set the carry flag if the value in the accumulator is greater than or equal to the value to compare with" do
        @cpu.ram[0x50] = 0x40
        @cpu.ram[0x51] = 0x69
        @cpu.runop(0xD5, 0x4C)
        assert_equal 1, @cpu.flag[:C]

        @cpu.runop(0xD5, 0x4D)
        assert_equal 1, @cpu.flag[:C]
      end

      should "not set the carry flag if the value in the accumulator is less than the value to compare with" do
        @cpu.ram[0x24] = 0x6A
        @cpu.runop(0xD5, 0x20)
        assert_equal 0, @cpu.flag[:C]
      end

      should "set the zero flag if the value in the accumulator is equal to the value to be compared" do
        @cpu.ram[0x24] = 0x69
        @cpu.runop(0xD5, 0x20)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the values to be compared are not equal" do
        @cpu.ram[0x24] = 0x6A
        @cpu.runop(0xD5, 0x20)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.ram[0x24] = 0x7F
        @cpu.register[:A] = 0XFF
        @cpu.runop(0xD5, 0x20)
        assert_equal 1, @cpu.flag[:S]
      end

      should "not set the sign flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.ram[0x24] = 0x68
        @cpu.runop(0xD5, 0x20)
        assert_equal 0, @cpu.flag[:S]
      end

      should "wrap larger addresses around to stay on the zero page" do
        @cpu.ram[0x24] = 0x69 # good result, will set the zero flag
        @cpu.ram[0x24 + 0xFF] = 0xB0 # wrong result, didn't wrap
        @cpu.register[:X] = 0xFF
        @cpu.runop(0xD5, 0x24)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "increase the pc by the correct number of bytes" do
        pc = @cpu.pc
        @cpu.runop(0xD5, 0x6A)
        assert_equal pc + 2, @cpu.pc
      end
    end

    context "absolute mode" do
      setup do
        @cpu.register[:A] = 0x69
      end

      should "set the carry flag if the value in the accumulator is greater than or equal to the value to compare with" do
        @cpu.ram[0x5050] = 0x40
        @cpu.ram[0x5150] = 0x69
        @cpu.runop(0xCD, 0x50, 0x50)
        assert_equal 1, @cpu.flag[:C]

        @cpu.runop(0xCD, 0x51, 0x50)
        assert_equal 1, @cpu.flag[:C]
      end

      should "not set the carry flag if the value in the accumulator is less than the value to compare with" do
        @cpu.ram[0x2450] = 0x6A
        @cpu.runop(0xCD, 0x24, 0x50)
        assert_equal 0, @cpu.flag[:C]
      end

      should "set the zero flag if the value in the accumulator is equal to the value to be compared" do
        @cpu.ram[0x2450] = 0x69
        @cpu.runop(0xCD, 0x24, 0x50)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the values to be compared are not equal" do
        @cpu.ram[0x2450] = 0x6A
        @cpu.runop(0xCD, 0x24, 0x50)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.ram[0x2450] = 0x7F
        @cpu.register[:A] = 0XFF
        @cpu.runop(0xCD, 0x24, 0x50)
        assert_equal 1, @cpu.flag[:S]
      end

      should "not set the sign flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.ram[0x2450] = 0x68
        @cpu.runop(0xCD, 0x24, 0x50)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the correct number of bytes" do
        pc = @cpu.pc
        @cpu.runop(0xCD, 0x6A, 0x56)
        assert_equal pc + 3, @cpu.pc
      end
    end

    context "absolutex mode" do
      setup do
        @cpu.register[:A] = 0x69
        @cpu.register[:X] = 0x04
      end

      should "set the carry flag if the value in the accumulator is greater than or equal to the value to compare with" do
        @cpu.ram[0x5050] = 0x40
        @cpu.ram[0x5150] = 0x69
        @cpu.runop(0xDD, 0x50, 0x4C)
        assert_equal 1, @cpu.flag[:C]

        @cpu.runop(0xDD, 0x51, 0x4C)
        assert_equal 1, @cpu.flag[:C]
      end

      should "not set the carry flag if the value in the accumulator is less than the value to compare with" do
        @cpu.ram[0x2450] = 0x6A
        @cpu.runop(0xDD, 0x24, 0x4C)
        assert_equal 0, @cpu.flag[:C]
      end

      should "set the zero flag if the value in the accumulator is equal to the value to be compared" do
        @cpu.ram[0x2450] = 0x69
        @cpu.runop(0xDD, 0x24, 0x4C)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the values to be compared are not equal" do
        @cpu.ram[0x2450] = 0x6A
        @cpu.runop(0xDD, 0x24, 0x4C)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.ram[0x2450] = 0x7F
        @cpu.register[:A] = 0XFF
        @cpu.runop(0xDD, 0x24, 0x4C)
        assert_equal 1, @cpu.flag[:S]
      end

      should "not set the sign flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.ram[0x2450] = 0x68
        @cpu.runop(0xDD, 0x24, 0x4C)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the correct number of bytes" do
        pc = @cpu.pc
        @cpu.runop(0xDD, 0x6A, 0x56)
        assert_equal pc + 3, @cpu.pc
      end
    end

    context "absolutey mode" do
      setup do
        @cpu.register[:A] = 0x69
        @cpu.register[:Y] = 0x04
      end

      should "set the carry flag if the value in the accumulator is greater than or equal to the value to compare with" do
        @cpu.ram[0x5050] = 0x40
        @cpu.ram[0x5150] = 0x69
        @cpu.runop(0xD9, 0x50, 0x4C)
        assert_equal 1, @cpu.flag[:C]

        @cpu.runop(0xD9, 0x51, 0x4C)
        assert_equal 1, @cpu.flag[:C]
      end

      should "not set the carry flag if the value in the accumulator is less than the value to compare with" do
        @cpu.ram[0x2450] = 0x6A
        @cpu.runop(0xD9, 0x24, 0x4C)
        assert_equal 0, @cpu.flag[:C]
      end

      should "set the zero flag if the value in the accumulator is equal to the value to be compared" do
        @cpu.ram[0x2450] = 0x69
        @cpu.runop(0xD9, 0x24, 0x4C)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the values to be compared are not equal" do
        @cpu.ram[0x2450] = 0x6A
        @cpu.runop(0xD9, 0x24, 0x4C)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.ram[0x2450] = 0x7F
        @cpu.register[:A] = 0XFF
        @cpu.runop(0xD9, 0x24, 0x4C)
        assert_equal 1, @cpu.flag[:S]
      end

      should "not set the sign flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.ram[0x2450] = 0x68
        @cpu.runop(0xD9, 0x24, 0x4C)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the correct number of bytes" do
        pc = @cpu.pc
        @cpu.runop(0xD9, 0x6A, 0x56)
        assert_equal pc + 3, @cpu.pc
      end
    end

  end
end