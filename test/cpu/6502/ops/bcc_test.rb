require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502BccTest < Test::Unit::TestCase
  context "BCC" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "relative mode" do
      setup do
        @op = 0x90
      end

      context "carry flag clear" do
        should "increase the pc by the number of bytes in the arg if the arg is > 0 and less than 0x80" do
          @cpu.pc = 0x69
          @cpu.runop(@op, 0x05)
          assert_equal 0x6E + 2, @cpu.pc # + 2 due to pc increment
        end

        should "decrease the pc by the number of bytes (twos complement) in the arg if the arg is >= 0x80 and <= 0xFF" do
          @cpu.pc = 0x6950
          @cpu.runop(@op, 0xF8)
          assert_equal (0x6950 + 2) - (~(0xF8) & 0xff), @cpu.pc
        end
      end

      context "carry flag set" do
        setup do
          @cpu.flag[:C] = 1
        end
        
        should "increase the pc by the number of bytes for this op" do
          pc = @cpu.pc
          @cpu.runop(@op, 0x04)
          assert_equal pc + 2, @cpu.pc
        end
      end
    end
  end
end