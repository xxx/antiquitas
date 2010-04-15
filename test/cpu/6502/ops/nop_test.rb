require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502NopTest < Test::Unit::TestCase
  context "NOP" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0xEA
      end

      should_increase_pc_by 1
    end
  end
end