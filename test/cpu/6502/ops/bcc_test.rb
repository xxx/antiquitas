require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502BccTest < Test::Unit::TestCase
  context "BCC" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "relative mode" do
      context "carry flag clear" do
        should "increase or decrease the pc by the number of bytes passed" do
          @cpu.pc = 0x69
          @cpu.runop(0x90, 0x05)
          assert_equal 0x6E + 2, @cpu.pc # + 2 due to pc imcrement

          @cpu.runop(0x90, 0xF8)
          assert_equal 0x69 + 2, @cpu.pc
        end
      end

      context "carry flag set" do
        setup do
          @cpu.flag[:C] = 1
        end
        
        should "increase the pc by the number of bytes for this op" do
          pc = @cpu.pc
          @cpu.runop(0x90, 0x04)
          assert_equal pc + 2, @cpu.pc
        end
      end
    end
  end
end