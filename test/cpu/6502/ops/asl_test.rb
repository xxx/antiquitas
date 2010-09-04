require File.expand_path('../../../test_helper', File.dirname(__FILE__))

class Cpu6502AslTest < Test::Unit::TestCase
  context "ASL" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "accumulator mode" do
      setup do
        @op = 0x0A
      end

      should_increase_pc_by 1
      should_increase_cycles_by 2
      
      should "shift the accumulator left 1 bit" do
        @cpu.register[:A] = 0x20
        @cpu.runop(@op)
        assert_equal 0x20 << 1, @cpu.register[:A]
      end

      should "set the zero flag if the acc is now zero" do
        @cpu.register[:A] = 0x80
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the acc is not zero" do
        @cpu.register[:A] = 0x05
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result is set" do
        @cpu.register[:A] = 0x40
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:N]
      end

      should "not set the negative flag if bit 7 of the result is not set" do
        @cpu.register[:A] = 0x03
        @cpu.runop(@op)
        assert_equal 0, @cpu.flag[:N]
      end

      should "set the carry flag to pre-shift bit 7 of the item to get shifted" do
        @cpu.register[:A] = 0x81
        @cpu.runop(@op)
        assert_equal 1, @cpu.flag[:C]
      end
    end

    context "zeropage mode" do
      setup do
        @op = 0x06
      end

      should_increase_pc_by 2
      should_increase_cycles_by 5

      should "shift the value at the passed location left 1 bit" do
        @cpu.ram[0x04] = 0x20
        @cpu.runop(@op, 0x04)
        assert_equal 0x20 << 1, @cpu.ram[0x04]
      end

      should "set the zero flag if the acc is now zero" do
        @cpu.ram[0x04] = 0x80
        @cpu.runop(@op, 0x04)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the acc is not zero" do
        @cpu.ram[0x04] = 0x05
        @cpu.runop(@op, 0x04)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result is set" do
        @cpu.ram[0x04] = 0x40
        @cpu.runop(@op, 0x04)
        assert_equal 1, @cpu.flag[:N]
      end

      should "not set the negative flag if bit 7 of the result is not set" do
        @cpu.ram[0x04] = 0x03
        @cpu.runop(@op, 0x04)
        assert_equal 0, @cpu.flag[:N]
      end

      should "set the carry flag to pre-shift bit 7 of the item to get shifted" do
        @cpu.ram[0x04] = 0x81
        @cpu.runop(@op, 0x04)
        assert_equal 1, @cpu.flag[:C]
      end
    end

    context "zeropagex mode" do
      setup do
        @op = 0x16
        @cpu.register[:X] = 0x06
      end

      should_increase_pc_by 2
      should_increase_cycles_by 6

      should "shift the value at the passed location + the value in the X register left 1 bit" do
        @cpu.ram[0x0A] = 0x20
        @cpu.runop(@op, 0x04)
        assert_equal 0x20 << 1, @cpu.ram[0x0A]
      end

      should "set the zero flag if the acc is now zero" do
        @cpu.ram[0x0A] = 0x80
        @cpu.runop(@op, 0x04)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the acc is not zero" do
        @cpu.ram[0x0A] = 0x05
        @cpu.runop(@op, 0x04)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result is set" do
        @cpu.ram[0x0A] = 0x40
        @cpu.runop(@op, 0x04)
        assert_equal 1, @cpu.flag[:N]
      end

      should "not set the negative flag if bit 7 of the result is not set" do
        @cpu.ram[0x0A] = 0x03
        @cpu.runop(@op, 0x04)
        assert_equal 0, @cpu.flag[:N]
      end

      should "set the carry flag to pre-shift bit 7 of the item to get shifted" do
        @cpu.ram[0x0A] = 0x81
        @cpu.runop(@op, 0x04)
        assert_equal 1, @cpu.flag[:C]
      end
    end

    context "absolute mode" do
      setup do
        @op = 0x0E
      end

      should_increase_pc_by 3
      should_increase_cycles_by 6

      should "shift the value at the passed location left 1 bit" do
        @cpu.ram[0x23B3] = 0x20
        @cpu.runop(@op, 0x23, 0xB3)
        assert_equal 0x20 << 1, @cpu.ram[0x23B3]
      end

      should "set the zero flag if the acc is now zero" do
        @cpu.ram[0x23B3] = 0x80
        @cpu.runop(@op, 0x23, 0xB3)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the acc is not zero" do
        @cpu.ram[0x23B3] = 0x05
        @cpu.runop(@op, 0x23, 0xB3)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result is set" do
        @cpu.ram[0x23B3] = 0x40
        @cpu.runop(@op, 0x23, 0xB3)
        assert_equal 1, @cpu.flag[:N]
      end

      should "not set the negative flag if bit 7 of the result is not set" do
        @cpu.ram[0x23B3] = 0x03
        @cpu.runop(@op, 0x23, 0xB3)
        assert_equal 0, @cpu.flag[:N]
      end

      should "set the carry flag to pre-shift bit 7 of the item to get shifted" do
        @cpu.ram[0x23B3] = 0x81
        @cpu.runop(@op, 0x23, 0xB3)
        assert_equal 1, @cpu.flag[:C]
      end
    end

    context "absolutex mode" do
      setup do
        @op = 0x1E
        @cpu.register[:X] = 0x04
      end

      should_increase_pc_by 3
      should_increase_cycles_by 7

      should "shift the value at the passed location + the value in the X register left 1 bit" do
        @cpu.ram[0x23B3] = 0x20
        @cpu.runop(@op, 0x23, 0xAF)
        assert_equal 0x20 << 1, @cpu.ram[0x23B3]
      end

      should "set the zero flag if the acc is now zero" do
        @cpu.ram[0x23B3] = 0x80
        @cpu.runop(@op, 0x23, 0xAF)
        assert_equal 1, @cpu.flag[:Z]
      end

      should "not set the zero flag if the acc is not zero" do
        @cpu.ram[0x23B3] = 0x05
        @cpu.runop(@op, 0x23, 0xAF)
        assert_equal 0, @cpu.flag[:Z]
      end

      should "set the negative flag if bit 7 of the result is set" do
        @cpu.ram[0x23B3] = 0x40
        @cpu.runop(@op, 0x23, 0xAF)
        assert_equal 1, @cpu.flag[:N]
      end

      should "not set the negative flag if bit 7 of the result is not set" do
        @cpu.ram[0x23B3] = 0x03
        @cpu.runop(@op, 0x23, 0xAF)
        assert_equal 0, @cpu.flag[:N]
      end

      should "set the carry flag to pre-shift bit 7 of the item to get shifted" do
        @cpu.ram[0x23B3] = 0x81
        @cpu.runop(@op, 0x23, 0xAF)
        assert_equal 1, @cpu.flag[:C]
      end
    end
  end
end