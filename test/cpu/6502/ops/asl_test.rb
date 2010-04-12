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
  end
end