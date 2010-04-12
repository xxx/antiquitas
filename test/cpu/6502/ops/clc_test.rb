require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502ClcTest < Test::Unit::TestCase
  context "CLC" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      should "clear the carry flag" do
        @cpu.flag[:C] = 1
        @cpu.runop(0x18)
        assert_equal 0, @cpu.flag[:C]
      end

      should "increase the pc by the number of bytes for this op" do
        pc = @cpu.pc
        @cpu.runop(0x18)
        assert_equal pc + 1, @cpu.pc
      end
    end
  end
end