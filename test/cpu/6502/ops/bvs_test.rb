require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502BvsTest < Test::Unit::TestCase
  context "BVS" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "relative mode" do
      context "overflow flag is set" do
        setup do
          @cpu.flag[:V] = 1
        end

        should "increase or decrease the pc by the number of bytes for the op" do
          pc = @cpu.pc
          @cpu.runop(0x70, 0x20)
          assert_equal pc + 0x20 + 2, @cpu.pc

          pc = @cpu.pc
          @cpu.runop(0x70, 0xE0)
          assert_equal (pc - (~0xE0 & 0xFF)) + 2, @cpu.pc
        end
      end

      context "overflow flag is clear" do
        setup do
          @cpu.flag[:V] = 0
        end

        should "increase the pc by the number of bytes for the op" do
          pc = @cpu.pc
          @cpu.runop(0x70, 0xA0)
          assert_equal pc + 2, @cpu.pc
        end
      end
    end
  end
end