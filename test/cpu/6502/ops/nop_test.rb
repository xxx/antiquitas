require File.expand_path('../../../test_helper', File.dirname(__FILE__))

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
      should_increase_cycles_by 2
    end
  end
end