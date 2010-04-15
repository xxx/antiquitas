require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502SedTest < Test::Unit::TestCase
  context "SED" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0xF8
      end

      should_increase_pc_by(1)

      should "set the decimal mode flag" do
        @cpu.flag[:D] = 0
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:D]
      end
    end
  end
end