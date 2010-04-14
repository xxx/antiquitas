require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502InxTest < Test::Unit::TestCase
  context "INX" do
    setup do
      @cpu = Cpu6502.new
    end

    context "implied mode" do
      setup do
        @op = 0xE8
      end

      should "increment the X register" do
        @cpu.register = {:X => 8}
        @cpu.runop(@op)
        assert_equal 9, @cpu.register[:X]
      end

      should "set the sign flag of the bit 7 of the X register is set" do
        @cpu.register = {:X => -2}
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag of the bit 7 of the X register is not set" do
        @cpu.register = {:X => -1}
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:S]
      end

      should "set the zero flag if the X register is now 0" do
        @cpu.register = {:X => -1}
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the X register is not 0" do
        @cpu.register = {:X => 0}
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "increase the pc by the number of bytes for the op" do
        pc = @cpu.pc
        @cpu.runop(@op)
        assert_equal pc + 1, @cpu.pc
      end
    end
  end
end