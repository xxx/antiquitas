require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502RolTest < Test::Unit::TestCase
  context "ROL" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "accumulator mode" do
      setup do
        @op = 0x2A
      end

      should "shift the accumulator 1 bit to the left, moving bit 7 into the carry, and the carry into bit 0" do
        @cpu.register[:A] = 0x81
        @cpu.flag[:C] = 0
        @cpu.runop(@op)
        assert_equal 0x02, @cpu.register[:A]
        assert_equal 1, @cpu.flag[:C]
      end

      should "set the zero flag if the accumulator is 0" do
        @cpu.register[:A] = 0x80
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator is not zero" do
        @cpu.register[:A] = 0x81
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result is set" do
        @cpu.register[:A] = 0x41
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the result is not set" do
        @cpu.register[:A] = 0x01
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(@op)
        assert_equal pc + 1, @cpu.pc
      end
    end

    context "zeropage mode" do
      setup do
        @op = 0x26
      end

      should "shift the accumulator 1 bit to the left, moving bit 7 into the carry, and the carry into bit 0" do
        @cpu.ram[0x23] = 0x81
        @cpu.flag[:C] = 0
        @cpu.runop(@op, 0x23)
        assert_equal 0x02, @cpu.ram[0x23]
        assert_equal 1, @cpu.flag[:C]
      end

      should "set the zero flag if the accumulator is 0" do
        @cpu.ram[0x23] = 0x80
        @cpu.runop(@op, 0x23)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator is not zero" do
        @cpu.ram[0x23] = 0x81
        @cpu.runop(@op, 0x23)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result is set" do
        @cpu.ram[0x23] = 0x41
        @cpu.runop(@op, 0x23)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the result is not set" do
        @cpu.ram[0x23] = 0x01
        @cpu.runop(@op, 0x23)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(@op, 0x23)
        assert_equal pc + 2, @cpu.pc
      end
    end

    context "zeropagex mode" do
      setup do
        @op = 0x36
        @cpu.register[:X] = 0x04
      end

      should "shift the accumulator 1 bit to the left, moving bit 7 into the carry, and the carry into bit 0" do
        @cpu.ram[0x23] = 0x81
        @cpu.flag[:C] = 0
        @cpu.runop(@op, 0x1F)
        assert_equal 0x02, @cpu.ram[0x23]
        assert_equal 1, @cpu.flag[:C]
      end

      should "set the zero flag if the accumulator is 0" do
        @cpu.ram[0x23] = 0x80
        @cpu.runop(@op, 0x1F)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator is not zero" do
        @cpu.ram[0x23] = 0x81
        @cpu.runop(@op, 0x1F)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result is set" do
        @cpu.ram[0x23] = 0x41
        @cpu.runop(@op, 0x1F)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the result is not set" do
        @cpu.ram[0x23] = 0x01
        @cpu.runop(@op, 0x1F)
        assert_equal 0, @cpu.flag[:S]
      end

      should "correct the address so it stays on the zero page" do
        @cpu.register[:X] = 0xFF
        @cpu.ram[0x23] = 0x81
        @cpu.runop(@op, 0x23)
        assert_equal 0x02, @cpu.ram[0x23]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(@op, 0x1F)
        assert_equal pc + 2, @cpu.pc
      end
    end

    context "absolute mode" do
      setup do
        @op = 0x2E
      end

      should "shift the accumulator 1 bit to the left, moving bit 7 into the carry, and the carry into bit 0" do
        @cpu.ram[0x2344] = 0x81
        @cpu.flag[:C] = 0
        @cpu.runop(@op, 0x23, 0x44)
        assert_equal 0x02, @cpu.ram[0x2344]
        assert_equal 1, @cpu.flag[:C]
      end

      should "set the zero flag if the accumulator is 0" do
        @cpu.ram[0x2344] = 0x80
        @cpu.runop(@op, 0x23, 0x44)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator is not zero" do
        @cpu.ram[0x2344] = 0x81
        @cpu.runop(@op, 0x23, 0x44)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result is set" do
        @cpu.ram[0x2344] = 0x41
        @cpu.runop(@op, 0x23, 0x44)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the result is not set" do
        @cpu.ram[0x2344] = 0x01
        @cpu.runop(@op, 0x23, 0x44)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(@op, 0x23, 0x44)
        assert_equal pc + 3, @cpu.pc
      end
    end

    context "absolutex mode" do
      setup do
        @op = 0x3E
        @cpu.register[:X] = 0x04
      end

      should "shift the accumulator 1 bit to the left, moving bit 7 into the carry, and the carry into bit 0" do
        @cpu.ram[0x2344] = 0x81
        @cpu.flag[:C] = 0
        @cpu.runop(@op, 0x23, 0x40)
        assert_equal 0x02, @cpu.ram[0x2344]
        assert_equal 1, @cpu.flag[:C]
      end

      should "set the zero flag if the accumulator is 0" do
        @cpu.ram[0x2344] = 0x80
        @cpu.runop(@op, 0x23, 0x40)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator is not zero" do
        @cpu.ram[0x2344] = 0x81
        @cpu.runop(@op, 0x23, 0x40)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result is set" do
        @cpu.ram[0x2344] = 0x41
        @cpu.runop(@op, 0x23, 0x40)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the result is not set" do
        @cpu.ram[0x2344] = 0x01
        @cpu.runop(@op, 0x23, 0x40)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(@op, 0x23, 0x40)
        assert_equal pc + 3, @cpu.pc
      end
    end

  end
end