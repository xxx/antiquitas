require File.expand_path('../../../test_helper', File.dirname(__FILE__))

class Cpu6502BvsTest < Test::Unit::TestCase
  context "BVS" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "relative mode" do
      setup do
        @op = 0x70
      end

      should_increase_cycles_with_branch_check_by 2 do
        [:V, 1] # pass the flag to check and its state when we want to branch
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

        should_increase_pc_by 2
      end
    end
  end
end