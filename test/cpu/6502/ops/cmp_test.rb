require File.expand_path('../../../test_helper', File.dirname(__FILE__))

class Cpu6502CmpTest < Test::Unit::TestCase
  context "CMP" do
    setup do
      @cpu = Cpu6502.new
    end

    context "immediate mode" do
      setup do
        @op = 0xC9
        @cpu.register[:A] = 0x69
      end

      should_increase_pc_by 2
      should_increase_cycles_by 2

      should "set the carry flag if the value in the accumulator is greater than or equal to the value to compare with" do
        @cpu.runop(@op, 0x40)
        assert_equal 1, @cpu.flag[:C]

        @cpu.runop(@op, 0x69)
        assert_equal 1, @cpu.flag[:C]
      end

      should "not set the carry flag if the value in the accumulator is less than the value to compare with" do
        @cpu.runop(@op, 0x6A)
        assert_equal 0, @cpu.flag[:C]
      end

      should "set the zero flag if the value in the accumulator is equal to the value to be compared" do
        @cpu.runop(@op, 0x69)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the values to be compared are not equal" do
        @cpu.runop(@op, 0x6A)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.register[:A] = 0XFF
        @cpu.runop(@op, 0x7F)
        assert_equal 1, @cpu.flag[:N]
      end
      
      should "not set the negative flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.runop(@op, 0x68)
        assert_equal 0, @cpu.flag[:N]
      end
    end

    context "zeropage mode" do
      setup do
        @op = 0xC5
        @cpu.register[:A] = 0x69
      end

      should_increase_pc_by 2
      should_increase_cycles_by 3

      should "set the carry flag if the value in the accumulator is greater than or equal to the value to compare with" do
        @cpu.ram[0x50] = 0x40
        @cpu.ram[0x51] = 0x69
        @cpu.runop(@op, 0x50)
        assert_equal 1, @cpu.flag[:C]

        @cpu.runop(@op, 0x51)
        assert_equal 1, @cpu.flag[:C]
      end

      should "not set the carry flag if the value in the accumulator is less than the value to compare with" do
        @cpu.ram[0x24] = 0x6A
        @cpu.runop(@op, 0x24)
        assert_equal 0, @cpu.flag[:C]
      end

      should "set the zero flag if the value in the accumulator is equal to the value to be compared" do
        @cpu.ram[0x24] = 0x69
        @cpu.runop(@op, 0x24)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the values to be compared are not equal" do
        @cpu.ram[0x24] = 0x6A
        @cpu.runop(@op, 0x24)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.ram[0x24] = 0x7F
        @cpu.register[:A] = 0XFF
        @cpu.runop(@op, 0x24)
        assert_equal 1, @cpu.flag[:N]
      end

      should "not set the negative flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.ram[0x24] = 0x68
        @cpu.runop(@op, 0x24)
        assert_equal 0, @cpu.flag[:N]
      end
    end

    context "zeropagex mode" do
      setup do
        @op = 0xD5
        @cpu.register[:A] = 0x69
        @cpu.register[:X] = 0x04
      end

      should_increase_pc_by 2
      should_increase_cycles_by 4

      should "set the carry flag if the value in the accumulator is greater than or equal to the value to compare with" do
        @cpu.ram[0x50] = 0x40
        @cpu.ram[0x51] = 0x69
        @cpu.runop(@op, 0x4C)
        assert_equal 1, @cpu.flag[:C]

        @cpu.runop(@op, 0x4D)
        assert_equal 1, @cpu.flag[:C]
      end

      should "not set the carry flag if the value in the accumulator is less than the value to compare with" do
        @cpu.ram[0x24] = 0x6A
        @cpu.runop(@op, 0x20)
        assert_equal 0, @cpu.flag[:C]
      end

      should "set the zero flag if the value in the accumulator is equal to the value to be compared" do
        @cpu.ram[0x24] = 0x69
        @cpu.runop(@op, 0x20)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the values to be compared are not equal" do
        @cpu.ram[0x24] = 0x6A
        @cpu.runop(@op, 0x20)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.ram[0x24] = 0x7F
        @cpu.register[:A] = 0XFF
        @cpu.runop(@op, 0x20)
        assert_equal 1, @cpu.flag[:N]
      end

      should "not set the negative flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.ram[0x24] = 0x68
        @cpu.runop(@op, 0x20)
        assert_equal 0, @cpu.flag[:N]
      end

      should "wrap larger addresses around to stay on the zero page" do
        @cpu.ram[0x24] = 0x69 # good result, will set the zero flag
        @cpu.ram[0x24 + 0xFF] = 0xB0 # wrong result, didn't wrap
        @cpu.register[:X] = 0xFF
        @cpu.runop(@op, 0x24)
        assert_equal 1, @cpu.flag[:Z]
      end
    end

    context "absolute mode" do
      setup do
        @op = 0xCD
        @cpu.register[:A] = 0x69
      end

      should_increase_pc_by 3
      should_increase_cycles_by 4

      should "set the carry flag if the value in the accumulator is greater than or equal to the value to compare with" do
        @cpu.ram[0x5050] = 0x40
        @cpu.ram[0x5150] = 0x69
        @cpu.runop(@op, 0x50, 0x50)
        assert_equal 1, @cpu.flag[:C]

        @cpu.runop(@op, 0x51, 0x50)
        assert_equal 1, @cpu.flag[:C]
      end

      should "not set the carry flag if the value in the accumulator is less than the value to compare with" do
        @cpu.ram[0x2450] = 0x6A
        @cpu.runop(@op, 0x24, 0x50)
        assert_equal 0, @cpu.flag[:C]
      end

      should "set the zero flag if the value in the accumulator is equal to the value to be compared" do
        @cpu.ram[0x2450] = 0x69
        @cpu.runop(@op, 0x24, 0x50)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the values to be compared are not equal" do
        @cpu.ram[0x2450] = 0x6A
        @cpu.runop(@op, 0x24, 0x50)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.ram[0x2450] = 0x7F
        @cpu.register[:A] = 0XFF
        @cpu.runop(@op, 0x24, 0x50)
        assert_equal 1, @cpu.flag[:N]
      end

      should "not set the negative flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.ram[0x2450] = 0x68
        @cpu.runop(@op, 0x24, 0x50)
        assert_equal 0, @cpu.flag[:N]
      end
    end

    context "absolutex mode" do
      setup do
        @op = 0xDD
        @cpu.register[:A] = 0x69
        @cpu.register[:X] = 0x04
      end

      should_increase_pc_by 3
      should_increase_cycles_with_boundary_check_by 4

      should "set the carry flag if the value in the accumulator is greater than or equal to the value to compare with" do
        @cpu.ram[0x5050] = 0x40
        @cpu.ram[0x5150] = 0x69
        @cpu.runop(@op, 0x50, 0x4C)
        assert_equal 1, @cpu.flag[:C]

        @cpu.runop(@op, 0x51, 0x4C)
        assert_equal 1, @cpu.flag[:C]
      end

      should "not set the carry flag if the value in the accumulator is less than the value to compare with" do
        @cpu.ram[0x2450] = 0x6A
        @cpu.runop(@op, 0x24, 0x4C)
        assert_equal 0, @cpu.flag[:C]
      end

      should "set the zero flag if the value in the accumulator is equal to the value to be compared" do
        @cpu.ram[0x2450] = 0x69
        @cpu.runop(@op, 0x24, 0x4C)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the values to be compared are not equal" do
        @cpu.ram[0x2450] = 0x6A
        @cpu.runop(@op, 0x24, 0x4C)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.ram[0x2450] = 0x7F
        @cpu.register[:A] = 0XFF
        @cpu.runop(@op, 0x24, 0x4C)
        assert_equal 1, @cpu.flag[:N]
      end

      should "not set the negative flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.ram[0x2450] = 0x68
        @cpu.runop(@op, 0x24, 0x4C)
        assert_equal 0, @cpu.flag[:N]
      end
    end

    context "absolutey mode" do
      setup do
        @op = 0xD9
        @cpu.register[:A] = 0x69
        @cpu.register[:Y] = 0x04
      end

      should_increase_pc_by 3
      should_increase_cycles_with_boundary_check_by 4

      should "set the carry flag if the value in the accumulator is greater than or equal to the value to compare with" do
        @cpu.ram[0x5050] = 0x40
        @cpu.ram[0x5150] = 0x69
        @cpu.runop(@op, 0x50, 0x4C)
        assert_equal 1, @cpu.flag[:C]

        @cpu.runop(@op, 0x51, 0x4C)
        assert_equal 1, @cpu.flag[:C]
      end

      should "not set the carry flag if the value in the accumulator is less than the value to compare with" do
        @cpu.ram[0x2450] = 0x6A
        @cpu.runop(@op, 0x24, 0x4C)
        assert_equal 0, @cpu.flag[:C]
      end

      should "set the zero flag if the value in the accumulator is equal to the value to be compared" do
        @cpu.ram[0x2450] = 0x69
        @cpu.runop(@op, 0x24, 0x4C)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the values to be compared are not equal" do
        @cpu.ram[0x2450] = 0x6A
        @cpu.runop(@op, 0x24, 0x4C)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.ram[0x2450] = 0x7F
        @cpu.register[:A] = 0XFF
        @cpu.runop(@op, 0x24, 0x4C)
        assert_equal 1, @cpu.flag[:N]
      end

      should "not set the negative flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.ram[0x2450] = 0x68
        @cpu.runop(@op, 0x24, 0x4C)
        assert_equal 0, @cpu.flag[:N]
      end
    end

    context "indirectx mode" do
      setup do
        @op = 0xC1
        @cpu.register[:A] = 0x69
        @cpu.register[:X] = 0x04
        @cpu.ram[0x50] = 0x28 # lo byte
        @cpu.ram[0x51] = 0x7C # hi byte
        @cpu.ram[0x7C28] = 0x20
      end

      should_increase_pc_by 2
      should_increase_cycles_by 6

      should "set the carry flag if the value in the accumulator is greater than or equal to the value to compare with" do
        @cpu.runop(@op, 0x4C)
        assert_equal 1, @cpu.flag[:C]

        @cpu.ram[0x7C28] = 0x69
        @cpu.runop(@op, 0x4C)
        assert_equal 1, @cpu.flag[:C]
      end

      should "not set the carry flag if the value in the accumulator is less than the value to compare with" do
        @cpu.ram[0x7C28] = 0x6A
        @cpu.runop(@op, 0x4C)
        assert_equal 0, @cpu.flag[:C]
      end

      should "set the zero flag if the value in the accumulator is equal to the value to be compared" do
        @cpu.ram[0x7C28] = 0x69
        @cpu.runop(@op, 0x4C)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the values to be compared are not equal" do
        @cpu.ram[0x7C28] = 0x6A
        @cpu.runop(@op, 0x4C)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.ram[0x7C28] = 0x7F
        @cpu.register[:A] = 0XFF
        @cpu.runop(@op, 0x4C)
        assert_equal 1, @cpu.flag[:N]
      end

      should "not set the negative flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.ram[0x7C28] = 0x68
        @cpu.runop(@op, 0x4C)
        assert_equal 0, @cpu.flag[:N]
      end

      should "not let a calculated address overflow off of the zero page" do
        @cpu.register[:X] = 0xFF
        @cpu.runop(@op, 0x50)
        assert_equal 1, @cpu.flag[:C]
      end
    end

    context "indirecty mode" do
      setup do
        @op = 0xD1
        @cpu.register[:A] = 0x69
        @cpu.register[:Y] = 0x04
        @cpu.ram[0x50] = 0x4C # lo byte
        @cpu.ram[0x51] = 0x24 # hi byte
        @cpu.ram[0x2450] = 0x20
      end

      should_increase_pc_by 2
      should_increase_cycles_with_boundary_check_by 5

      should "set the carry flag if the value in the accumulator is greater than or equal to the value to compare with" do
        @cpu.runop(@op, 0x50)
        assert_equal 1, @cpu.flag[:C]

        @cpu.ram[0x2450] = 0x69
        @cpu.runop(@op, 0x50)
        assert_equal 1, @cpu.flag[:C]
      end

      should "not set the carry flag if the value in the accumulator is less than the value to compare with" do
        @cpu.ram[0x2450] = 0x6A
        @cpu.runop(@op, 0x50)
        assert_equal 0, @cpu.flag[:C]
      end

      should "set the zero flag if the value in the accumulator is equal to the value to be compared" do
        @cpu.ram[0x2450] = 0x69
        @cpu.runop(@op, 0x50)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the values to be compared are not equal" do
        @cpu.ram[0x2450] = 0x6A
        @cpu.runop(@op, 0x50)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.ram[0x2450] = 0x7F
        @cpu.register[:A] = 0XFF
        @cpu.runop(@op, 0x50)
        assert_equal 1, @cpu.flag[:N]
      end

      should "not set the negative flag if bit 7 of the result of accumulator - value to be compared is set" do
        @cpu.ram[0x2450] = 0x68
        @cpu.runop(@op, 0x50)
        assert_equal 0, @cpu.flag[:N]
      end
    end

  end
end