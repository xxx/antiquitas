require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502AndTest < Test::Unit::TestCase
  context "AND" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "immediate mode" do
      setup do
        @op = 0x29
      end

      should_increase_pc_by 2
      should_increase_cycles_by 2

      should "do a bitwise AND of the accumulator and the passed arg, storing the result in the accumulator" do
        @cpu.register[:A] = 0x69
        @cpu.runop(@op, 0x22)
        assert_equal 0x69 & 0x22, @cpu.register[:A]
      end

      should "set the zero flag if the resulting accumulator is 0" do
        @cpu.register[:A] = 0x69
        @cpu.runop(@op, 0x00)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the resulting accumulator is not 0" do
        @cpu.register[:A] = 0x07
        @cpu.runop(@op, 0x04)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the resulting accumulator is set" do
        @cpu.register[:A] = 0x80
        @cpu.runop(@op, 0x80)
        assert_equal 1, @cpu.flag[:N]
      end

      should "not set the negative flag if bit 7 of the resulting accumulator is set" do
        @cpu.register[:A] = 0x80
        @cpu.runop(@op, 0x7F)
        assert_equal 0, @cpu.flag[:N]
      end
    end

    context "zeropage mode" do
      setup do
        @op = 0x25
      end

      should_increase_pc_by 2
      should_increase_cycles_by 3

      should "do a bitwise AND of the accumulator and the value at the memory location of the passed arg, storing the result in the accumulator" do
        @cpu.register[:A] = 0x69
        @cpu.ram[0x22] = 0x12
        @cpu.runop(@op, 0x22)
        assert_equal 0x69 & 0x12, @cpu.register[:A]
      end

      should "set the zero flag if the resulting accumulator is 0" do
        @cpu.register[:A] = 0x69
        @cpu.ram[0x22] = 0x00
        @cpu.runop(@op, 0x22)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the resulting accumulator is not 0" do
        @cpu.register[:A] = 0x07
        @cpu.ram[0x22] = 0x04
        @cpu.runop(@op, 0x22)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the resulting accumulator is set" do
        @cpu.register[:A] = 0x80
        @cpu.ram[0x22] = 0x80
        @cpu.runop(@op, 0x22)
        assert_equal 1, @cpu.flag[:N]
      end

      should "not set the negative flag if bit 7 of the resulting accumulator is set" do
        @cpu.register[:A] = 0x80
        @cpu.ram[0x22] = 0x7F
        @cpu.runop(@op, 0x22)
        assert_equal 0, @cpu.flag[:N]
      end
    end

    context "zeropagex mode" do
      setup do
        @op = 0x35
        @cpu.register[:X] = 0x04
      end

      should_increase_pc_by 2
      should_increase_cycles_by 4

      should "do a bitwise AND of the accumulator and the value at the memory location of the passed arg, storing the result in the accumulator" do
        @cpu.register[:A] = 0x69
        @cpu.ram[0x22] = 0x12
        @cpu.runop(@op, 0x1E)
        assert_equal 0x69 & 0x12, @cpu.register[:A]
      end

      should "set the zero flag if the resulting accumulator is 0" do
        @cpu.register[:A] = 0x69
        @cpu.ram[0x22] = 0x00
        @cpu.runop(@op, 0x1E)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the resulting accumulator is not 0" do
        @cpu.register[:A] = 0x07
        @cpu.ram[0x22] = 0x04
        @cpu.runop(@op, 0x1E)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the resulting accumulator is set" do
        @cpu.register[:A] = 0x80
        @cpu.ram[0x22] = 0x80
        @cpu.runop(@op, 0x1E)
        assert_equal 1, @cpu.flag[:N]
      end

      should "not set the negative flag if bit 7 of the resulting accumulator is set" do
        @cpu.register[:A] = 0x80
        @cpu.ram[0x22] = 0x7F
        @cpu.runop(@op, 0x1E)
        assert_equal 0, @cpu.flag[:N]
      end

      should "correct any overflow in the resulting address to stay on the zero page" do
        @cpu.register[:A] = 0x10
        @cpu.register[:X] = 0xFF
        @cpu.ram[0xFE] = 0x33
        @cpu.runop(@op, 0xFE)
        assert_equal 0x10 & 0x33, @cpu.register[:A]
      end
    end

    context "absolute mode" do
      setup do
        @op = 0x2D
      end

      should_increase_pc_by 3
      should_increase_cycles_by 4

      should "do a bitwise AND of the accumulator and the value at the memory location of the passed args, storing the result in the accumulator" do
        @cpu.register[:A] = 0x69
        @cpu.ram[0x22FC] = 0x12
        @cpu.runop(@op, 0x22, 0xFC)
        assert_equal 0x69 & 0x12, @cpu.register[:A]
      end

      should "set the zero flag if the resulting accumulator is 0" do
        @cpu.register[:A] = 0x69
        @cpu.ram[0x22FC] = 0x00
        @cpu.runop(@op, 0x22, 0xFC)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the resulting accumulator is not 0" do
        @cpu.register[:A] = 0x07
        @cpu.ram[0x22FC] = 0x04
        @cpu.runop(@op, 0x22, 0xFC)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the resulting accumulator is set" do
        @cpu.register[:A] = 0x80
        @cpu.ram[0x22FC] = 0x80
        @cpu.runop(@op, 0x22, 0xFC)
        assert_equal 1, @cpu.flag[:N]
      end

      should "not set the negative flag if bit 7 of the resulting accumulator is set" do
        @cpu.register[:A] = 0x80
        @cpu.ram[0x22FC] = 0x7F
        @cpu.runop(@op, 0x22, 0xFC)
        assert_equal 0, @cpu.flag[:N]
      end
    end

    context "absolutex mode" do
      setup do
        @op = 0x3D
        @cpu.register[:X] = 0x04
      end

      should_increase_pc_by 3
      should_increase_cycles_with_boundary_check_by 4

      should "add the value in the X register to the value at the memory location specified by the arguments and do a bitwise AND with the accumulator, storing the result in the accumulator" do
        @cpu.register[:A] = 0x69
        @cpu.ram[0x22FC] = 0x12
        @cpu.runop(@op, 0x22, 0xF8)
        assert_equal 0x69 & 0x12, @cpu.register[:A]
      end

      should "set the zero flag if the resulting accumulator is 0" do
        @cpu.register[:A] = 0x69
        @cpu.ram[0x22FC] = 0x00
        @cpu.runop(@op, 0x22, 0xF8)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the resulting accumulator is not 0" do
        @cpu.register[:A] = 0x07
        @cpu.ram[0x22FC] = 0x04
        @cpu.runop(@op, 0x22, 0xF8)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the resulting accumulator is set" do
        @cpu.register[:A] = 0x80
        @cpu.ram[0x22FC] = 0x80
        @cpu.runop(@op, 0x22, 0xF8)
        assert_equal 1, @cpu.flag[:N]
      end

      should "not set the negative flag if bit 7 of the resulting accumulator is set" do
        @cpu.register[:A] = 0x80
        @cpu.ram[0x22FC] = 0x7F
        @cpu.runop(@op, 0x22, 0xF8)
        assert_equal 0, @cpu.flag[:N]
      end
    end

    context "absolutey mode" do
      setup do
        @op = 0x39
        @cpu.register[:Y] = 0x04
      end

      should_increase_pc_by 3
      should_increase_cycles_with_boundary_check_by 4

      should "add the value in the X register to the value at the memory location specified by the arguments and do a bitwise AND with the accumulator, storing the result in the accumulator" do
        @cpu.register[:A] = 0x69
        @cpu.ram[0x22FC] = 0x12
        @cpu.runop(@op, 0x22, 0xF8)
        assert_equal 0x69 & 0x12, @cpu.register[:A]
      end

      should "set the zero flag if the resulting accumulator is 0" do
        @cpu.register[:A] = 0x69
        @cpu.ram[0x22FC] = 0x00
        @cpu.runop(@op, 0x22, 0xF8)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the resulting accumulator is not 0" do
        @cpu.register[:A] = 0x07
        @cpu.ram[0x22FC] = 0x04
        @cpu.runop(@op, 0x22, 0xF8)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the resulting accumulator is set" do
        @cpu.register[:A] = 0x80
        @cpu.ram[0x22FC] = 0x80
        @cpu.runop(@op, 0x22, 0xF8)
        assert_equal 1, @cpu.flag[:N]
      end

      should "not set the negative flag if bit 7 of the resulting accumulator is set" do
        @cpu.register[:A] = 0x80
        @cpu.ram[0x22FC] = 0x7F
        @cpu.runop(@op, 0x22, 0xF8)
        assert_equal 0, @cpu.flag[:N]
      end
    end

    context "indirectx mode" do
      setup do
        @op = 0x21
        @cpu.register[:X] = 0x04
        @cpu.ram[0x1E] = 0x22
        @cpu.ram[0x1F] = 0x45
      end

      should_increase_pc_by 2
      should_increase_cycles_by 6

      should "do a bitwise AND of the accumulator and the correct memory location, storing the result in the accumulator" do
        @cpu.register[:A] = 0x69
        @cpu.ram[0x4522] = 0x12
        @cpu.runop(@op, 0x1A)
        assert_equal 0x69 & 0x12, @cpu.register[:A]
      end

      should "set the zero flag if the resulting accumulator is 0" do
        @cpu.register[:A] = 0x69
        @cpu.ram[0x4522] = 0x00
        @cpu.runop(@op, 0x1A)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the resulting accumulator is not 0" do
        @cpu.register[:A] = 0x07
        @cpu.ram[0x4522] = 0x04
        @cpu.runop(@op, 0x1A)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the resulting accumulator is set" do
        @cpu.register[:A] = 0x80
        @cpu.ram[0x4522] = 0x80
        @cpu.runop(@op, 0x1A)
        assert_equal 1, @cpu.flag[:N]
      end

      should "not set the negative flag if bit 7 of the resulting accumulator is set" do
        @cpu.register[:A] = 0x80
        @cpu.ram[0x4522] = 0x7F
        @cpu.runop(@op, 0x1A)
        assert_equal 0, @cpu.flag[:N]
      end

      should "wrap too-large addresses around so they fit on the zero page" do
        @cpu.register[:A] = 0x1A
        @cpu.register[:X] = 0x04
        @cpu.ram[0x00] = 0x0A
        @cpu.ram[0xFF] = 0x02
        @cpu.ram[0xFF + 1] = 0x10
        @cpu.ram[((0x10 << 8) | 0x02)] = 0xB0
        @cpu.ram[((0x0A << 8) | 0x02)] = 0x69
        @cpu.runop(@op, 0xFB)
        assert_equal 0x1A & 0x69, @cpu.register[:A]
      end
    end

    context "indirecty mode" do
      setup do
        @op = 0x31
        @cpu.register[:Y] = 0x04
        @cpu.ram[0x1E] = 0x22
        @cpu.ram[0x1F] = 0x45
        @cpu.ram[0x4526] = 0x77
      end

      should_increase_pc_by 2
      should_increase_cycles_with_boundary_check_by 5

      should "do a bitwise AND of the accumulator and the correct memory location, storing the result in the accumulator" do
        @cpu.register[:A] = 0x69
        @cpu.runop(@op, 0x1E)
        assert_equal 0x69 & 0x77, @cpu.register[:A]
      end

      should "set the zero flag if the resulting accumulator is 0" do
        @cpu.register[:A] = 0x69
        @cpu.ram[0x4526] = 0x00
        @cpu.runop(@op, 0x1E)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the resulting accumulator is not 0" do
        @cpu.register[:A] = 0x07
        @cpu.ram[0x4526] = 0x04
        @cpu.runop(@op, 0x1E)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the resulting accumulator is set" do
        @cpu.register[:A] = 0x80
        @cpu.ram[0x4526] = 0x80
        @cpu.runop(@op, 0x1E)
        assert_equal 1, @cpu.flag[:N]
      end

      should "not set the negative flag if bit 7 of the resulting accumulator is set" do
        @cpu.register[:A] = 0x80
        @cpu.ram[0x4526] = 0x7F
        @cpu.runop(@op, 0x1E)
        assert_equal 0, @cpu.flag[:N]
      end

      should "wrap too-large addresses around so they fit on the zero page" do
        @cpu.register[:A] = 0x80
        @cpu.register[:Y] = 0x04
        @cpu.ram[0x00] = 0x0A
        @cpu.ram[0xFF] = 0x02
        @cpu.ram[0xFF + 1] = 0x10
        @cpu.ram[((0x10 << 8) | 0x06)] = 0xB0 # WRONG - didn't wrap
        @cpu.ram[((0x0A << 8) | 0x06)] = 0x69 # correct
        @cpu.runop(@op, 0xFF)
        assert_equal 0x80 & 0x69, @cpu.register[:A]
      end
    end

  end
end