require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

class Cpu6502IncTest < Test::Unit::TestCase
  context "INC" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "zeropage mode" do
      setup do
        @op = 0xE6
        @cpu.ram[0x12] = 0x69
      end

      should_increase_pc_by 2
      should_increase_cycles_by 5

      should "increment the value at the correct address by 1" do
        @cpu.runop(@op, 0x12)
        assert_equal 0x6A, @cpu.ram[0x12]
      end

      should "set the zero flag if the result is 0" do
        @cpu.ram[0x12] = 0xFF
        @cpu.runop(@op, 0x12)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the result is not 0" do
        @cpu.runop(@op, 0x12)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result is set" do
        @cpu.ram[0x12] = 0x81
        @cpu.runop(@op, 0x12)
        assert_equal 1, @cpu.flag[:N]
      end

      should "not set the negative flag if bit 7 of the result is not set" do
        @cpu.runop(@op, 0x12)
        assert_equal 0, @cpu.flag[:N]
      end
    end

    context "zeropagex mode" do
      setup do
        @op = 0xF6
        @cpu.ram[0x16] = 0x69
        @cpu.register[:X] = 0x04
      end

      should_increase_pc_by 2
      should_increase_cycles_by 6

      should "increment the value at the correct address by 1" do
        @cpu.runop(@op, 0x12)
        assert_equal 0x6A, @cpu.ram[0x16]
      end

      should "set the zero flag if the result is 0" do
        @cpu.ram[0x16] = 0xFF
        @cpu.runop(@op, 0x12)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the result is not 0" do
        @cpu.runop(@op, 0x12)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result is set" do
        @cpu.ram[0x16] = 0x81
        @cpu.runop(@op, 0x12)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the result is not set" do
        @cpu.runop(@op, 0x12)
        assert_equal 0, @cpu.flag[:N]
      end

      should "correct the calculated address to stay on the zero page" do
        @cpu.register[:X] = 0xFF
        @cpu.runop(@op, 0x16)
        assert_equal 0x6A, @cpu.ram[0x16]
      end
    end
    
    context "absolute mode" do
      setup do
        @op = 0xEE
        @cpu.ram[0x165B] = 0x69
      end

      should_increase_pc_by 3
      should_increase_cycles_by 6

      should "increment the value at the correct address by 1" do
        @cpu.runop(@op, 0x16, 0x5B)
        assert_equal 0x6A, @cpu.ram[0x165B]
      end

      should "set the zero flag if the result is 0" do
        @cpu.ram[0x165B] = 0xFF
        @cpu.runop(@op, 0x16, 0x5B)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the result is not 0" do
        @cpu.runop(@op, 0x16, 0x5B)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result is set" do
        @cpu.ram[0x165B] = 0x81
        @cpu.runop(@op, 0x16, 0x5B)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the result is not set" do
        @cpu.runop(@op, 0x16, 0x5B)
        assert_equal 0, @cpu.flag[:N]
      end
    end
    
    context "absolutex mode" do
      setup do
        @op = 0xFE
        @cpu.register[:X] = 0x04
        @cpu.ram[0x165F] = 0x69
      end

      should_increase_pc_by 3
      should_increase_cycles_by 7

      should "increment the value at the correct address by 1" do
        @cpu.runop(@op, 0x16, 0x5B)
        assert_equal 0x6A, @cpu.ram[0x165F]
      end

      should "set the zero flag if the result is 0" do
        @cpu.ram[0x165F] = 0xFF
        @cpu.runop(@op, 0x16, 0x5B)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the result is not 0" do
        @cpu.runop(@op, 0x16, 0x5B)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result is set" do
        @cpu.ram[0x165F] = 0x81
        @cpu.runop(@op, 0x16, 0x5B)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the result is not set" do
        @cpu.runop(@op, 0x16, 0x5B)
        assert_equal 0, @cpu.flag[:N]
      end
    end
  end
end