require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502LsrTest < Test::Unit::TestCase
  context "LSR" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "accumulator mode" do
      setup do
        @op = 0x4A
      end

      should_increase_pc_by 1

      should "shift the accumulator 1 bit right, setting bit 7 to 0 and the carry flag to what was in bit 0" do
        @cpu.register[:A] = 0x41
        @cpu.runop(@op)
        assert_equal 0x20, @cpu.register[:A]
        assert_equal 0, @cpu.register[:A] & 0x80
        assert_equal 1, @cpu.flag[:C]
      end

      should "set the zero flag if the result is zero" do
        @cpu.register[:A] = 0x01
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the result is not zero" do
        @cpu.register[:A] = 0x10
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:Z]
      end
    end

    context "zeropage mode" do
      setup do
        @op = 0x46
      end

      should_increase_pc_by 2

      should "shift the value at the correct location 1 bit right, setting bit 7 to 0 and the carry flag to what was in bit 0" do
        @cpu.ram[0x22] = 0x41
        @cpu.runop(@op, 0x22)
        assert_equal 0x20, @cpu.ram[0x22]
        assert_equal 0, @cpu.ram[0x22] & 0x80
        assert_equal 1, @cpu.flag[:C]
      end

      should "set the zero flag if the result is zero" do
        @cpu.ram[0x22] = 0x01
        @cpu.runop(@op, 0x22)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the result is not zero" do
        @cpu.ram[0x22] = 0x10
        @cpu.runop(@op, 0x22)
        assert_equal 0, @cpu.flag[:Z]
      end
    end

    context "zeropagex mode" do
      setup do
        @op = 0x56
        @cpu.register[:X] = 0x04
      end

      should_increase_pc_by 2

      should "shift the value at the correct location 1 bit right, setting bit 7 to 0 and the carry flag to what was in bit 0" do
        @cpu.ram[0x22] = 0x41
        @cpu.runop(@op, 0x1E)
        assert_equal 0x20, @cpu.ram[0x22]
        assert_equal 0, @cpu.ram[0x22] & 0x80
        assert_equal 1, @cpu.flag[:C]
      end

      should "set the zero flag if the result is zero" do
        @cpu.ram[0x22] = 0x01
        @cpu.runop(@op, 0x1E)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the result is not zero" do
        @cpu.ram[0x22] = 0x10
        @cpu.runop(@op, 0x1E)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "wrap the address around to remain on the zero page" do
        @cpu.ram[0x22] = 0x41
        @cpu.register[:X] = 0xFE
        @cpu.runop(@op, 0x23)
        assert_equal 0x20, @cpu.ram[0x22]
      end
    end

    context "absolute mode" do
      setup do
        @op = 0x4E
      end

      should_increase_pc_by 3

      should "shift the value at the correct location 1 bit right, setting bit 7 to 0 and the carry flag to what was in bit 0" do
        @cpu.ram[0x225E] = 0x41
        @cpu.runop(@op, 0x22, 0x5E)
        assert_equal 0x20, @cpu.ram[0x225E]
        assert_equal 0, @cpu.ram[0x225E] & 0x80
        assert_equal 1, @cpu.flag[:C]
      end

      should "set the zero flag if the result is zero" do
        @cpu.ram[0x225E] = 0x01
        @cpu.runop(@op, 0x22, 0x5E)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the result is not zero" do
        @cpu.ram[0x225E] = 0x10
        @cpu.runop(@op, 0x22, 0x5E)
        assert_equal 0, @cpu.flag[:Z]
      end
    end

    context "absolutex mode" do
      setup do
        @op = 0x5E
        @cpu.register[:X] = 0x04
      end

      should_increase_pc_by 3

      should "shift the value at the correct location 1 bit right, setting bit 7 to 0 and the carry flag to what was in bit 0" do
        @cpu.ram[0x225E] = 0x41
        @cpu.runop(@op, 0x22, 0x5A)
        assert_equal 0x20, @cpu.ram[0x225E]
        assert_equal 0, @cpu.ram[0x225E] & 0x80
        assert_equal 1, @cpu.flag[:C]
      end

      should "set the zero flag if the result is zero" do
        @cpu.ram[0x225E] = 0x01
        @cpu.runop(@op, 0x22, 0x5A)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the result is not zero" do
        @cpu.ram[0x225E] = 0x10
        @cpu.runop(@op, 0x22, 0x5A)
        assert_equal 0, @cpu.flag[:Z]
      end
    end
  end
end