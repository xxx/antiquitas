require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502BvsTest < Test::Unit::TestCase
  context "BVS" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "relative mode" do
      setup do
        @op = 0x70
      end

      context "overflow flag is set" do
        setup do
          @cpu.flag[:V] = 1
        end

        should_branch_correctly
      end

      context "overflow flag is clear" do
        setup do
          @cpu.flag[:V] = 0
        end

        should "increase the pc by the number of bytes for the op" do
          pc = @cpu.pc
          @cpu.runop(@op, 0xA0)
          assert_equal pc + 2, @cpu.pc
        end
      end
    end
  end
end