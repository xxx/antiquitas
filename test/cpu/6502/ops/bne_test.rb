require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502BneTest < Test::Unit::TestCase
  context "BNE" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "relative mode" do
      setup do
        @op = 0xD0
      end

      context "zero flag is set" do
        setup do
          @cpu.flag[:Z] = 1
        end

        should "increase the pc by the number of bytes for the op" do
          pc = @cpu.pc
          @cpu.runop(@op, 0xA0)
          assert_equal pc + 2, @cpu.pc
        end
      end

      context "zero flag is not set" do
        setup do
          @cpu.flag[:Z] = 0
        end

        should_branch_correctly
      end
    end
  end
end