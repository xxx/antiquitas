require File.expand_path('../../../test_helper', File.dirname(__FILE__))

class Cpu6502EorTest < Test::Unit::TestCase
  context "EOR" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "immediate mode" do
      setup do
        @op = 0x49
        @cpu.register[:A] = 0x80
      end

      should_increase_pc_by 2
      should_increase_cycles_by 2

      should "exclusive OR the contents of the accumulator with the correct value based on addressing mode, storing the results in the accumulator" do
        @cpu.runop(@op, 0x83)
        assert_equal 0x03, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator ends up as zero" do
        @cpu.runop(@op, 0x80)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator does not end up as zero" do
        @cpu.runop(@op, 0x87)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result is set" do
        @cpu.runop(@op, 0x04)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the result is not set" do
        @cpu.runop(@op, 0x81)
        assert_equal 0, @cpu.flag[:N]
      end
    end

    context "zeropage mode" do
      setup do
        @op = 0x45
        @cpu.register[:A] = 0x80
      end

      should_increase_pc_by 2
      should_increase_cycles_by 3

      should "exclusive OR the contents of the accumulator with the correct value based on addressing mode, storing the results in the accumulator" do
        @cpu.ram[0x50] = 0x83
        @cpu.runop(@op, 0x50)
        assert_equal 0x03, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator ends up as zero" do
        @cpu.ram[0x50] = 0x80
        @cpu.runop(@op, 0x50)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator does not end up as zero" do
        @cpu.ram[0x50] = 0x87
        @cpu.runop(@op, 0x50)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result is set" do
        @cpu.ram[0x50] = 0x04
        @cpu.runop(@op, 0x50)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the result is not set" do
        @cpu.ram[0x50] = 0x81
        @cpu.runop(@op, 0x50)
        assert_equal 0, @cpu.flag[:N]
      end
    end
    
    context "zeropagex mode" do
      setup do
        @op = 0x55
        @cpu.register[:A] = 0x80
        @cpu.register[:X] = 0x04
      end

      should_increase_pc_by 2
      should_increase_cycles_by 4

      should "exclusive OR the contents of the accumulator with the correct value based on addressing mode, storing the results in the accumulator" do
        @cpu.ram[0x50] = 0x83
        @cpu.runop(@op, 0x4C)
        assert_equal 0x03, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator ends up as zero" do
        @cpu.ram[0x50] = 0x80
        @cpu.runop(@op, 0x4C)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator does not end up as zero" do
        @cpu.ram[0x50] = 0x87
        @cpu.runop(@op, 0x4C)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result is set" do
        @cpu.ram[0x50] = 0x04
        @cpu.runop(@op, 0x4C)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the result is not set" do
        @cpu.ram[0x50] = 0x81
        @cpu.runop(@op, 0x4C)
        assert_equal 0, @cpu.flag[:N]
      end

      should "wrap addresses around so the result is still on the zero page" do
        @cpu.ram[0x50] = 0x83
        @cpu.register[:X] = 0xFF
        @cpu.runop(@op, 0x50)
        assert_equal 0x03, @cpu.register[:A]
      end
    end

    context "absolute mode" do
      setup do
        @op = 0x4D
        @cpu.register[:A] = 0x80
      end

      should_increase_pc_by 3
      should_increase_cycles_by 4

      should "exclusive OR the contents of the accumulator with the correct value based on addressing mode, storing the results in the accumulator" do
        @cpu.ram[0x5150] = 0x83
        @cpu.runop(@op, 0x51, 0x50)
        assert_equal 0x03, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator ends up as zero" do
        @cpu.ram[0x5150] = 0x80
        @cpu.runop(@op, 0x51, 0x50)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator does not end up as zero" do
        @cpu.ram[0x5150] = 0x87
        @cpu.runop(@op, 0x51, 0x50)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result is set" do
        @cpu.ram[0x5150] = 0x04
        @cpu.runop(@op, 0x51, 0x50)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the result is not set" do
        @cpu.ram[0x5150] = 0x81
        @cpu.runop(@op, 0x51, 0x50)
        assert_equal 0, @cpu.flag[:N]
      end
    end

    context "absolutex mode" do
      setup do
        @op = 0x5D
        @cpu.register[:A] = 0x80
        @cpu.register[:X] = 0x04
      end

      should_increase_pc_by 3
      should_increase_cycles_with_boundary_check_by 4

      should "exclusive OR the contents of the accumulator with the correct value based on addressing mode, storing the results in the accumulator" do
        @cpu.ram[0x5150] = 0x83
        @cpu.runop(@op, 0x51, 0x4C)
        assert_equal 0x03, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator ends up as zero" do
        @cpu.ram[0x5150] = 0x80
        @cpu.runop(@op, 0x51, 0x4C)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator does not end up as zero" do
        @cpu.ram[0x5150] = 0x87
        @cpu.runop(@op, 0x51, 0x4C)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result is set" do
        @cpu.ram[0x5150] = 0x04
        @cpu.runop(@op, 0x51, 0x4C)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the result is not set" do
        @cpu.ram[0x5150] = 0x81
        @cpu.runop(@op, 0x51, 0x4C)
        assert_equal 0, @cpu.flag[:N]
      end
    end

    context "absolutey mode" do
      setup do
        @op = 0x59
        @cpu.register[:A] = 0x80
        @cpu.register[:Y] = 0x04
      end

      should_increase_pc_by 3
      should_increase_cycles_with_boundary_check_by 4

      should "exclusive OR the contents of the accumulator with the correct value based on addressing mode, storing the results in the accumulator" do
        @cpu.ram[0x5150] = 0x83
        @cpu.runop(@op, 0x51, 0x4C)
        assert_equal 0x03, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator ends up as zero" do
        @cpu.ram[0x5150] = 0x80
        @cpu.runop(@op, 0x51, 0x4C)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator does not end up as zero" do
        @cpu.ram[0x5150] = 0x87
        @cpu.runop(@op, 0x51, 0x4C)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result is set" do
        @cpu.ram[0x5150] = 0x04
        @cpu.runop(@op, 0x51, 0x4C)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the result is not set" do
        @cpu.ram[0x5150] = 0x81
        @cpu.runop(@op, 0x51, 0x4C)
        assert_equal 0, @cpu.flag[:N]
      end
    end

    context "indirectx mode" do
      setup do
        @op = 0x41
        @cpu.register[:A] = 0x80
        @cpu.register[:X] = 0x04
        @cpu.ram[0x20] = 0x50
        @cpu.ram[0x21] = 0x51
      end

      should_increase_pc_by 2
      should_increase_cycles_by 6

      should "exclusive OR the contents of the accumulator with the correct value based on addressing mode, storing the results in the accumulator" do
        @cpu.ram[0x5150] = 0x83
        @cpu.runop(@op, 0x1C)
        assert_equal 0x03, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator ends up as zero" do
        @cpu.ram[0x5150] = 0x80
        @cpu.runop(@op, 0x1C)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator does not end up as zero" do
        @cpu.ram[0x5150] = 0x87
        @cpu.runop(@op, 0x1C)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result is set" do
        @cpu.ram[0x5150] = 0x04
        @cpu.runop(@op, 0x1C)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the result is not set" do
        @cpu.ram[0x5150] = 0x81
        @cpu.runop(@op, 0x1C)
        assert_equal 0, @cpu.flag[:N]
      end

      should "wrap the address around so it stays on the zero page" do
        @cpu.ram[0xFF] = 0x40
        @cpu.ram[0x00] = 0x23
        @cpu.ram[0x2340] = 0x83
        @cpu.runop(@op, 0xFB)
        assert_equal 0x03, @cpu.register[:A]
      end
    end
    
    context "indirecty mode" do
      setup do
        @op = 0x51
        @cpu.register[:A] = 0x80
        @cpu.register[:Y] = 0x04
        @cpu.ram[0x20] = 0x4C
        @cpu.ram[0x21] = 0x51
      end

      should_increase_pc_by 2
      should_increase_cycles_with_boundary_check_by 5

      should "exclusive OR the contents of the accumulator with the correct value based on addressing mode, storing the results in the accumulator" do
        @cpu.ram[0x5150] = 0x83
        @cpu.runop(@op, 0x20)
        assert_equal 0x03, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator ends up as zero" do
        @cpu.ram[0x5150] = 0x80
        @cpu.runop(@op, 0x20)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator does not end up as zero" do
        @cpu.ram[0x5150] = 0x87
        @cpu.runop(@op, 0x20)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result is set" do
        @cpu.ram[0x5150] = 0x04
        @cpu.runop(@op, 0x20)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the result is not set" do
        @cpu.ram[0x5150] = 0x81
        @cpu.runop(@op, 0x20)
        assert_equal 0, @cpu.flag[:N]
      end
    end
  end
end