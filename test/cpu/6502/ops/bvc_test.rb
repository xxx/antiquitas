require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502BvcTest < Test::Unit::TestCase
  context "BVC" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "relative mode" do
      setup do
        @op = 0x50
      end

      context "overflow flag is set" do
        setup do
          @cpu.flag[:V] = 1
        end

        should_increase_pc_by 2
      end

      context "overflow flag is clear" do
        setup do
          @cpu.flag[:V] = 0
        end

        should_branch_correctly
      end
    end
  end
end