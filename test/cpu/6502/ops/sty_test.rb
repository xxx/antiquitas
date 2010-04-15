require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502StyTest < Test::Unit::TestCase
  context "STY" do
    setup do
      @cpu = Cpu6502.new
      @cpu.register[:Y] = 0x69
    end
    
    context "zeropage mode" do
      setup do
        @op = 0x84
      end

      should_increase_pc_by 2

      should "store the value in the Y register to the correct place in memory" do
        @cpu.runop(@op, 0x40)
        assert_equal 0x69, @cpu.ram[0x40]
      end
    end

    context "zeropagex mode" do
      setup do
        @op = 0x94
        @cpu.register[:X] = 0x04
      end

      should_increase_pc_by 2

      should "store the value in the Y register to the correct place in memory" do
        @cpu.runop(@op, 0x3C)
        assert_equal 0x69, @cpu.ram[0x40]
      end

      should "correct the address so it remains on the zero page" do
        @cpu.register[:X] = 0xFF
        @cpu.runop(@op, 0x40)
        assert_equal 0x69, @cpu.ram[0x40]
      end
    end

    context "absolute mode" do
      setup do
        @op = 0x8C
      end

      should_increase_pc_by 3

      should "store the value in the Y register to the correct place in memory" do
        @cpu.runop(@op, 0x20, 0x50)
        assert_equal 0x69, @cpu.ram[0x2050]
      end
    end
  end
end