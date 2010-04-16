require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502TxaTest < Test::Unit::TestCase
  context "TXA" do
    setup do
      @cpu = Cpu6502.new
    end

    context "implied mode" do
      setup do
        @op = 0x8A
        @cpu.register[:X] = 0x69
      end

      should_increase_pc_by 1
      should_increase_cycles_by 2

      should "transfer the contents of the X register to the accumulator" do
        @cpu.runop(@op)
        assert_equal 0x69, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator is zero" do
        @cpu.register[:X] = 0x00
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator is not zero" do
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the accumulator is set" do
        @cpu.register[:X] = 0x80
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the accumulator is not set" do
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:N]
      end
    end
  end
end