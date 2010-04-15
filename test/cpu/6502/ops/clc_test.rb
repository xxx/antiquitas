require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502ClcTest < Test::Unit::TestCase
  context "CLC" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0x18
      end

      should_increase_pc_by 1

      should "clear the carry flag" do
        @cpu.flag[:C] = 1
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:C]
      end
    end
  end
end