require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502LdyTest < Test::Unit::TestCase
  context "LDY" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "immediate mode" do
      should "load the argument into the Y register" do
        @cpu.runop(0xA0, 0x69)
        assert_equal 0x69, @cpu.register[:Y]
      end

      should "set the zero flag if the Y register is 0" do
        @cpu.runop(0xA0, 0x00)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the Y register is not 0" do
        @cpu.runop(0xA0, 0x01)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the Y register is set" do
        @cpu.runop(0xA0, 0xFF)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the Y register is not set" do
        @cpu.runop(0xA0, 0x00)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0xA0, 0x69)
        assert_equal pc + 2, @cpu.pc
      end
    end

    context "zeropage mode" do
      should "load the correct value into the Y register" do
        @cpu.ram[0x04] = 0x69
        @cpu.runop(0xA4, 0x04)
        assert_equal 0x69, @cpu.register[:Y]
      end

      should "set the zero flag if the Y register is 0" do
        @cpu.ram[0x12] = 0x00
        @cpu.runop(0xA4, 0x12)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the Y register is not 0" do
        @cpu.ram[0x12] = 0x01
        @cpu.runop(0xA4, 0x12)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the Y register is set" do
        @cpu.ram[0x12] = 0xFF
        @cpu.runop(0xA4, 0x12)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the Y register is not set" do
        @cpu.ram[0x12] = 0x00
        @cpu.runop(0xA4, 0x12)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0xA4, 0x69)
        assert_equal pc + 2, @cpu.pc
      end
    end
    
    context "zeropagex mode" do
      setup do
        @cpu.register[:X] = 0x04
      end
      
      should "load the correct value into the Y register" do
        @cpu.ram[0x08] = 0x69
        @cpu.runop(0xB4, 0x04)
        assert_equal 0x69, @cpu.register[:Y]
      end

      should "set the zero flag if the Y register is 0" do
        @cpu.ram[0x16] = 0x00
        @cpu.runop(0xB4, 0x12)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the Y register is not 0" do
        @cpu.ram[0x16] = 0x01
        @cpu.runop(0xB4, 0x12)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the Y register is set" do
        @cpu.ram[0x16] = 0xFF
        @cpu.runop(0xB4, 0x12)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the Y register is not set" do
        @cpu.ram[0x16] = 0x00
        @cpu.runop(0xB4, 0x12)
        assert_equal 0, @cpu.flag[:S]
      end

      should "correct the address so it stays on the zero page" do
        @cpu.register[:X] = 0xFF
        @cpu.ram[0x16] = 0x77
        @cpu.runop(0xB4, 0x16)
        assert_equal @cpu.register[:Y], 0x77
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0xB4, 0x69)
        assert_equal pc + 2, @cpu.pc
      end
    end

    context "absolute mode" do
      should "load the correct value into the Y register" do
        @cpu.ram[0x049F] = 0x69
        @cpu.runop(0xAC, 0x04, 0x9F)
        assert_equal 0x69, @cpu.register[:Y]
      end

      should "set the zero flag if the Y register is 0" do
        @cpu.ram[0x129F] = 0x00
        @cpu.runop(0xAC, 0x12, 0x9F)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the Y register is not 0" do
        @cpu.ram[0x129F] = 0x01
        @cpu.runop(0xAC, 0x12, 0x9F)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the Y register is set" do
        @cpu.ram[0x129F] = 0xFF
        @cpu.runop(0xAC, 0x12, 0x9F)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the Y register is not set" do
        @cpu.ram[0x12, 0x9F] = 0x00
        @cpu.runop(0xAC, 0x12, 0x9F)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0xAC, 0x69, 0x44)
        assert_equal pc + 3, @cpu.pc
      end
    end

    context "absolutex mode" do
      setup do
        @cpu.register[:X] = 0x04
      end

      should "load the correct value into the Y register" do
        @cpu.ram[0x049F] = 0x69
        @cpu.runop(0xBC, 0x04, 0x9B)
        assert_equal 0x69, @cpu.register[:Y]
      end

      should "set the zero flag if the Y register is 0" do
        @cpu.ram[0x129F] = 0x00
        @cpu.runop(0xBC, 0x12, 0x9B)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the Y register is not 0" do
        @cpu.ram[0x129F] = 0x01
        @cpu.runop(0xBC, 0x12, 0x9B)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the Y register is set" do
        @cpu.ram[0x129F] = 0xFF
        @cpu.runop(0xBC, 0x12, 0x9B)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the Y register is not set" do
        @cpu.ram[0x12, 0x9F] = 0x00
        @cpu.runop(0xBC, 0x12, 0x9B)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0xBC, 0x69, 0x44)
        assert_equal pc + 3, @cpu.pc
      end
    end

  end
end