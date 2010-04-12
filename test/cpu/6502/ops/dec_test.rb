require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502DecTest < Test::Unit::TestCase
  context "DEC" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "zeropage mode" do
      setup do
        @cpu.ram[0x12] = 0x69
      end
      
      should "decrement the value at the correct address by 1" do
        @cpu.runop(0xC6, 0x12)
        assert_equal 0x68, @cpu.ram[0x12]
      end

      should "set the zero flag if the result is 0" do
        @cpu.ram[0x12] = 0x01
        @cpu.runop(0xC6, 0x12)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the result is not 0" do
        @cpu.runop(0xC6, 0x12)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result is set" do
        @cpu.ram[0x12] = 0x81
        @cpu.runop(0xC6, 0x12)
        assert_equal 1, @cpu.flag[:S]
      end

      should "not set the sign flag if bit 7 of the result is not set" do
        @cpu.runop(0xC6, 0x12)
        assert_equal 0, @cpu.flag[:S]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0xC6, 0x12)
        assert_equal pc + 2, @cpu.pc
      end
    end

    context "zeropagex mode" do
      setup do
        @cpu.ram[0x16] = 0x69
        @cpu.register[:X] = 0x04
      end

      should "decrement the value at the correct address by 1" do
        @cpu.runop(0xD6, 0x12)
        assert_equal 0x68, @cpu.ram[0x16]
      end

      should "set the zero flag if the result is 0" do
        @cpu.ram[0x16] = 0x01
        @cpu.runop(0xD6, 0x12)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the result is not 0" do
        @cpu.runop(0xD6, 0x12)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result is set" do
        @cpu.ram[0x16] = 0x81
        @cpu.runop(0xD6, 0x12)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the result is not set" do
        @cpu.runop(0xD6, 0x12)
        assert_equal 0, @cpu.flag[:S]
      end

      should "correct the calculated address to stay on the zero page" do
        @cpu.register[:X] = 0xFF
        @cpu.runop(0xD6, 0x16)
        assert_equal 0x68, @cpu.ram[0x16]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0xD6, 0x12)
        assert_equal pc + 2, @cpu.pc
      end
    end
  end
end