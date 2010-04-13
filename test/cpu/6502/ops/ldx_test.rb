require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502LdxTest < Test::Unit::TestCase
  context "LDX" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "immediate mode" do
      should "load the argument into the X register" do
        @cpu.runop(0xA2, 0x69)
        assert_equal 0x69, @cpu.register[:X]
      end

      should "set the zero flag if the X register is 0" do
        @cpu.runop(0xA2, 0x00)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the X register is not 0" do
        @cpu.runop(0xA2, 0x01)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the X register is set" do
        @cpu.runop(0xA2, 0xFF)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the X register is not set" do
        @cpu.runop(0xA2, 0x00)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0xA2, 0x69)
        assert_equal pc + 2, @cpu.pc
      end
    end

    context "zeropage mode" do
      should "load the correct value into the X register" do
        @cpu.ram[0x04] = 0x69
        @cpu.runop(0xA6, 0x04)
        assert_equal 0x69, @cpu.register[:X]
      end

      should "set the zero flag if the X register is 0" do
        @cpu.ram[0x12] = 0x00
        @cpu.runop(0xA6, 0x12)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the X register is not 0" do
        @cpu.ram[0x12] = 0x01
        @cpu.runop(0xA6, 0x12)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the X register is set" do
        @cpu.ram[0x12] = 0xFF
        @cpu.runop(0xA6, 0x12)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the X register is not set" do
        @cpu.ram[0x12] = 0x00
        @cpu.runop(0xA6, 0x12)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0xA6, 0x69)
        assert_equal pc + 2, @cpu.pc
      end
    end
    
    context "zeropagey mode" do
      setup do
        @cpu.register[:Y] = 0x04
      end
      
      should "load the correct value into the X register" do
        @cpu.ram[0x08] = 0x69
        @cpu.runop(0xB6, 0x04)
        assert_equal 0x69, @cpu.register[:X]
      end

      should "set the zero flag if the X register is 0" do
        @cpu.ram[0x16] = 0x00
        @cpu.runop(0xB6, 0x12)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the X register is not 0" do
        @cpu.ram[0x16] = 0x01
        @cpu.runop(0xB6, 0x12)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the X register is set" do
        @cpu.ram[0x16] = 0xFF
        @cpu.runop(0xB6, 0x12)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the X register is not set" do
        @cpu.ram[0x16] = 0x00
        @cpu.runop(0xB6, 0x12)
        assert_equal 0, @cpu.flag[:S]
      end

      should "correct the address so it stays on the zero page" do
        @cpu.register[:Y] = 0xFF
        @cpu.ram[0x16] = 0x77
        @cpu.runop(0xB6, 0x16)
        assert_equal @cpu.register[:X], 0x77
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0xB6, 0x69)
        assert_equal pc + 2, @cpu.pc
      end
    end

    context "absolute mode" do
      should "load the correct value into the X register" do
        @cpu.ram[0x049F] = 0x69
        @cpu.runop(0xAE, 0x04, 0x9F)
        assert_equal 0x69, @cpu.register[:X]
      end

      should "set the zero flag if the X register is 0" do
        @cpu.ram[0x129F] = 0x00
        @cpu.runop(0xAE, 0x12, 0x9F)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the X register is not 0" do
        @cpu.ram[0x129F] = 0x01
        @cpu.runop(0xAE, 0x12, 0x9F)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the X register is set" do
        @cpu.ram[0x129F] = 0xFF
        @cpu.runop(0xAE, 0x12, 0x9F)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the X register is not set" do
        @cpu.ram[0x12, 0x9F] = 0x00
        @cpu.runop(0xAE, 0x12, 0x9F)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0xAE, 0x69, 0x44)
        assert_equal pc + 3, @cpu.pc
      end
    end

    context "absolutey mode" do
      setup do
        @cpu.register[:Y] = 0x04
      end

      should "load the correct value into the X register" do
        @cpu.ram[0x049F] = 0x69
        @cpu.runop(0xBE, 0x04, 0x9B)
        assert_equal 0x69, @cpu.register[:X]
      end

      should "set the zero flag if the X register is 0" do
        @cpu.ram[0x129F] = 0x00
        @cpu.runop(0xBE, 0x12, 0x9B)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the X register is not 0" do
        @cpu.ram[0x129F] = 0x01
        @cpu.runop(0xBE, 0x12, 0x9B)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the X register is set" do
        @cpu.ram[0x129F] = 0xFF
        @cpu.runop(0xBE, 0x12, 0x9B)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the X register is not set" do
        @cpu.ram[0x12, 0x9F] = 0x00
        @cpu.runop(0xBE, 0x12, 0x9B)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0xBE, 0x69, 0x44)
        assert_equal pc + 3, @cpu.pc
      end
    end

  end
end