require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502CTsxTest < Test::Unit::TestCase
  context "TSX" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0xBA
      end

      should_increase_pc_by 1

      should "transfer the value in the stack pointer to the X register" do
        @cpu.register[:SP] = 0x69
        @cpu.runop(@op)
        assert_equal 0x69, @cpu.register[:X]
      end

      should "not change the value of the stack pointer" do
        @cpu.register[:SP] = 0x40
        sp = @cpu.register[:SP]
        @cpu.runop(@op)
        assert_equal sp, @cpu.register[:SP]
      end

      should "set the zero flag if the transferred value is 0" do
        @cpu.register[:SP] = 0x00
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the transferred value is not 0" do
        @cpu.register[:SP] = 0x50
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the sign flag if the transferred value has bit 7 set" do
        @cpu.register[:SP] = 0x80
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:S]
      end

      should "clear the sign flag if the transferred value does not have bit 7 set" do
        @cpu.register[:SP] = 0x08
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:S]
      end
    end
  end
end