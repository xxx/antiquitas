require File.expand_path('../../../test_helper', File.dirname(__FILE__))

class Cpu6502LdaTest < Test::Unit::TestCase
  context "LDA" do
    setup do
      @cpu = Cpu6502.new
    end

    context "immediate mode" do
      setup do
        @op = 0xA9
      end

      should_increase_pc_by 2
      should_increase_cycles_by 2

      should "load the accumulator with arg" do
        @cpu.runop(@op, 0x69)
        assert_equal 0x69, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator is zero" do
        @cpu.runop(@op, 0x00)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator is not zero" do
        @cpu.runop(@op, 0x04)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the accumulator is set" do
        @cpu.runop(@op, 0xFF)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the accumulator is not set" do
        @cpu.runop(@op, 0x01)
        assert_equal 0, @cpu.flag[:N]
      end
    end

    context "zeropage mode" do
      setup do
        @op = 0xA5
      end

      should_increase_pc_by 2
      should_increase_cycles_by 3

      should "load the accumulator with the correct value" do
        @cpu.ram[0x12] = 0x69
        @cpu.runop(@op, 0x12)
        assert_equal 0x69, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator is zero" do
        @cpu.ram[0x12] = 0x00
        @cpu.runop(@op, 0x12)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator is not zero" do
        @cpu.ram[0x12] = 0x04
        @cpu.runop(@op, 0x12)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the accumulator is set" do
        @cpu.ram[0x12] = 0xFF
        @cpu.runop(@op, 0x12)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the accumulator is not set" do
        @cpu.ram[0x12] = 0x01
        @cpu.runop(@op, 0x12)
        assert_equal 0, @cpu.flag[:N]
      end
    end

    context "zeropagex mode" do
      setup do
        @op = 0xB5
        @cpu.register[:X] = 0x04
      end

      should_increase_pc_by 2
      should_increase_cycles_by 4

      should "load the accumulator with the correct value" do
        @cpu.ram[0x12] = 0x69
        @cpu.runop(@op, 0x0E)
        assert_equal 0x69, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator is zero" do
        @cpu.ram[0x12] = 0x00
        @cpu.runop(@op, 0x0E)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator is not zero" do
        @cpu.ram[0x12] = 0x04
        @cpu.runop(@op, 0x0E)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the accumulator is set" do
        @cpu.ram[0x12] = 0xFF
        @cpu.runop(@op, 0x0E)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the accumulator is not set" do
        @cpu.ram[0x12] = 0x01
        @cpu.runop(@op, 0x0E)
        assert_equal 0, @cpu.flag[:N]
      end

      should "correct addresses to remain on the zero page" do
        @cpu.ram[0x12] = 0x01
        @cpu.register[:X] = 0xFF
        @cpu.runop(@op, 0x12)
        assert_equal 0x01, @cpu.register[:A]
      end
    end

    context "absolute mode" do
      setup do
        @op = 0xAD
      end

      should_increase_pc_by 3
      should_increase_cycles_by 4

      should "load the accumulator with the correct value" do
        @cpu.ram[0x128E] = 0x69
        @cpu.runop(@op, 0x12, 0x8E)
        assert_equal 0x69, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator is zero" do
        @cpu.ram[0x128E] = 0x00
        @cpu.runop(@op, 0x12, 0x8E)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator is not zero" do
        @cpu.ram[0x128E] = 0x04
        @cpu.runop(@op, 0x12, 0x8E)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the accumulator is set" do
        @cpu.ram[0x128E] = 0xFF
        @cpu.runop(@op, 0x12, 0x8E)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the accumulator is not set" do
        @cpu.ram[0x128E] = 0x01
        @cpu.runop(@op, 0x12, 0x8E)
        assert_equal 0, @cpu.flag[:N]
      end
    end

    context "absolutex mode" do
      setup do
        @op = 0xBD
        @cpu.register[:X] = 0x04
      end

      should_increase_pc_by 3
      should_increase_cycles_with_boundary_check_by 4

      should "load the accumulator with the correct value" do
        @cpu.ram[0x128E] = 0x69
        @cpu.runop(@op, 0x12, 0x8A)
        assert_equal 0x69, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator is zero" do
        @cpu.ram[0x128E] = 0x00
        @cpu.runop(@op, 0x12, 0x8A)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator is not zero" do
        @cpu.ram[0x128E] = 0x04
        @cpu.runop(@op, 0x12, 0x8A)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the accumulator is set" do
        @cpu.ram[0x128E] = 0xFF
        @cpu.runop(@op, 0x12, 0x8A)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the accumulator is not set" do
        @cpu.ram[0x128E] = 0x01
        @cpu.runop(@op, 0x12, 0x8A)
        assert_equal 0, @cpu.flag[:N]
      end
    end

    context "absolutey mode" do
      setup do
        @op = 0xB9
        @cpu.register[:Y] = 0x04
      end

      should_increase_pc_by 3
      should_increase_cycles_with_boundary_check_by 4

      should "load the accumulator with the correct value" do
        @cpu.ram[0x128E] = 0x69
        @cpu.runop(@op, 0x12, 0x8A)
        assert_equal 0x69, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator is zero" do
        @cpu.ram[0x128E] = 0x00
        @cpu.runop(@op, 0x12, 0x8A)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator is not zero" do
        @cpu.ram[0x128E] = 0x04
        @cpu.runop(@op, 0x12, 0x8A)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the accumulator is set" do
        @cpu.ram[0x128E] = 0xFF
        @cpu.runop(@op, 0x12, 0x8A)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the accumulator is not set" do
        @cpu.ram[0x128E] = 0x01
        @cpu.runop(@op, 0x12, 0x8A)
        assert_equal 0, @cpu.flag[:N]
      end
    end

    context "indirectx mode" do
      setup do
        @op = 0xA1
        @cpu.register[:X] = 0x04
        @cpu.ram[0x16] = 0x24
        @cpu.ram[0x17] = 0x51
      end

      should_increase_pc_by 2
      should_increase_cycles_by 6

      should "load the accumulator with the correct value" do
        @cpu.ram[0x5124] = 0x69
        @cpu.runop(@op, 0x12)
        assert_equal 0x69, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator is zero" do
        @cpu.ram[0x5124] = 0x00
        @cpu.runop(@op, 0x12)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator is not zero" do
        @cpu.ram[0x5124] = 0x04
        @cpu.runop(@op, 0x12)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the accumulator is set" do
        @cpu.ram[0x5124] = 0xFF
        @cpu.runop(@op, 0x12)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the accumulator is not set" do
        @cpu.ram[0x5124] = 0x01
        @cpu.runop(@op, 0x12)
        assert_equal 0, @cpu.flag[:N]
      end

      should "correct the address so it remains on the zero page" do
        @cpu.ram[0x5124] = 0x69
        @cpu.runop(@op, 0x12)
        assert_equal 0x69, @cpu.register[:A]
      end
    end

    context "indirecty mode" do
      setup do
        @op = 0xB1
        @cpu.register[:Y] = 0x04
        @cpu.ram[0x16] = 0x24
        @cpu.ram[0x17] = 0x51
      end

      should_increase_pc_by 2
      should_increase_cycles_with_boundary_check_by 5

      should "load the accumulator with the correct value" do
        @cpu.ram[0x5128] = 0x69
        @cpu.runop(@op, 0x16)
        assert_equal 0x69, @cpu.register[:A]
      end

      should "set the zero flag if the accumulator is zero" do
        @cpu.ram[0x5128] = 0x00
        @cpu.runop(@op, 0x16)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "clear the zero flag if the accumulator is not zero" do
        @cpu.ram[0x5128] = 0x04
        @cpu.runop(@op, 0x16)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the accumulator is set" do
        @cpu.ram[0x5128] = 0xFF
        @cpu.runop(@op, 0x16)
        assert_equal 1, @cpu.flag[:N]
      end

      should "clear the negative flag if bit 7 of the accumulator is not set" do
        @cpu.ram[0x5128] = 0x01
        @cpu.runop(@op, 0x16)
        assert_equal 0, @cpu.flag[:N]
      end
    end
  end
end