require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502InyTest < Test::Unit::TestCase
  context "INY" do
    setup do
      @cpu = Cpu6502.new
    end

    context "implied mode" do
      setup do
        @op = 0xC8
      end

      should_increase_pc_by 1

      should "increment the Y register" do
        @cpu.register[:Y] = 0x08
        @cpu.runop(@op)
        assert_equal 0x09, @cpu.register[:Y]
      end

      should "set the negative flag of the bit 7 of the Y register is set" do
        @cpu.register[:Y] = 0xFE
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag of the bit 7 of the Y register is not set" do
        @cpu.register[:Y] = 0xFF
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:N]
      end

      should "set the zero flag if the Y register is now 0" do
        @cpu.register[:Y] = 0xFF
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the Y register is not 0" do
        @cpu.register[:Y] = 0x00
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:Z]
      end
    end
  end
end