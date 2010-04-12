require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502BneTest < Test::Unit::TestCase
  context "BNE" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "relative mode" do
      context "zero flag is set" do
        setup do
          @cpu.flag[:Z] = 1
        end

        should "increase the pc by the number of bytes for the op" do
          pc = @cpu.pc
          @cpu.runop(0xD0, 0xA0)
          assert_equal pc + 2, @cpu.pc
        end
      end

      context "zero flag is not set" do
        setup do
          @cpu.flag[:Z] = 0
        end

        should "increase or decrease the pc by the number of bytes for the op" do
          pc = @cpu.pc
          @cpu.runop(0xD0, 0x20)
          assert_equal pc + 0x20 + 2, @cpu.pc

          pc = @cpu.pc
          @cpu.runop(0xD0, 0xE0)
          assert_equal (pc - (~0xE0 & 0x00FF)) + 2, @cpu.pc
        end
      end
    end
  end
end