require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502AslTest < Test::Unit::TestCase
  context "ASL" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "accumulator mode" do
      should "shift the accumulator left 1 bit" do
        @cpu.register[:A] = 0x20
        @cpu.runop(0x0A)
        assert_equal 0x20 << 1, @cpu.register[:A]
      end

      should "set the zero flag if the acc is now zero" do
        @cpu.register[:A] = 0x80
        @cpu.runop(0x0A)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the acc is not zero" do
        @cpu.register[:A] = 0x05
        @cpu.runop(0x0A)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result is set" do
        @cpu.register[:A] = 0x40
        @cpu.runop(0x0A)
        assert_equal 1, @cpu.flag[:S]
      end

      should "not set the sign flag if bit 7 of the result is not set" do
        @cpu.register[:A] = 0x03
        @cpu.runop(0x0A)
        assert_equal 0, @cpu.flag[:S]
      end

      should "set the carry flag to pre-shift bit 7 of the item to get shifted" do
        @cpu.register[:A] = 0x81
        @cpu.runop(0x0A)
        assert_equal 1, @cpu.flag[:C]
      end

      should "increase the pc by the number of bytes this op has" do
        pc = @cpu.pc
        @cpu.runop(0x0A)
        assert_equal pc + 1, @cpu.pc
      end
    end

    context "zeropage mode" do
      should "shift the value at the passed location left 1 bit" do
        @cpu.ram[0x04] = 0x20
        @cpu.runop(0x06, 0x04)
        assert_equal 0x20 << 1, @cpu.ram[0x04]
      end

      should "set the zero flag if the acc is now zero" do
        @cpu.ram[0x04] = 0x80
        @cpu.runop(0x06, 0x04)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the acc is not zero" do
        @cpu.ram[0x04] = 0x05
        @cpu.runop(0x06, 0x04)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result is set" do
        @cpu.ram[0x04] = 0x40
        @cpu.runop(0x06, 0x04)
        assert_equal 1, @cpu.flag[:S]
      end

      should "not set the sign flag if bit 7 of the result is not set" do
        @cpu.ram[0x04] = 0x03
        @cpu.runop(0x06, 0x04)
        assert_equal 0, @cpu.flag[:S]
      end

      should "set the carry flag to pre-shift bit 7 of the item to get shifted" do
        @cpu.ram[0x04] = 0x81
        @cpu.runop(0x06, 0x04)
        assert_equal 1, @cpu.flag[:C]
      end

      should "increase the pc by the number of bytes this op has" do
        pc = @cpu.pc
        @cpu.runop(0x06, 0x04)
        assert_equal pc + 2, @cpu.pc
      end
    end

    context "zeropagex mode" do
      setup do
        @cpu.register[:X] = 0x06
      end
      
      should "shift the value at the passed location + the value in the X register left 1 bit" do
        @cpu.ram[0x0A] = 0x20
        @cpu.runop(0x16, 0x04)
        assert_equal 0x20 << 1, @cpu.ram[0x0A]
      end

      should "set the zero flag if the acc is now zero" do
        @cpu.ram[0x0A] = 0x80
        @cpu.runop(0x16, 0x04)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the acc is not zero" do
        @cpu.ram[0x0A] = 0x05
        @cpu.runop(0x16, 0x04)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result is set" do
        @cpu.ram[0x0A] = 0x40
        @cpu.runop(0x16, 0x04)
        assert_equal 1, @cpu.flag[:S]
      end

      should "not set the sign flag if bit 7 of the result is not set" do
        @cpu.ram[0x0A] = 0x03
        @cpu.runop(0x16, 0x04)
        assert_equal 0, @cpu.flag[:S]
      end

      should "set the carry flag to pre-shift bit 7 of the item to get shifted" do
        @cpu.ram[0x0A] = 0x81
        @cpu.runop(0x16, 0x04)
        assert_equal 1, @cpu.flag[:C]
      end

      should "increase the pc by the number of bytes this op has" do
        pc = @cpu.pc
        @cpu.runop(0x16, 0x04)
        assert_equal pc + 2, @cpu.pc
      end
    end

    context "absolute mode" do
      should "shift the value at the passed location left 1 bit" do
        @cpu.ram[0x23B3] = 0x20
        @cpu.runop(0x0E, 0x23, 0xB3)
        assert_equal 0x20 << 1, @cpu.ram[0x23B3]
      end

      should "set the zero flag if the acc is now zero" do
        @cpu.ram[0x23B3] = 0x80
        @cpu.runop(0x0E, 0x23, 0xB3)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the acc is not zero" do
        @cpu.ram[0x23B3] = 0x05
        @cpu.runop(0x0E, 0x23, 0xB3)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result is set" do
        @cpu.ram[0x23B3] = 0x40
        @cpu.runop(0x0E, 0x23, 0xB3)
        assert_equal 1, @cpu.flag[:S]
      end

      should "not set the sign flag if bit 7 of the result is not set" do
        @cpu.ram[0x23B3] = 0x03
        @cpu.runop(0x0E, 0x23, 0xB3)
        assert_equal 0, @cpu.flag[:S]
      end

      should "set the carry flag to pre-shift bit 7 of the item to get shifted" do
        @cpu.ram[0x23B3] = 0x81
        @cpu.runop(0x0E, 0x23, 0xB3)
        assert_equal 1, @cpu.flag[:C]
      end

      should "increase the pc by the number of bytes this op has" do
        pc = @cpu.pc
        @cpu.runop(0x0E, 0x23, 0xB3)
        assert_equal pc + 3, @cpu.pc
      end
    end

    context "absolutex mode" do
      setup do
        @cpu.register[:X] = 0x04
      end
      
      should "shift the value at the passed location + the value in the X register left 1 bit" do
        @cpu.ram[0x23B3] = 0x20
        @cpu.runop(0x1E, 0x23, 0xAF)
        assert_equal 0x20 << 1, @cpu.ram[0x23B3]
      end

      should "set the zero flag if the acc is now zero" do
        @cpu.ram[0x23B3] = 0x80
        @cpu.runop(0x1E, 0x23, 0xAF)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the acc is not zero" do
        @cpu.ram[0x23B3] = 0x05
        @cpu.runop(0x1E, 0x23, 0xAF)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result is set" do
        @cpu.ram[0x23B3] = 0x40
        @cpu.runop(0x1E, 0x23, 0xAF)
        assert_equal 1, @cpu.flag[:S]
      end

      should "not set the sign flag if bit 7 of the result is not set" do
        @cpu.ram[0x23B3] = 0x03
        @cpu.runop(0x1E, 0x23, 0xAF)
        assert_equal 0, @cpu.flag[:S]
      end

      should "set the carry flag to pre-shift bit 7 of the item to get shifted" do
        @cpu.ram[0x23B3] = 0x81
        @cpu.runop(0x1E, 0x23, 0xAF)
        assert_equal 1, @cpu.flag[:C]
      end

      should "increase the pc by the number of bytes this op has" do
        pc = @cpu.pc
        @cpu.runop(0x1E, 0x23, 0xAF)
        assert_equal pc + 3, @cpu.pc
      end
    end
  end
end