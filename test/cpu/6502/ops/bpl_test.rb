require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502BplTest < Test::Unit::TestCase
  context "BPL" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "relative mode" do
      setup do
        @op = 0x10
      end

      context "sign flag is set" do
        setup do
          @cpu.flag[:S] = 1
        end

        should_increase_pc_by 2
      end

      context "sign flag is clear" do
        setup do
          @cpu.flag[:S] = 0
        end
        
        should_branch_correctly
      end
    end
  end
end