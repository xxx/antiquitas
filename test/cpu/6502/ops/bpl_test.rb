require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502BplTest < Test::Unit::TestCase
  context "BPL" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "relative mode" do
      context "sign flag is set" do
        setup do
          @cpu.flag[:S] = 1
        end

        should "increase the pc by the number of bytes for the op" do
          pc = @cpu.pc
          @cpu.runop(0x10, 0xA0)
          assert_equal pc + 2, @cpu.pc
        end
      end

      context "sign flag is clear" do
        setup do
          @cpu.flag[:S] = 0
        end
        
        should "increase or decrease the pc by the number of bytes for the op" do
          pc = @cpu.pc
          @cpu.runop(0x10, 0x20)
          assert_equal pc + 0x20 + 2, @cpu.pc

          pc = @cpu.pc
          @cpu.runop(0x10, 0xE0)
          assert_equal (pc - (~0xE0 & 0xFF)) + 2, @cpu.pc
        end
      end
    end
  end
end