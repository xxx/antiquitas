require File.expand_path('../../../test_helper', File.dirname(__FILE__))

class Cpu6502BmiTest < Test::Unit::TestCase
  context "BMI" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "relative mode" do
      setup do
        @op = 0x30
      end

      should_increase_cycles_with_branch_check_by 2 do
        [:N, 1] # pass the flag to check and its state when we want to branch
      end

      context "negative flag is set" do
        setup do
          @cpu.flag[:N] = 1
        end

        should_branch_correctly
      end

      context "negative flag is clear" do
        setup do
          @cpu.flag[:N] = 0
        end

        should_increase_pc_by 2
      end
    end
  end
end