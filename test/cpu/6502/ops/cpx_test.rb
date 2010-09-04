require File.expand_path('../../../test_helper', File.dirname(__FILE__))

class Cpu6502CpxTest < Test::Unit::TestCase
  context "CPX" do
    setup do
      @cpu = Cpu6502.new
    end

    context "immediate mode" do
      setup do
        @op = 0xE0
        @cpu.register[:X] = 0x30
      end

      should_increase_pc_by 2
      should_increase_cycles_by 2

      should "set the carry flag if the value in the X register is the same or greater than the passed value" do
        @cpu.runop(@op, 0x30)
        assert_equal 1, @cpu.flag[:C]

        @cpu.runop(@op, 0)
        assert_equal 1, @cpu.flag[:C]
      end

      should "clear the carry flag if the value in the X register is less than the passed value" do
        @cpu.runop(@op, 0x40)
        assert_equal 0, @cpu.flag[:C]
      end

      should "set the zero flag if the value in the X register is the same as the passed value" do
        @cpu.runop(@op, 0x30)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the value in the X register is not the same as the passed value" do
        @cpu.runop(@op, 0)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag of the value if the result of X minus the value is negative" do
        @cpu.runop(@op, 0x40)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag of the value if the result of X minus the value is not negative" do
        @cpu.runop(@op, 0x30)
        assert_equal 0, @cpu.flag[:N]
      end
    end

    context "zeropage mode" do
      setup do
        @op = 0xE4
        @cpu.register[:X] = 0x30
        @cpu.ram[0x1A] = 0x69
      end

      should_increase_pc_by 2
      should_increase_cycles_by 3

      should "set the carry flag if the X register value is the same or greater than the passed value" do
        @cpu.ram[0x1A] = 0x20
        @cpu.runop(@op, 0x1A)
        assert_equal 1, @cpu.flag[:C]

        @cpu.ram[0x1A] = 0x30
        @cpu.runop(@op, 0x1A)
        assert_equal 1, @cpu.flag[:C]
      end

      should "clear the carry flag if the X register value is less than the passed value" do
        @cpu.runop(@op, 0x1A)
        assert_equal 0, @cpu.flag[:C]
      end

      should "set the zero flag if the X register value is the same as the passed value" do
        @cpu.ram[0x1A] = 0x30
        @cpu.runop(@op, 0x1A)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the X register value is not the same as the passed value" do
        @cpu.runop(@op, 0x1A)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag of the value if the result of X minus the value is negative" do
        @cpu.runop(@op, 0x1A)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag of the value if the result of X minus the value is not negative" do
        @cpu.ram[0x1A] = 0x01
        @cpu.runop(@op, 0x1A)
        assert_equal 0, @cpu.flag[:N]
      end
    end

    context "absolute mode" do
      setup do
        @op = 0xEC
        @cpu.register[:X] = 0x30
        @cpu.ram[0x1A34] = 0x69
      end

      should_increase_pc_by 3
      should_increase_cycles_by 4

      should "set the carry flag if the X register value is the same or greater than the passed value" do
        @cpu.ram[0x1A34] = 0x20
        @cpu.runop(@op, 0x1A, 0x34)
        assert_equal 1, @cpu.flag[:C]

        @cpu.ram[0x1A34] = 0x30
        @cpu.runop(@op, 0x1A, 0x34)
        assert_equal 1, @cpu.flag[:C]
      end

      should "clear the carry flag if the X register value is less than the passed value" do
        @cpu.runop(@op, 0x1A, 0x34)
        assert_equal 0, @cpu.flag[:C]
      end

      should "set the zero flag if the X register value is the same as the passed value" do
        @cpu.ram[0x1A34] = 0x30
        @cpu.runop(@op, 0x1A, 0x34)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the X register value is not the same as the passed value" do
        @cpu.runop(@op, 0x1A, 0x34)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag of the value if the result of X minus the value is negative" do
        @cpu.runop(@op, 0x1A, 0x34)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag of the value if the result of X minus the value is not negative" do
        @cpu.ram[0x1A34] = 0x01
        @cpu.runop(@op, 0x1A, 0x34)
        assert_equal 0, @cpu.flag[:N]
      end
    end
  end
end