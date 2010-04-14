require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502RtsTest < Test::Unit::TestCase
  context "RTS" do
    setup do
      @cpu = Cpu6502.new
    end

    context "implied mode" do
      setup do
        @op = 0x60
      end

      should "pulls a new value for the pc from the stack, increments, it, and assigns it to the pc" do
        @cpu.pc = 0x53FF
        @cpu.push(0x88)
        @cpu.push(0x20)
        @cpu.runop(@op)
        assert_equal 0x8821, @cpu.pc
      end
    end
  end
end