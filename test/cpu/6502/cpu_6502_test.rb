require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class Cpu6502Test < Test::Unit::TestCase
#  include RR::Adapters::TestUnit

  def setup
    @cpu = Cpu6502.new
  end

  context "initialization" do
    should "initialize the registers" do
      assert_equal 0, @cpu.register[:A]
      assert_equal 0, @cpu.register[:X]
      assert_equal 0, @cpu.register[:Y]
      assert_equal 0xFF, @cpu.register[:S]
      assert_equal 0, @cpu.register[:P]
    end

    should "zero the flags" do
      assert_equal 0, @cpu.flag[:N]
      assert_equal 0, @cpu.flag[:V]
      assert_equal 0, @cpu.flag[:B]
      assert_equal 0, @cpu.flag[:D]
      assert_equal 0, @cpu.flag[:I]
      assert_equal 0, @cpu.flag[:Z]
      assert_equal 0, @cpu.flag[:C]
    end

    should "initialize the pc" do
      assert_equal 0, @cpu.pc
    end
  end

end
