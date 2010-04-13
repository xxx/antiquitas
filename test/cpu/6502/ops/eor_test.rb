require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502EorTest < Test::Unit::TestCase
  context "EOR" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "immediate mode" do
      setup do
        @cpu.register[:A] = 0x80
      end

      should "exclusive OR the contents of the accumulator with the correct value based on addressing mode, storing the results in the accumulator" do
        @cpu.runop(0x49, 0x83)
        assert_equal 0x03, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator ends up as zero" do
        @cpu.runop(0x49, 0x80)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator does not end up as zero" do
        @cpu.runop(0x49, 0x87)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result is set" do
        @cpu.runop(0x49, 0x04)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the result is not set" do
        @cpu.runop(0x49, 0x81)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0x49, 0x07)
        assert_equal pc + 2, @cpu.pc
      end
    end

    context "zeropage mode" do
      setup do
        @cpu.register[:A] = 0x80
      end

      should "exclusive OR the contents of the accumulator with the correct value based on addressing mode, storing the results in the accumulator" do
        @cpu.ram[0x50] = 0x83
        @cpu.runop(0x45, 0x50)
        assert_equal 0x03, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator ends up as zero" do
        @cpu.ram[0x50] = 0x80
        @cpu.runop(0x45, 0x50)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator does not end up as zero" do
        @cpu.ram[0x50] = 0x87
        @cpu.runop(0x45, 0x50)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result is set" do
        @cpu.ram[0x50] = 0x04
        @cpu.runop(0x45, 0x50)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the result is not set" do
        @cpu.ram[0x50] = 0x81
        @cpu.runop(0x45, 0x50)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0x45, 0x50)
        assert_equal pc + 2, @cpu.pc
      end
    end
    
    context "zeropagex mode" do
      setup do
        @cpu.register[:A] = 0x80
        @cpu.register[:X] = 0x04
      end

      should "exclusive OR the contents of the accumulator with the correct value based on addressing mode, storing the results in the accumulator" do
        @cpu.ram[0x50] = 0x83
        @cpu.runop(0x55, 0x4C)
        assert_equal 0x03, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator ends up as zero" do
        @cpu.ram[0x50] = 0x80
        @cpu.runop(0x55, 0x4C)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator does not end up as zero" do
        @cpu.ram[0x50] = 0x87
        @cpu.runop(0x55, 0x4C)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result is set" do
        @cpu.ram[0x50] = 0x04
        @cpu.runop(0x55, 0x4C)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the result is not set" do
        @cpu.ram[0x50] = 0x81
        @cpu.runop(0x55, 0x4C)
        assert_equal 0, @cpu.flag[:S]
      end

      should "wrap addresses around so the result is still on the zero page" do
        @cpu.ram[0x50] = 0x83
        @cpu.register[:X] = 0xFF
        @cpu.runop(0x55, 0x50)
        assert_equal 0x03, @cpu.register[:A]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0x55, 0x4C)
        assert_equal pc + 2, @cpu.pc
      end
    end

    context "absolute mode" do
      setup do
        @cpu.register[:A] = 0x80
      end

      should "exclusive OR the contents of the accumulator with the correct value based on addressing mode, storing the results in the accumulator" do
        @cpu.ram[0x5150] = 0x83
        @cpu.runop(0x4D, 0x51, 0x50)
        assert_equal 0x03, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator ends up as zero" do
        @cpu.ram[0x5150] = 0x80
        @cpu.runop(0x4D, 0x51, 0x50)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator does not end up as zero" do
        @cpu.ram[0x5150] = 0x87
        @cpu.runop(0x4D, 0x51, 0x50)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result is set" do
        @cpu.ram[0x5150] = 0x04
        @cpu.runop(0x4D, 0x51, 0x50)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the result is not set" do
        @cpu.ram[0x5150] = 0x81
        @cpu.runop(0x4D, 0x51, 0x50)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0x4D, 0x51, 0x50)
        assert_equal pc + 3, @cpu.pc
      end
    end

    context "absolutex mode" do
      setup do
        @cpu.register[:A] = 0x80
        @cpu.register[:X] = 0x04
      end

      should "exclusive OR the contents of the accumulator with the correct value based on addressing mode, storing the results in the accumulator" do
        @cpu.ram[0x5150] = 0x83
        @cpu.runop(0x5D, 0x51, 0x4C)
        assert_equal 0x03, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator ends up as zero" do
        @cpu.ram[0x5150] = 0x80
        @cpu.runop(0x5D, 0x51, 0x4C)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator does not end up as zero" do
        @cpu.ram[0x5150] = 0x87
        @cpu.runop(0x5D, 0x51, 0x4C)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result is set" do
        @cpu.ram[0x5150] = 0x04
        @cpu.runop(0x5D, 0x51, 0x4C)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the result is not set" do
        @cpu.ram[0x5150] = 0x81
        @cpu.runop(0x5D, 0x51, 0x4C)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0x5D, 0x51, 0x4C)
        assert_equal pc + 3, @cpu.pc
      end
    end

    context "absolutey mode" do
      setup do
        @cpu.register[:A] = 0x80
        @cpu.register[:Y] = 0x04
      end

      should "exclusive OR the contents of the accumulator with the correct value based on addressing mode, storing the results in the accumulator" do
        @cpu.ram[0x5150] = 0x83
        @cpu.runop(0x59, 0x51, 0x4C)
        assert_equal 0x03, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator ends up as zero" do
        @cpu.ram[0x5150] = 0x80
        @cpu.runop(0x59, 0x51, 0x4C)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator does not end up as zero" do
        @cpu.ram[0x5150] = 0x87
        @cpu.runop(0x59, 0x51, 0x4C)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result is set" do
        @cpu.ram[0x5150] = 0x04
        @cpu.runop(0x59, 0x51, 0x4C)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the result is not set" do
        @cpu.ram[0x5150] = 0x81
        @cpu.runop(0x59, 0x51, 0x4C)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0x59, 0x51, 0x4C)
        assert_equal pc + 3, @cpu.pc
      end
    end

    context "indirectx mode" do
      setup do
        @cpu.register[:A] = 0x80
        @cpu.register[:X] = 0x04
        @cpu.ram[0x20] = 0x50
        @cpu.ram[0x21] = 0x51
      end

      should "exclusive OR the contents of the accumulator with the correct value based on addressing mode, storing the results in the accumulator" do
        @cpu.ram[0x5150] = 0x83
        @cpu.runop(0x41, 0x1C)
        assert_equal 0x03, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator ends up as zero" do
        @cpu.ram[0x5150] = 0x80
        @cpu.runop(0x41, 0x1C)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator does not end up as zero" do
        @cpu.ram[0x5150] = 0x87
        @cpu.runop(0x41, 0x1C)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result is set" do
        @cpu.ram[0x5150] = 0x04
        @cpu.runop(0x41, 0x1C)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the result is not set" do
        @cpu.ram[0x5150] = 0x81
        @cpu.runop(0x41, 0x1C)
        assert_equal 0, @cpu.flag[:S]
      end

      should "wrap the address around so it stays on the zero page" do
        @cpu.register[:X] = 0xFF
        @cpu.ram[0x5150] = 0x83
        @cpu.runop(0x41, 0x20)
        assert_equal 0x03, @cpu.register[:A]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0x41, 0x1C)
        assert_equal pc + 2, @cpu.pc
      end
    end
    
    context "indirecty mode" do
      setup do
        @cpu.register[:A] = 0x80
        @cpu.register[:Y] = 0x04
        @cpu.ram[0x20] = 0x4C
        @cpu.ram[0x21] = 0x51
      end

      should "exclusive OR the contents of the accumulator with the correct value based on addressing mode, storing the results in the accumulator" do
        @cpu.ram[0x5150] = 0x83
        @cpu.runop(0x51, 0x20)
        assert_equal 0x03, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator ends up as zero" do
        @cpu.ram[0x5150] = 0x80
        @cpu.runop(0x51, 0x20)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator does not end up as zero" do
        @cpu.ram[0x5150] = 0x87
        @cpu.runop(0x51, 0x20)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result is set" do
        @cpu.ram[0x5150] = 0x04
        @cpu.runop(0x51, 0x20)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the result is not set" do
        @cpu.ram[0x5150] = 0x81
        @cpu.runop(0x51, 0x20)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0x51, 0x20)
        assert_equal pc + 2, @cpu.pc
      end
    end

  end
end