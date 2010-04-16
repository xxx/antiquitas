require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502BcsTest < Test::Unit::TestCase
  context "BCS" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "relative mode" do
      setup do
        @op = 0xB0
      end
      
      should_increase_cycles_with_branch_check_by 2 do
        [:C, 1] # pass the flag to check and its state when we want to branch
      end

      context "carry flag set" do
        setup do
          @cpu.flag[:C] = 1
        end

        should_branch_correctly
      end

      context "carry flag clear" do
        should_increase_pc_by 2
      end
    end
  end
end