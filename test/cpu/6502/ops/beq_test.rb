require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502BeqTest < Test::Unit::TestCase
  context "BEQ" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "relative mode" do
      setup do
        @op = 0xF0
      end

      context "zero flag is set" do
        setup do
          @cpu.flag[:Z] = 1
        end

        should_branch_correctly
      end

      context "zero flag is clear" do
        setup do
          @cpu.flag[:Z] = 0
        end

        should_increase_pc_by 2
      end
    end
  end
end