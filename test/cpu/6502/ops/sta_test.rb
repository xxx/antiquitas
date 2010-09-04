require File.expand_path('../../../test_helper', File.dirname(__FILE__))

class Cpu6502StaTest < Test::Unit::TestCase
  context "STA" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "zeropage mode" do
      setup do
        @op = 0x85
        @cpu.register[:A] = 0x69
      end

      should_increase_pc_by 2
      should_increase_cycles_by 3

      should "store the value in the accumulator into the correct place in memory" do
        @cpu.runop(@op, 0x50)
        assert_equal 0x69, @cpu.ram[0x50]
      end
    end

    context "zeropagex mode" do
      setup do
        @op = 0x95
        @cpu.register[:A] = 0x69
        @cpu.register[:X] = 0x04
      end

      should_increase_pc_by 2
      should_increase_cycles_by 4

      should "store the value in the accumulator into the correct place in memory" do
        @cpu.runop(@op, 0x50)
        assert_equal 0x69, @cpu.ram[0x54]
      end

      should "wrap addresses around to remain on the zero page" do
        @cpu.runop(@op, 0xFE)
        assert_equal 0x69, @cpu.ram[0x03]
      end
    end

    context "absolute mode" do
      setup do
        @op = 0x8D
        @cpu.register[:A] = 0x69
      end

      should_increase_pc_by 3
      should_increase_cycles_by 4

      should "store the value in the accumulator into the correct place in memory" do
        @cpu.runop(@op, 0x51, 0x50)
        assert_equal 0x69, @cpu.ram[0x5150]
      end
    end

    context "absolutex mode" do
      setup do
        @op = 0x9D
        @cpu.register[:A] = 0x69
        @cpu.register[:X] = 0x04
      end

      should_increase_pc_by 3
      should_increase_cycles_by 5

      should "store the value in the accumulator into the correct place in memory" do
        @cpu.runop(@op, 0x51, 0x4C)
        assert_equal 0x69, @cpu.ram[0x5150]
      end
    end

    context "absolutey mode" do
      setup do
        @op = 0x99
        @cpu.register[:A] = 0x69
        @cpu.register[:Y] = 0x04
      end

      should_increase_pc_by 3
      should_increase_cycles_by 5
      
      should "store the value in the accumulator into the correct place in memory" do
        @cpu.runop(@op, 0x51, 0x4C)
        assert_equal 0x69, @cpu.ram[0x5150]
      end
    end

    context "indirectx mode" do
      setup do
        @op = 0x81
        @cpu.register[:A] = 0x69
        @cpu.register[:X] = 0x04
        @cpu.ram[0x34] = 0x20
        @cpu.ram[0x35] = 0x1F
      end

      should_increase_pc_by 2
      should_increase_cycles_by 6

      should "store the value in the accumulator into the correct place in memory" do
        @cpu.runop(@op, 0x30)
        assert_equal 0x69, @cpu.ram[0x1F20]
      end

      should "wrap addresses around to remain on the zero page" do
        @cpu.ram[0x02] = 0x10
        @cpu.ram[0x03] = 0x12
        @cpu.runop(@op, 0xFE)
        assert_equal 0x69, @cpu.ram[0x1210]
      end
    end

    context "indirecty mode" do
      setup do
        @op = 0x91
        @cpu.register[:A] = 0x69
        @cpu.register[:Y] = 0x04
        @cpu.ram[0x34] = 0x20
        @cpu.ram[0x35] = 0x1F
      end

      should_increase_pc_by 2
      should_increase_cycles_by 6

      should "store the value in the accumulator into the correct place in memory" do
        @cpu.runop(@op, 0x34)
        assert_equal 0x69, @cpu.ram[0x1F24]
      end

      should "wrap addresses around to remain on the zero page" do
        @cpu.ram[0x00] = 0x12
        @cpu.ram[0xFF] = 0x0C
        @cpu.ram[0x100] = 0xB0
        @cpu.runop(@op, 0xFF)
        assert_equal 0x69, @cpu.ram[0x1210]
      end
    end
  end
end