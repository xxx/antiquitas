require File.expand_path('../../test_helper.rb', File.dirname(__FILE__))

class Cpu6502Test < Test::Unit::TestCase
#  include RR::Adapters::TestUnit

  def setup
    @cpu = Cpu6502.new
  end

  should_be_disassemblable
  should_be_monitorable

  should "be little-endian" do
    assert_equal :little, @cpu.endianness
  end

  context "initialization" do
    should "initialize the registers" do
      assert_equal 0, @cpu.register[:A]
      assert_equal 0, @cpu.register[:X]
      assert_equal 0, @cpu.register[:Y]
      assert_equal 0xFF, @cpu.register[:S]
      assert_equal 0, @cpu.register[:P]
    end

    should "zero the flags" do
      assert_equal 0, @cpu.flag[:N]
      assert_equal 0, @cpu.flag[:V]
      assert_equal 0, @cpu.flag[:B]
      assert_equal 0, @cpu.flag[:D]
      assert_equal 0, @cpu.flag[:I]
      assert_equal 0, @cpu.flag[:Z]
      assert_equal 0, @cpu.flag[:C]
    end

    should "initialize the pc" do
      assert_equal 0, @cpu.pc
    end
  end

  context "interrupts" do
    setup do
      @cpu.pc = 0x4520
    end

    context "NMI" do
      should "push the pc onto the stack, high byte first" do
        @cpu.nmi
        @cpu.pull # status register
        assert_equal 0x20, @cpu.pull
        assert_equal 0x45, @cpu.pull
      end

      should "push the status register onto the stack with the break flag clear" do
        @cpu.flag[:B] = 1
        @cpu.nmi
        assert_equal 0, @cpu.pull
      end

      should "load the pc from $FFFA/B" do
        @cpu.ram[0xFFFA] = 0x69
        @cpu.ram[0xFFFB] = 0x77
        @cpu.nmi
        assert_equal 0x7769, @cpu.pc
      end

      should "set the interrupt disable flag" do
        @cpu.nmi
        assert_equal 1, @cpu.flag[:I]
      end
    end

    context "IRQ" do
      should "not run if the interrupt disable flag is set" do
        @cpu.ram[0xFFFE] = 0x69
        @cpu.flag[:I] = 1
        @cpu.irq
        assert_equal 0x4520, @cpu.pc
      end

      should "push the pc onto the stack, high byte first" do
        @cpu.irq
        @cpu.pull # status register
        assert_equal 0x20, @cpu.pull
        assert_equal 0x45, @cpu.pull
      end

      should "push the status register onto the stack with the break flag clear" do
        @cpu.flag[:B] = 1
        @cpu.irq
        assert_equal 0, @cpu.pull
      end

      should "load the pc from $FFFE/F" do
        @cpu.ram[0xFFFE] = 0x69
        @cpu.ram[0xFFFF] = 0x77
        @cpu.irq
        assert_equal 0x7769, @cpu.pc
      end

      should "set the interrupt disable flag" do
        @cpu.irq
        assert_equal 1, @cpu.flag[:I]
      end
    end

    context "RESET" do
      should "load the pc from $FFFC/D" do
        @cpu.ram[0xFFFC] = 0x69
        @cpu.ram[0xFFFD] = 0x77
        @cpu.reset
        assert_equal 0x7769, @cpu.pc
      end

      should "set the interrupt disable flag" do
        @cpu.reset
        assert_equal 1, @cpu.flag[:I]
      end
    end
  end
end
