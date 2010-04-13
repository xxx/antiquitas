require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502LdaTest < Test::Unit::TestCase
  context "LDA" do
    setup do
      @cpu = Cpu6502.new
    end

    context "immediate mode" do
      should "load the accumulator with arg" do
        @cpu.runop(0xA9, 0x69)
        assert_equal 0x69, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator is zero" do
        @cpu.runop(0xA9, 0x00)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator is not zero" do
        @cpu.runop(0xA9, 0x04)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the accumulator is set" do
        @cpu.runop(0xA9, 0xFF)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the accumulator is not set" do
        @cpu.runop(0xA9, 0x01)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for the op" do
        pc = @cpu.pc
        @cpu.runop(0xA9, 0x01)
        assert_equal pc + 2, @cpu.pc
      end
    end

    context "zeropage mode" do
      should "load the accumulator with the correct value" do
        @cpu.ram[0x12] = 0x69
        @cpu.runop(0xA5, 0x12)
        assert_equal 0x69, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator is zero" do
        @cpu.ram[0x12] = 0x00
        @cpu.runop(0xA5, 0x12)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator is not zero" do
        @cpu.ram[0x12] = 0x04
        @cpu.runop(0xA5, 0x12)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the accumulator is set" do
        @cpu.ram[0x12] = 0xFF
        @cpu.runop(0xA5, 0x12)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the accumulator is not set" do
        @cpu.ram[0x12] = 0x01
        @cpu.runop(0xA5, 0x12)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for the op" do
        pc = @cpu.pc
        @cpu.runop(0xA5, 0x01)
        assert_equal pc + 2, @cpu.pc
      end
    end

    context "zeropagex mode" do
      setup do
        @cpu.register[:X] = 0x04
      end

      should "load the accumulator with the correct value" do
        @cpu.ram[0x12] = 0x69
        @cpu.runop(0xB5, 0x0E)
        assert_equal 0x69, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator is zero" do
        @cpu.ram[0x12] = 0x00
        @cpu.runop(0xB5, 0x0E)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator is not zero" do
        @cpu.ram[0x12] = 0x04
        @cpu.runop(0xB5, 0x0E)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the accumulator is set" do
        @cpu.ram[0x12] = 0xFF
        @cpu.runop(0xB5, 0x0E)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the accumulator is not set" do
        @cpu.ram[0x12] = 0x01
        @cpu.runop(0xB5, 0x0E)
        assert_equal 0, @cpu.flag[:S]
      end

      should "correct addresses to remain on the zero page" do
        @cpu.ram[0x12] = 0x01
        @cpu.register[:X] = 0xFF
        @cpu.runop(0xB5, 0x12)
        assert_equal 0x01, @cpu.register[:A]
      end

      should "increase the pc by the number of bytes for the op" do
        pc = @cpu.pc
        @cpu.runop(0xB5, 0x01)
        assert_equal pc + 2, @cpu.pc
      end
    end

    context "absolute mode" do
      should "load the accumulator with the correct value" do
        @cpu.ram[0x128E] = 0x69
        @cpu.runop(0xAD, 0x12, 0x8E)
        assert_equal 0x69, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator is zero" do
        @cpu.ram[0x128E] = 0x00
        @cpu.runop(0xAD, 0x12, 0x8E)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator is not zero" do
        @cpu.ram[0x128E] = 0x04
        @cpu.runop(0xAD, 0x12, 0x8E)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the accumulator is set" do
        @cpu.ram[0x128E] = 0xFF
        @cpu.runop(0xAD, 0x12, 0x8E)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the accumulator is not set" do
        @cpu.ram[0x128E] = 0x01
        @cpu.runop(0xAD, 0x12, 0x8E)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for the op" do
        pc = @cpu.pc
        @cpu.runop(0xAD, 0x01, 0x4D)
        assert_equal pc + 3, @cpu.pc
      end
    end

    context "absolutex mode" do
      setup do
        @cpu.register[:X] = 0x04
      end

      should "load the accumulator with the correct value" do
        @cpu.ram[0x128E] = 0x69
        @cpu.runop(0xBD, 0x12, 0x8A)
        assert_equal 0x69, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator is zero" do
        @cpu.ram[0x128E] = 0x00
        @cpu.runop(0xBD, 0x12, 0x8A)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator is not zero" do
        @cpu.ram[0x128E] = 0x04
        @cpu.runop(0xBD, 0x12, 0x8A)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the accumulator is set" do
        @cpu.ram[0x128E] = 0xFF
        @cpu.runop(0xBD, 0x12, 0x8A)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the accumulator is not set" do
        @cpu.ram[0x128E] = 0x01
        @cpu.runop(0xBD, 0x12, 0x8A)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for the op" do
        pc = @cpu.pc
        @cpu.runop(0xBD, 0x01, 0x4D)
        assert_equal pc + 3, @cpu.pc
      end
    end

    context "absolutey mode" do
      setup do
        @cpu.register[:Y] = 0x04
      end

      should "load the accumulator with the correct value" do
        @cpu.ram[0x128E] = 0x69
        @cpu.runop(0xB9, 0x12, 0x8A)
        assert_equal 0x69, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator is zero" do
        @cpu.ram[0x128E] = 0x00
        @cpu.runop(0xB9, 0x12, 0x8A)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator is not zero" do
        @cpu.ram[0x128E] = 0x04
        @cpu.runop(0xB9, 0x12, 0x8A)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the accumulator is set" do
        @cpu.ram[0x128E] = 0xFF
        @cpu.runop(0xB9, 0x12, 0x8A)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the accumulator is not set" do
        @cpu.ram[0x128E] = 0x01
        @cpu.runop(0xB9, 0x12, 0x8A)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for the op" do
        pc = @cpu.pc
        @cpu.runop(0xB9, 0x01, 0x4D)
        assert_equal pc + 3, @cpu.pc
      end
    end

    context "indirectx mode" do
      setup do
        @cpu.register[:X] = 0x04
        @cpu.ram[0x16] = 0x24
        @cpu.ram[0x17] = 0x51
      end
      
      should "load the accumulator with the correct value" do
        @cpu.ram[0x5124] = 0x69
        @cpu.runop(0xA1, 0x12)
        assert_equal 0x69, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator is zero" do
        @cpu.ram[0x5124] = 0x00
        @cpu.runop(0xA1, 0x12)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator is not zero" do
        @cpu.ram[0x5124] = 0x04
        @cpu.runop(0xA1, 0x12)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the accumulator is set" do
        @cpu.ram[0x5124] = 0xFF
        @cpu.runop(0xA1, 0x12)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the accumulator is not set" do
        @cpu.ram[0x5124] = 0x01
        @cpu.runop(0xA1, 0x12)
        assert_equal 0, @cpu.flag[:S]
      end

      should "correct the address so it remains on the zero page" do
        @cpu.ram[0x5124] = 0x69
        @cpu.runop(0xA1, 0x12)
        assert_equal 0x69, @cpu.register[:A]
      end

      should "increase the pc by the number of bytes for the op" do
        pc = @cpu.pc
        @cpu.runop(0xA1, 0x01)
        assert_equal pc + 2, @cpu.pc
      end
    end

  end
end