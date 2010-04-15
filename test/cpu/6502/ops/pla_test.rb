require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502PlaTest < Test::Unit::TestCase
  context "PLA" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0x68
      end

      should_increase_pc_by 1

      should "pull a value from the stack and load it into the accumulator" do
        @cpu.push(0x77)
        @cpu.runop(@op)
        assert_equal 0x77, @cpu.register[:A]
      end

      should "set the zero flag if the result is 0" do
        @cpu.push(0x00)
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the result is not 0" do
        @cpu.push(0x01)
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if bit 7 of the result is set" do
        @cpu.push(0x80)
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if bit 7 of the result is not set" do
        @cpu.push(0x08)
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:S]
      end
    end
  end
end