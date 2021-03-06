require File.expand_path('../../../test_helper', File.dirname(__FILE__))

class Cpu6502SbcTest < Test::Unit::TestCase
  context "SBC" do
    setup do
      @cpu = Cpu6502.new
    end

    context "immediate mode" do
      setup do
        @op = 0xE9
      end

      should_increase_pc_by 2
      should_increase_cycles_by 2
      
      context "with decimal mode on" do
        setup do
          @cpu.flag[:D] = 1
        end

        should "subtract the passed value from the accumulator, subtracting one more if the carry flag is clear, using BCD mode" do
          @cpu.register[:A] = 0x08
          @cpu.flag[:C] = 0
          @cpu.runop(@op, 0x05)
          assert_equal 0x02, @cpu.register[:A]
        end

        should "set the carry flag if no borrow was required" do
          @cpu.register[:A] = 0x40
          @cpu.runop(@op, 0x10)
          assert_equal 1, @cpu.flag[:C]
        end

        should "clear the carry flag if a borrow was required" do
          @cpu.register[:A] = 0x30
          @cpu.runop(@op, 0x45)
          assert_equal 0, @cpu.flag[:C]
        end

        # zero flag in decimal mode is invalid on 6502
        should "set the zero flag if the result is 0" do
          @cpu.register[:A] = 0x01
          @cpu.runop(@op, 0x00)
          assert_equal 1, @cpu.flag[:Z]
        end

        should "clear the zero flag if the result is not zero" do
          @cpu.register[:A] = 0x08
          @cpu.runop(@op, 0x02)
          assert_equal 0, @cpu.flag[:Z]
        end

        # negative flag in decimal mode is invalid on 6502
        should "set the negative flag if bit 7 in the result is set" do
          @cpu.register[:A] = 0x09
          @cpu.runop(@op, 0x99)
          assert_equal 1, @cpu.flag[:N]
        end

        should "clear the negative flag if bit 7 in the result is not set" do
          @cpu.register[:A] = 0x15
          @cpu.runop(@op, 0x10)
          assert_equal 0, @cpu.flag[:N]
        end
      end

      context "with decimal mode off" do
        should "add the passed value and the value of the carry flag bit to the present value of the accumulator" do
          @cpu.register[:A] = 0x08
          @cpu.runop(@op, 0x05)
          assert_equal 0x08 - 0x05 - 1, @cpu.register[:A]
        end

        should "set the zero flag if the result is 0" do
          @cpu.register[:A] = 0x00
          @cpu.flag[:C] = 1
          @cpu.runop(@op, 0x00)
          assert_equal 1, @cpu.flag[:Z]
        end

        should "clear the zero flag if the result is not zero" do
          @cpu.register[:A] = 0x08
          @cpu.runop(@op, 0x02)
          assert_equal 0, @cpu.flag[:Z]
        end

        should "set the carry flag if no borrow was required" do
          @cpu.register[:A] = 0xFE
          @cpu.runop(@op, 0x02)
          assert_equal 1, @cpu.flag[:C]
        end

        should "clear the carry flag if borrow was required" do
          @cpu.register[:A] = 0x05
          @cpu.runop(@op, 0xFE)
          assert_equal 0, @cpu.flag[:C]
        end

        should "set the overflow flag if the sign of the result is wrong" do
          @cpu.register[:A] = 0x07
          @cpu.runop(@op, 0x7A)
          assert_equal 1, @cpu.flag[:V]
        end

        should "clear the overflow flag if the sign of the result is ok" do
          @cpu.register[:A] = 0x05
          @cpu.runop(@op, 0x04)
          assert_equal 0, @cpu.flag[:V]
        end

        should "set the negative flag if bit 7 in the result is set" do
          @cpu.register[:A] = 0x90
          @cpu.runop(@op, 0x01)
          assert_equal 1, @cpu.flag[:N]
        end

        should "clear the negative flag if bit 7 in the result is not set" do
          @cpu.register[:A] = 0x0A
          @cpu.runop(@op, 0x05)
          assert_equal 0, @cpu.flag[:N]
        end
      end
    end

    context "zeropage mode" do
      setup do
        @op = 0xE5
      end

      should_increase_pc_by 2
      should_increase_cycles_by 3
      
      context "with decimal mode on" do
        setup do
          @cpu.flag[:D] = 1
        end

        should "subtract the value at the memory location of the passed value from the accumulator, subtracting an additional one if the carry bit is clear, and store it in the accumulator, using BCD mode" do
          @cpu.register[:A] = 0x69
          @cpu.ram[0x05] = 0x08
          @cpu.runop(@op, 0x05)
          assert_equal 0x60, @cpu.register[:A]
        end

        should "set the carry flag if no borrow was required" do
          @cpu.register[:A] = 0x40
          @cpu.ram[0x60] = 0x38
          @cpu.runop(@op, 0x60)
          assert_equal 1, @cpu.flag[:C]
        end

        should "clear the carry flag if borrow was required" do
          @cpu.register[:A] = 0x30
          @cpu.ram[0x25] = 0x69
          @cpu.runop(@op, 0x25)
          assert_equal 0, @cpu.flag[:C]
        end

        # zero flag in decimal mode is undefined on 6502
        should "set the zero flag if the result is 0" do
          @cpu.register[:A] = 0x01
          @cpu.ram[0x42] = 0x00
          @cpu.runop(@op, 0x42)
          assert_equal 1, @cpu.flag[:Z]
        end

        should "clear the zero flag if the result is not zero" do
          @cpu.register[:A] = 0x08
          @cpu.ram[0x42] = 0x69
          @cpu.runop(@op, 0x42)
          assert_equal 0, @cpu.flag[:Z]
        end

        # negative flag in decimal mode is undefined on 6502
        should "set the negative flag if bit 7 in the result is set" do
          @cpu.register[:A] = 0x10
          @cpu.ram[0x42] = 0x11
          @cpu.runop(@op, 0x42)
          assert_equal 1, @cpu.flag[:N]
        end

        should "clear the negative flag if bit 7 in the result is not set" do
          @cpu.register[:A] = 0x10
          @cpu.ram[0x42] = 0x05
          @cpu.runop(@op, 0x42)
          assert_equal 0, @cpu.flag[:N]
        end
      end

      context "with decimal mode off" do
        should "subtract the correct value from the accumulator, subtracting an additional one if the carry bit is clear, and store the result in the accumulator" do
          @cpu.register[:A] = 0x08
          @cpu.ram[0x42] = 0x05
          @cpu.runop(@op, 0x42)
          assert_equal 0x08 - 0x05 - 1, @cpu.register[:A]
        end

        should "set the zero flag if the result is 0" do
          @cpu.register[:A] = 0x01
          @cpu.ram[0x42] = 0x00
          @cpu.runop(@op, 0x42)
          assert_equal 1, @cpu.flag[:Z]
        end

        should "clear the zero flag if the result is not zero" do
          @cpu.register[:A] = 0x08
          @cpu.ram[0x42] = 0x05
          @cpu.runop(@op, 0x42)
          assert_equal 0, @cpu.flag[:Z]
        end

        should "set the carry flag if the result did not requir a borrow" do
          @cpu.register[:A] = 0xFE
          @cpu.ram[0x42] = 0x02
          @cpu.runop(@op, 0x42)
          assert_equal 1, @cpu.flag[:C]
        end

        should "clear the carry flag if the result required a borrow" do
          @cpu.register[:A] = 0x01
          @cpu.ram[0x42] = 0xFE
          @cpu.runop(@op, 0x42)
          assert_equal 0, @cpu.flag[:C]
        end

        should "set the overflow flag if the sign of the result is wrong" do
          @cpu.register[:A] = 0x07
          @cpu.ram[0x42] = 0x7A
          @cpu.runop(@op, 0x42)
          assert_equal 1, @cpu.flag[:V]
        end

        should "clear the overflow flag if the sign of the result is ok" do
          @cpu.register[:A] = 0x0A
          @cpu.ram[0x42] = 0x05
          @cpu.runop(@op, 0x42)
          assert_equal 0, @cpu.flag[:V]
        end

        should "set the negative flag if bit 7 in the result is set" do
          @cpu.register[:A] = 0x00
          @cpu.ram[0x42] = 0x10
          @cpu.runop(@op, 0x42)
          assert_equal 1, @cpu.flag[:N]
        end

        should "clear the negative flag if bit 7 in the result is not set" do
          @cpu.register[:A] = 0x05
          @cpu.ram[0x42] = 0x04
          @cpu.runop(@op, 0x42)
          assert_equal 0, @cpu.flag[:N]
        end
      end
    end

    context "zeropagex mode" do
      setup do
        @op = 0xF5
        @cpu.register[:X] = 0x04
      end

      should_increase_pc_by 2
      should_increase_cycles_by 4

      context "with decimal mode on" do
        setup do
          @cpu.flag[:D] = 1
        end

        should "subtract the correct value from the accumulator, subtracting one more of the carry flag is clear, storing the result in the accumulator, using BCD mode" do
          @cpu.register[:A] = 0x08
          @cpu.ram[0x09] = 0x04
          @cpu.runop(@op, 0x05)
          assert_equal 0x03, @cpu.register[:A]
        end

        should "set the carry flag if no borrow was required" do
          @cpu.register[:A] = 0x40
          @cpu.ram[0x64] = 0x29
          @cpu.runop(@op, 0x60)
          assert_equal 1, @cpu.flag[:C]
        end

        should "clear the carry flag if borrow was required" do
          @cpu.register[:A] = 0x30
          @cpu.ram[0x25] = 0x69
          @cpu.runop(@op, 0x21)
          assert_equal 0, @cpu.flag[:C]
        end

        # zero flag in decimal mode is undefined on 6502
        should "set the zero flag if the result is 0" do
          @cpu.register[:A] = 0x01
          @cpu.ram[0x42] = 0x00
          @cpu.runop(@op, 0x3E)
          assert_equal 1, @cpu.flag[:Z]
        end

        should "clear the zero flag if the result is not zero" do
          @cpu.register[:A] = 0x08
          @cpu.ram[0x42] = 0x69
          @cpu.runop(@op, 0x3E)
          assert_equal 0, @cpu.flag[:Z]
        end

        # negative flag in decimal mode is undefined on 6502
        should "set the negative flag if bit 7 in the result is set" do
          @cpu.register[:A] = 0x44
          @cpu.ram[0x42] = 0x90
          @cpu.runop(@op, 0x3E)
          assert_equal 1, @cpu.flag[:N]
        end

        should "clear the negative flag if bit 7 in the result is not set" do
          @cpu.register[:A] = 0x15
          @cpu.ram[0x42] = 0x10
          @cpu.runop(@op, 0x3E)
          assert_equal 0, @cpu.flag[:N]
        end
      end

      context "with decimal mode off" do
        should "subtract the correct value from the accumulator, subtracting an extra one if the carry flag is clear, storing the result in the accumulator" do
          @cpu.register[:A] = 0x08
          @cpu.ram[0x42] = 0x05
          @cpu.runop(@op, 0x3E)
          assert_equal 0x08 - 0x05 - 1, @cpu.register[:A]
        end

        should "set the zero flag if the result is 0" do
          @cpu.register[:A] = 0x01
          @cpu.ram[0x42] = 0x00
          @cpu.runop(@op, 0x3E)
          assert_equal 1, @cpu.flag[:Z]
        end

        should "clear the zero flag if the result is not zero" do
          @cpu.register[:A] = 0x08
          @cpu.ram[0x42] = 0x05
          @cpu.runop(@op, 0x3E)
          assert_equal 0, @cpu.flag[:Z]
        end

        should "set the carry flag if no borrow was required" do
          @cpu.register[:A] = 0xFE
          @cpu.ram[0x42] = 0x02
          @cpu.runop(@op, 0x3E)
          assert_equal 1, @cpu.flag[:C]
        end

        should "clear the carry flag if borrow was required" do
          @cpu.register[:A] = 0x01
          @cpu.ram[0x42] = 0x02
          @cpu.runop(@op, 0x3E)
          assert_equal 0, @cpu.flag[:C]
        end

        should "set the overflow flag if the sign of the result is wrong" do
          @cpu.register[:A] = 0x82
          @cpu.ram[0x42] = 0x81
          @cpu.runop(@op, 0x3E)
          assert_equal 1, @cpu.flag[:V]
        end

        should "clear the overflow flag if the sign of the result is ok" do
          @cpu.register[:A] = 0x0A
          @cpu.ram[0x42] = 0x05
          @cpu.runop(@op, 0x3E)
          assert_equal 0, @cpu.flag[:V]
        end

        should "set the negative flag if bit 7 in the result is set" do
          @cpu.register[:A] = 0xFF
          @cpu.ram[0x42] = 0x02
          @cpu.runop(@op, 0x3E)
          assert_equal 1, @cpu.flag[:N]
        end

        should "clear the negative flag if bit 7 in the result is not set" do
          @cpu.register[:A] = 0x0A
          @cpu.ram[0x42] = 0x05
          @cpu.runop(@op, 0x3E)
          assert_equal 0, @cpu.flag[:N]
        end
      end

      should "wrap too-large addresses around so they fit on the zero page" do
        @cpu.register[:A] = 0x0A
        @cpu.register[:X] = 0xFF
        @cpu.ram[0xFE] = 0x01
        @cpu.ram[0xFE + 0xFF] = 0x02
        @cpu.runop(@op, 0xFE)
        assert_equal 0x08, @cpu.register[:A]
      end
    end

    context "absolute mode" do
      setup do
        @op = 0xED
      end

      should_increase_pc_by 3
      should_increase_cycles_by 4

      context "with decimal mode on" do
        setup do
          @cpu.flag[:D] = 1
        end

        should "subtract the correct value from the accumulator, subtracting one more if the carry flag is clear, using BCD mode" do
          @cpu.register[:A] = 0x80
          @cpu.ram[0x2436] = 0x42
          @cpu.runop(@op, 0x24, 0x36)
          assert_equal 0x37, @cpu.register[:A]
        end

        should "set the carry flag if no borrow was required" do
          @cpu.register[:A] = 0x40
          @cpu.ram[0x2436] = 0x29
          @cpu.runop(@op, 0x24, 0x36)
          assert_equal 1, @cpu.flag[:C]
        end

        should "clear the carry flag if borrow was required" do
          @cpu.register[:A] = 0x30
          @cpu.ram[0x2436] = 0x69
          @cpu.runop(@op, 0x24, 0x36)
          assert_equal 0, @cpu.flag[:C]
        end

        # zero flag in decimal mode is undefined on 6502
        should "set the zero flag if the result is 0" do
          @cpu.register[:A] = 0x01
          @cpu.ram[0x2436] = 0x00
          @cpu.runop(@op, 0x24, 0x36)
          assert_equal 1, @cpu.flag[:Z]
        end

        should "clear the zero flag if the result is not zero" do
          @cpu.register[:A] = 0x08
          @cpu.ram[0x2436] = 0x69
          @cpu.runop(@op, 0x24, 0x36)
          assert_equal 0, @cpu.flag[:Z]
        end

        # negative flag in decimal mode is undefined on 6502
        should "set the negative flag if bit 7 in the result is set" do
          @cpu.register[:A] = 0x87
          @cpu.ram[0x2436] = 0x88
          @cpu.runop(@op, 0x24, 0x36)
          assert_equal 1, @cpu.flag[:N]
        end

        should "clear the negative flag if bit 7 in the result is not set" do
          @cpu.register[:A] = 0x10
          @cpu.ram[0x2436] = 0x05
          @cpu.runop(@op, 0x24, 0x36)
          assert_equal 0, @cpu.flag[:N]
        end
      end

      context "with decimal mode off" do
        should "add the passed value and the value of the carry flag bit to the present value of the accumulator" do
          @cpu.register[:A] = 0x08
          @cpu.ram[0x2436] = 0x05
          @cpu.runop(@op, 0x24, 0x36)
          assert_equal 0x08 - 0x05 - 1, @cpu.register[:A]
        end

        should "set the zero flag if the result is 0" do
          @cpu.register[:A] = 0x01
          @cpu.ram[0x2436] = 0x00
          @cpu.runop(@op, 0x24, 0x36)
          assert_equal 1, @cpu.flag[:Z]
        end

        should "clear the zero flag if the result is not zero" do
          @cpu.register[:A] = 0x08
          @cpu.ram[0x2436] = 0x05
          @cpu.runop(@op, 0x24, 0x36)
          assert_equal 0, @cpu.flag[:Z]
        end

        should "set the carry flag if no borrow was required" do
          @cpu.register[:A] = 0xFE
          @cpu.ram[0x2436] = 0x02
          @cpu.runop(@op, 0x24, 0x36)
          assert_equal 1, @cpu.flag[:C]
        end

        should "clear the carry flag if borrow was required" do
          @cpu.register[:A] = 0x10
          @cpu.ram[0x2436] = 0x15
          @cpu.runop(@op, 0x24, 0x36)
          assert_equal 0, @cpu.flag[:C]
        end

        should "set the overflow flag if the sign of the result is wrong" do
          @cpu.register[:A] = 0x07
          @cpu.ram[0x2436] = 0x7A
          @cpu.runop(@op, 0x24, 0x36)
          assert_equal 1, @cpu.flag[:V]
        end

        should "clear the overflow flag if the sign of the result is ok" do
          @cpu.register[:A] = 0x15
          @cpu.ram[0x2436] = 0x0A
          @cpu.runop(@op, 0x24, 0x36)
          assert_equal 0, @cpu.flag[:V]
        end

        should "set the negative flag if bit 7 in the result is set" do
          @cpu.register[:A] = 0x02
          @cpu.ram[0x2436] = 0x10
          @cpu.runop(@op, 0x24, 0x36)
          assert_equal 1, @cpu.flag[:N]
        end

        should "clear the negative flag if bit 7 in the result is not set" do
          @cpu.register[:A] = 0x0A
          @cpu.ram[0x2436] = 0x05
          @cpu.runop(@op, 0x24, 0x36)
          assert_equal 0, @cpu.flag[:N]
        end
      end
    end

    context "absolutex mode" do
      setup do
        @op = 0xFD
        @cpu.register[:X] = 0x04
      end

      should_increase_pc_by 3
      should_increase_cycles_with_boundary_check_by 4

      context "with decimal mode on" do
        setup do
          @cpu.flag[:D] = 1
        end

        should "subtract the correct value from the value in the accumulator, subtracting an extra one if the carry flag is clear, using BCD mode" do
          @cpu.register[:A] = 0x69
          @cpu.ram[0x2436] = 0x08
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 0x60, @cpu.register[:A]
        end

        should "set the carry flag if no borrow was required" do
          @cpu.register[:A] = 0x70
          @cpu.ram[0x2436] = 0x69
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 1, @cpu.flag[:C]
        end

        should "clear the carry flag if borrow was required" do
          @cpu.register[:A] = 0x30
          @cpu.ram[0x2436] = 0x69
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 0, @cpu.flag[:C]
        end

        # zero flag in decimal mode is undefined on 6502
        should "set the zero flag if the result is 0" do
          @cpu.register[:A] = 0x01
          @cpu.ram[0x2436] = 0x00
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 1, @cpu.flag[:Z]
        end

        should "clear the zero flag if the result is not zero" do
          @cpu.register[:A] = 0x08
          @cpu.ram[0x2436] = 0x69
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 0, @cpu.flag[:Z]
        end

        # negative flag in decimal mode is undefined on 6502
        should "set the negative flag if bit 7 in the result is set" do
          @cpu.register[:A] = 0x60
          @cpu.ram[0x2436] = 0x90
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 1, @cpu.flag[:N]
        end

        should "clear the negative flag if bit 7 in the result is clear" do
          @cpu.register[:A] = 0x15
          @cpu.ram[0x2436] = 0x10
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 0, @cpu.flag[:N]
        end
      end

      context "with decimal mode off" do
        should "subtract the correct value from the value in the accumulator, subtracting an extra one if the carry flag is clear, storing the result in the accumulator" do
          @cpu.register[:A] = 0x08
          @cpu.ram[0x2436] = 0x05
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 0x08 - 0x05 - 1, @cpu.register[:A]
        end

        should "set the zero flag if the result is 0" do
          @cpu.register[:A] = 0x01
          @cpu.ram[0x2436] = 0x00
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 1, @cpu.flag[:Z]
        end

        should "clear the zero flag if the result is not zero" do
          @cpu.register[:A] = 0x08
          @cpu.ram[0x2436] = 0x05
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 0, @cpu.flag[:Z]
        end

        should "set the carry flag if no borrow was required" do
          @cpu.register[:A] = 0xFE
          @cpu.ram[0x2436] = 0x02
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 1, @cpu.flag[:C]
        end

        should "clear the carry flag if borrow was required" do
          @cpu.register[:A] = 0x02
          @cpu.ram[0x2436] = 0x10
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 0, @cpu.flag[:C]
        end

        should "set the overflow flag if the sign of the result is wrong" do
          @cpu.register[:A] = 0x07
          @cpu.ram[0x2436] = 0x7A
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 1, @cpu.flag[:V]
        end

        should "clear the overflow flag if the sign of the result is ok" do
          @cpu.register[:A] = 0x0A
          @cpu.ram[0x2436] = 0x05
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 0, @cpu.flag[:V]
        end

        should "set the negative flag if bit 7 in the result is set" do
          @cpu.register[:A] = 0x00
          @cpu.ram[0x2436] = 0x04
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 1, @cpu.flag[:N]
        end

        should "clear the negative flag if bit 7 in the result is not set" do
          @cpu.register[:A] = 0x05
          @cpu.ram[0x2436] = 0x03
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 0, @cpu.flag[:N]
        end
      end
    end

    context "absolutey mode" do
      setup do
        @op = 0xF9
        @cpu.register[:Y] = 0x04
      end

      should_increase_pc_by 3
      should_increase_cycles_with_boundary_check_by 4
      
      context "with decimal mode on" do
        setup do
          @cpu.flag[:D] = 1
        end

        should "subtract the correct value from the value in the accumulator, subtracting an extra one if the carry flag is clear, using BCD mode" do
          @cpu.register[:A] = 0x69
          @cpu.ram[0x2436] = 0x08
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 0x60, @cpu.register[:A]
        end

        should "set the carry flag if no borrow was required" do
          @cpu.register[:A] = 0x70
          @cpu.ram[0x2436] = 0x69
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 1, @cpu.flag[:C]
        end

        should "clear the carry flag if borrow was required" do
          @cpu.register[:A] = 0x30
          @cpu.ram[0x2436] = 0x69
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 0, @cpu.flag[:C]
        end

        # zero flag in decimal mode is undefined on 6502
        should "set the zero flag if the result is 0" do
          @cpu.register[:A] = 0x01
          @cpu.ram[0x2436] = 0x00
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 1, @cpu.flag[:Z]
        end

        should "clear the zero flag if the result is not zero" do
          @cpu.register[:A] = 0x08
          @cpu.ram[0x2436] = 0x69
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 0, @cpu.flag[:Z]
        end

        # negative flag in decimal mode is undefined on 6502
        should "set the negative flag if bit 7 in the result is set" do
          @cpu.register[:A] = 0x60
          @cpu.ram[0x2436] = 0x90
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 1, @cpu.flag[:N]
        end

        should "clear the negative flag if bit 7 in the result is not set" do
          @cpu.register[:A] = 0x15
          @cpu.ram[0x2436] = 0x10
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 0, @cpu.flag[:N]
        end
      end

      context "with decimal mode off" do
        should "subtract the correct value from the accumulator, subtracting an additional one if the carry flag is clear, storing the result in the accumulator" do
          @cpu.register[:A] = 0x08
          @cpu.ram[0x2436] = 0x05
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 0x08 - 0x05 - 1, @cpu.register[:A]
        end

        should "set the zero flag if the result is 0" do
          @cpu.register[:A] = 0x01
          @cpu.ram[0x2436] = 0x00
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 1, @cpu.flag[:Z]
        end

        should "clear the zero flag if the result is not zero" do
          @cpu.register[:A] = 0x08
          @cpu.ram[0x2436] = 0x05
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 0, @cpu.flag[:Z]
        end

        should "set the carry flag if no borrow was required" do
          @cpu.register[:A] = 0xFE
          @cpu.ram[0x2436] = 0x02
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 1, @cpu.flag[:C]
        end

        should "clear the carry flag if borrow was required" do
          @cpu.register[:A] = 0x10
          @cpu.ram[0x2436] = 0x20
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 0, @cpu.flag[:C]
        end

        should "set the overflow flag if the sign of the result is wrong" do
          @cpu.register[:A] = 0x07
          @cpu.ram[0x2436] = 0x7A
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 1, @cpu.flag[:V]
        end

        should "clear the overflow flag if the sign of the result is ok" do
          @cpu.register[:A] = 0x0A
          @cpu.ram[0x2436] = 0x05
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 0, @cpu.flag[:V]
        end

        should "set the negative flag if bit 7 in the result is set" do
          @cpu.register[:A] = 0x00
          @cpu.ram[0x2436] = 0x10
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 1, @cpu.flag[:N]
        end

        should "clear the negative flag if bit 7 in the result is not set" do
          @cpu.register[:A] = 0x05
          @cpu.ram[0x2436] = 0x03
          @cpu.runop(@op, 0x24, 0x32)
          assert_equal 0, @cpu.flag[:N]
        end
      end
    end

    context "indirectx mode" do
      setup do
        @op = 0xE1
        @cpu.register[:X] = 0x04
        @cpu.ram[0x35] = 0x02
        @cpu.ram[0x36] = 0x20
        @cpu.ram[(0x20 << 8) | 0x02] = 0x69
      end

      should_increase_pc_by 2
      should_increase_cycles_by 6
      
      context "with decimal mode on" do
        setup do
          @cpu.flag[:D] = 1
        end

        should "subtract the correct value from the accumulator, subtracting an additional one if the carry flag is clear, storing the result in the accumulator, using BCD mode" do
          @cpu.register[:A] = 0x80
          @cpu.runop(@op, 0x31)
          assert_equal 0x10, @cpu.register[:A]
        end

        should "set the carry flag if borrow was required" do
          @cpu.register[:A] = 0x01
          @cpu.runop(@op, 0xFF)
          assert_equal 1, @cpu.flag[:C]
        end

        should "clear the carry flag if borrow was not required" do
          @cpu.register[:A] = 0x40
          @cpu.runop(@op, 0x31)
          assert_equal 0, @cpu.flag[:C]
        end

        # zero flag in decimal mode is undefined on 6502
        should "set the zero flag if the result is 0" do
          @cpu.register[:A] = 0x01
          @cpu.ram[(0x20 << 8) | 0x02] = 0x00
          @cpu.runop(@op, 0x31)
          assert_equal 1, @cpu.flag[:Z]
        end

        should "clear the zero flag if the result is not zero" do
          @cpu.register[:A] = 0x08
          @cpu.runop(@op, 0x31)
          assert_equal 0, @cpu.flag[:Z]
        end

        # negative flag in decimal mode is undefined on 6502
        should "set the negative flag if bit 7 in the result is set" do
          @cpu.register[:A] = 0x94
          @cpu.ram[(0x20 << 8) | 0x02] = 0x96
          @cpu.runop(@op, 0x31)
          assert_equal 1, @cpu.flag[:N]
        end

        should "clear the negative flag if bit 7 in the result is not set" do
          @cpu.register[:A] = 0x80
          @cpu.runop(@op, 0x31)
          assert_equal 0, @cpu.flag[:N]
        end
      end

      context "with decimal mode off" do
        should "subtract the correct value from the accumulator, subtracting an additional one if the carry flag is clear, storing the result in the accumulator" do
          @cpu.register[:A] = 0x80
          @cpu.runop(@op, 0x31)
          assert_equal 0x80 - 0x69 - 1, @cpu.register[:A]
        end

        should "set the zero flag if the result is 0" do
          @cpu.register[:A] = 0x01
          @cpu.ram[(0x20 << 8) | 0x02] = 0x00
          @cpu.runop(@op, 0x31)
          assert_equal 1, @cpu.flag[:Z]
        end

        should "clear the zero flag if the result is not zero" do
          @cpu.register[:A] = 0x08
          @cpu.runop(@op, 0x31)
          assert_equal 0, @cpu.flag[:Z]
        end

        should "set the carry flag if borrow was not required" do
          @cpu.register[:A] = 0x90
          @cpu.runop(@op, 0x31)
          assert_equal 1, @cpu.flag[:C]
        end

        should "clear the carry flag if borrow was required" do
          @cpu.register[:A] = 0x40
          @cpu.runop(@op, 0x31)
          assert_equal 0, @cpu.flag[:C]
        end

        should "set the overflow flag if the sign of the result is wrong" do
          @cpu.register[:A] = 0x07
          @cpu.ram[(0x20 << 8) | 0x02] = 0x7A
          @cpu.runop(@op, 0x31)
          assert_equal 1, @cpu.flag[:V]
        end

        should "clear the overflow flag if the sign of the result is ok" do
          @cpu.register[:A] = 0x80
          @cpu.runop(@op, 0x31)
          assert_equal 0, @cpu.flag[:V]
        end

        should "set the negative flag if bit 7 in the result is set" do
          @cpu.register[:A] = 0x00
          @cpu.ram[(0x20 << 8) | 0x02] = 0x04
          @cpu.runop(@op, 0x31)
          assert_equal 1, @cpu.flag[:N]
        end

        should "clear the negative flag if bit 7 in the result is not set" do
          @cpu.register[:A] = 0x80
          @cpu.runop(@op, 0x31)
          assert_equal 0, @cpu.flag[:N]
        end
      end

      should "wrap too-large addresses around so they fit on the zero page" do
        @cpu.register[:A] = 0x50
        @cpu.register[:X] = 0x04
        @cpu.ram[0x00] = 0x0A
        @cpu.ram[0xFF] = 0x02
        @cpu.ram[0xFF + 1] = 0x10
        @cpu.ram[((0x10 << 8) | 0x02)] = 0xB0
        @cpu.ram[((0x0A << 8) | 0x02)] = 0x10
        @cpu.runop(@op, 0xFB)
        assert_equal 0x50 - 0x10 - 1, @cpu.register[:A]
      end
    end

    context "indirecty mode" do
      setup do
        @op = 0xF1
        @cpu.register[:Y] = 0x04
        @cpu.ram[0x35] = 0x02
        @cpu.ram[0x36] = 0x20
        @cpu.ram[0x2006] = 0x69
      end

      should_increase_pc_by 2
      should_increase_cycles_with_boundary_check_by 5

      context "with decimal mode on" do
        setup do
          @cpu.flag[:D] = 1
        end

        should "subtract the correct value from the accumulator, subtracting an additional one if the carry flag is clear, storing the result in the accumulator, using BCD mode" do
          @cpu.register[:A] = 0x85
          @cpu.runop(@op, 0x35)
          assert_equal 0x15, @cpu.register[:A]
        end

        should "set the carry flag if no borrow was required" do
          @cpu.register[:A] = 0x01
          @cpu.runop(@op, 0xFF)
          assert_equal 1, @cpu.flag[:C]
        end

        should "clear the carry flag if borrow was required" do
          @cpu.register[:A] = 0x40
          @cpu.runop(@op, 0x35)
          assert_equal 0, @cpu.flag[:C]
        end

        # zero flag in decimal mode is undefined on 6502
        should "set the zero flag if the result is 0" do
          @cpu.register[:A] = 0x01
          @cpu.ram[0x2006] = 0x00
          @cpu.runop(@op, 0x35)
          assert_equal 1, @cpu.flag[:Z]
        end

        should "clear the zero flag if the result is not zero" do
          @cpu.register[:A] = 0x08
          @cpu.runop(@op, 0x35)
          assert_equal 0, @cpu.flag[:Z]
        end

        # negative flag in decimal mode is undefined on 6502
        should "set the negative flag if bit 7 in the result is set" do
          @cpu.register[:A] = 0x44
          @cpu.runop(@op, 0x35)
          assert_equal 1, @cpu.flag[:N]
        end

        should "clear the negative flag if bit 7 in the result is not set" do
          @cpu.register[:A] = 0x80
          @cpu.runop(@op, 0x31)
          assert_equal 0, @cpu.flag[:N]
        end
      end

      context "with decimal mode off" do
        should "subtract the correct value from the accumulator, subtracting an additional one if the carry flag is clear, storing the result in the accululator" do
          @cpu.register[:A] = 0x90
          @cpu.runop(@op, 0x35)
          assert_equal 0x90 - 0x69 - 1, @cpu.register[:A]
        end

        should "set the zero flag if the result is 0" do
          @cpu.register[:A] = 0x01
          @cpu.ram[0x2006] = 0x00
          @cpu.runop(@op, 0x35)
          assert_equal 1, @cpu.flag[:Z]
        end

        should "clear the zero flag if the result is not zero" do
          @cpu.register[:A] = 0x08
          @cpu.runop(@op, 0x35)
          assert_equal 0, @cpu.flag[:Z]
        end

        should "set the carry flag if no borrow was required" do
          @cpu.register[:A] = 0x90
          @cpu.runop(@op, 0x35)
          assert_equal 1, @cpu.flag[:C]
        end

        should "clear the carry flag if borrow was required" do
          @cpu.register[:A] = 0x40
          @cpu.runop(@op, 0x35)
          assert_equal 0, @cpu.flag[:C]
        end

        should "set the overflow flag if the sign of the result is wrong" do
          @cpu.register[:A] = 0x07
          @cpu.ram[0x2006] = 0x7A
          @cpu.runop(@op, 0x35)
          assert_equal 1, @cpu.flag[:V]
        end

        should "clear the overflow flag if the sign of the result is ok" do
          @cpu.register[:A] = 0x80
          @cpu.runop(@op, 0x35)
          assert_equal 0, @cpu.flag[:V]
        end

        should "set the negative flag if bit 7 in the result is set" do
          @cpu.register[:A] = 0x10
          @cpu.runop(@op, 0x35)
          assert_equal 1, @cpu.flag[:N]
        end

        should "clear the negative flag if bit 7 in the result is not set" do
          @cpu.register[:A] = 0x85
          @cpu.runop(@op, 0x35)
          assert_equal 0, @cpu.flag[:N]
        end
      end

      should "wrap too-large addresses around so they fit on the zero page" do
        @cpu.register[:A] = 0x80
        @cpu.register[:Y] = 0x04
        @cpu.ram[0x00] = 0x0A # correct msb
        @cpu.ram[0xFF] = 0x02 # lsb
        @cpu.ram[0xFF + 1] = 0x10 # WRONG msb
        @cpu.ram[0x0A06] = 0x69
        @cpu.runop(@op, 0xFF)
        assert_equal 0x80 - 0x69 - 1, @cpu.register[:A]
      end
    end
  end
end