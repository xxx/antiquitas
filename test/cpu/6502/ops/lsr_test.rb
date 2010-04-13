require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502LsrTest < Test::Unit::TestCase
  context "LSR" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "accumulator mode" do
      should "shift the accumulator 1 bit right, setting bit 7 to 0 and the carry flag to what was in bit 0" do
        @cpu.register[:A] = 0x41
        @cpu.runop(0x4A)
        assert_equal 0x20, @cpu.register[:A]
        assert_equal 0, @cpu.register[:A] & 0x80
        assert_equal 1, @cpu.flag[:C]
      end

      should "set the zero flag if the result is zero" do
        @cpu.register[:A] = 0x01
        @cpu.runop(0x4A)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the result is not zero" do
        @cpu.register[:A] = 0x10
        @cpu.runop(0x4A)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0x4A)
        assert_equal pc + 1, @cpu.pc
      end
    end

    context "zeropage mode" do
      should "shift the value at the correct location 1 bit right, setting bit 7 to 0 and the carry flag to what was in bit 0" do
        @cpu.ram[0x22] = 0x41
        @cpu.runop(0x46, 0x22)
        assert_equal 0x20, @cpu.ram[0x22]
        assert_equal 0, @cpu.ram[0x22] & 0x80
        assert_equal 1, @cpu.flag[:C]
      end

      should "set the zero flag if the result is zero" do
        @cpu.ram[0x22] = 0x01
        @cpu.runop(0x46, 0x22)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the result is not zero" do
        @cpu.ram[0x22] = 0x10
        @cpu.runop(0x46, 0x22)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0x46, 0x22)
        assert_equal pc + 2, @cpu.pc
      end
    end

    context "zeropagex mode" do
      setup do
        @cpu.register[:X] = 0x04
      end

      should "shift the value at the correct location 1 bit right, setting bit 7 to 0 and the carry flag to what was in bit 0" do
        @cpu.ram[0x22] = 0x41
        @cpu.runop(0x56, 0x1E)
        assert_equal 0x20, @cpu.ram[0x22]
        assert_equal 0, @cpu.ram[0x22] & 0x80
        assert_equal 1, @cpu.flag[:C]
      end

      should "set the zero flag if the result is zero" do
        @cpu.ram[0x22] = 0x01
        @cpu.runop(0x56, 0x1E)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the result is not zero" do
        @cpu.ram[0x22] = 0x10
        @cpu.runop(0x56, 0x1E)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "wrap the address around to remain on the zero page" do
        @cpu.ram[0x22] = 0x41
        @cpu.register[:X] = 0xFE
        @cpu.runop(0x56, 0x23)
        assert_equal 0x20, @cpu.ram[0x22]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0x56, 0x1F)
        assert_equal pc + 2, @cpu.pc
      end
    end

    context "absolute mode" do
      should "shift the value at the correct location 1 bit right, setting bit 7 to 0 and the carry flag to what was in bit 0" do
        @cpu.ram[0x225E] = 0x41
        @cpu.runop(0x4E, 0x22, 0x5E)
        assert_equal 0x20, @cpu.ram[0x225E]
        assert_equal 0, @cpu.ram[0x225E] & 0x80
        assert_equal 1, @cpu.flag[:C]
      end

      should "set the zero flag if the result is zero" do
        @cpu.ram[0x225E] = 0x01
        @cpu.runop(0x4E, 0x22, 0x5E)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the result is not zero" do
        @cpu.ram[0x225E] = 0x10
        @cpu.runop(0x4E, 0x22, 0x5E)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0x4E, 0x22, 0x5E)
        assert_equal pc + 3, @cpu.pc
      end
    end

    context "absolutex mode" do
      setup do
        @cpu.register[:X] = 0x04
      end

      should "shift the value at the correct location 1 bit right, setting bit 7 to 0 and the carry flag to what was in bit 0" do
        @cpu.ram[0x225E] = 0x41
        @cpu.runop(0x5E, 0x22, 0x5A)
        assert_equal 0x20, @cpu.ram[0x225E]
        assert_equal 0, @cpu.ram[0x225E] & 0x80
        assert_equal 1, @cpu.flag[:C]
      end

      should "set the zero flag if the result is zero" do
        @cpu.ram[0x225E] = 0x01
        @cpu.runop(0x5E, 0x22, 0x5A)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the result is not zero" do
        @cpu.ram[0x225E] = 0x10
        @cpu.runop(0x5E, 0x22, 0x5A)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0x5E, 0x22, 0x5A)
        assert_equal pc + 3, @cpu.pc
      end
    end

  end
end