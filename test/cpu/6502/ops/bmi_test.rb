require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502BmiTest < Test::Unit::TestCase
  context "BMI" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "relative mode" do
      setup do
        @op = 0x30
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