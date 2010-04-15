require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502CTayTest < Test::Unit::TestCase
  context "TAY" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "implied mode" do
      setup do
        @op = 0xA8
      end

      should_increase_pc_by 1

      should "transfer the value in the accumulator to the Y register" do
        @cpu.register[:A] = 0x69
        @cpu.runop(@op)
        assert_equal 0x69, @cpu.register[:Y]
      end

      should "set the zero flag if the transferred value is 0" do
        @cpu.register[:A] = 0x00
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the transferred value is not 0" do
        @cpu.register[:A] = 0x50
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if the transferred value has bit 7 set" do
        @cpu.register[:A] = 0x80
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if the transferred value does not have bit 7 set" do
        @cpu.register[:A] = 0x08
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:N]
      end
    end
  end
end