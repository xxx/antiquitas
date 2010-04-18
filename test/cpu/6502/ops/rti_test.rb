require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502RtiTest < Test::Unit::TestCase
  context "RTI" do
    setup do
      @cpu = Cpu6502.new
    end

    context "implied mode" do
      setup do
        @op = 0x40
      end

      should_increase_cycles_by 6
      
      should "pull the value of the status register from the stack and set the flags from it accordingly, then the two bytes of the address to return to, low byte first, then set the pc to that address" do
        @cpu.pc = 0x53FF
        @cpu.push(0x88)
        @cpu.push(0x20)
        @cpu.push(0x03)
        @cpu.runop(@op)
        # bits 7 to 0 are: N V - B D I Z C
        assert_equal 1, @cpu.flag[:C]
        assert_equal 1, @cpu.flag[:Z]
        assert_equal 0x8820, @cpu.pc
      end

      should "always set the break flag to 0 because it doesn't actually exist" do
        @cpu.flag[:B] = 1
        @cpu.push(0x88)
        @cpu.push(0x20)
        @cpu.push(0x00)
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:B]
      end
    end
  end
end