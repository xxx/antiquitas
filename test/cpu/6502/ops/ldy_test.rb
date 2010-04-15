require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502LdyTest < Test::Unit::TestCase
  context "LDY" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "immediate mode" do
      setup do
        @op = 0xA0
      end

      should_increase_pc_by 2

      should "load the argument into the Y register" do
        @cpu.runop(@op, 0x69)
        assert_equal 0x69, @cpu.register[:Y]
      end

      should "set the zero flag if the Y register is 0" do
        @cpu.runop(@op, 0x00)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the Y register is not 0" do
        @cpu.runop(@op, 0x01)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the Y register is set" do
        @cpu.runop(@op, 0xFF)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the Y register is not set" do
        @cpu.runop(@op, 0x00)
        assert_equal 0, @cpu.flag[:N]
      end
    end

    context "zeropage mode" do
      setup do
        @op = 0xA4
      end

      should_increase_pc_by 2

      should "load the correct value into the Y register" do
        @cpu.ram[0x04] = 0x69
        @cpu.runop(@op, 0x04)
        assert_equal 0x69, @cpu.register[:Y]
      end

      should "set the zero flag if the Y register is 0" do
        @cpu.ram[0x12] = 0x00
        @cpu.runop(@op, 0x12)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the Y register is not 0" do
        @cpu.ram[0x12] = 0x01
        @cpu.runop(@op, 0x12)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the Y register is set" do
        @cpu.ram[0x12] = 0xFF
        @cpu.runop(@op, 0x12)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the Y register is not set" do
        @cpu.ram[0x12] = 0x00
        @cpu.runop(@op, 0x12)
        assert_equal 0, @cpu.flag[:N]
      end
    end
    
    context "zeropagex mode" do
      setup do
        @op = 0xB4
        @cpu.register[:X] = 0x04
      end

      should_increase_pc_by 2

      should "load the correct value into the Y register" do
        @cpu.ram[0x08] = 0x69
        @cpu.runop(@op, 0x04)
        assert_equal 0x69, @cpu.register[:Y]
      end

      should "set the zero flag if the Y register is 0" do
        @cpu.ram[0x16] = 0x00
        @cpu.runop(@op, 0x12)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the Y register is not 0" do
        @cpu.ram[0x16] = 0x01
        @cpu.runop(@op, 0x12)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the Y register is set" do
        @cpu.ram[0x16] = 0xFF
        @cpu.runop(@op, 0x12)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the Y register is not set" do
        @cpu.ram[0x16] = 0x00
        @cpu.runop(@op, 0x12)
        assert_equal 0, @cpu.flag[:N]
      end

      should "correct the address so it stays on the zero page" do
        @cpu.register[:X] = 0xFF
        @cpu.ram[0x16] = 0x77
        @cpu.runop(@op, 0x16)
        assert_equal @cpu.register[:Y], 0x77
      end
    end

    context "absolute mode" do
      setup do
        @op = 0xAC
      end

      should_increase_pc_by 3

      should "load the correct value into the Y register" do
        @cpu.ram[0x049F] = 0x69
        @cpu.runop(@op, 0x04, 0x9F)
        assert_equal 0x69, @cpu.register[:Y]
      end

      should "set the zero flag if the Y register is 0" do
        @cpu.ram[0x129F] = 0x00
        @cpu.runop(@op, 0x12, 0x9F)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the Y register is not 0" do
        @cpu.ram[0x129F] = 0x01
        @cpu.runop(@op, 0x12, 0x9F)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the Y register is set" do
        @cpu.ram[0x129F] = 0xFF
        @cpu.runop(@op, 0x12, 0x9F)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the Y register is not set" do
        @cpu.ram[0x12, 0x9F] = 0x00
        @cpu.runop(@op, 0x12, 0x9F)
        assert_equal 0, @cpu.flag[:N]
      end
    end

    context "absolutex mode" do
      setup do
        @op = 0xBC
        @cpu.register[:X] = 0x04
      end

      should_increase_pc_by 3

      should "load the correct value into the Y register" do
        @cpu.ram[0x049F] = 0x69
        @cpu.runop(@op, 0x04, 0x9B)
        assert_equal 0x69, @cpu.register[:Y]
      end

      should "set the zero flag if the Y register is 0" do
        @cpu.ram[0x129F] = 0x00
        @cpu.runop(@op, 0x12, 0x9B)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the Y register is not 0" do
        @cpu.ram[0x129F] = 0x01
        @cpu.runop(@op, 0x12, 0x9B)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the Y register is set" do
        @cpu.ram[0x129F] = 0xFF
        @cpu.runop(@op, 0x12, 0x9B)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the Y register is not set" do
        @cpu.ram[0x12, 0x9F] = 0x00
        @cpu.runop(@op, 0x12, 0x9B)
        assert_equal 0, @cpu.flag[:N]
      end
    end
  end
end