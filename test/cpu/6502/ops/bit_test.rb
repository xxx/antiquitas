require File.expand_path('../../../test_helper', File.dirname(__FILE__))

class Cpu6502BitTest < Test::Unit::TestCase
  context "BIT" do
    setup do
      @cpu = Cpu6502.new
    end
    
    context "zeropage mode" do
      setup do
        @op = 0x24
        @cpu.register[:A] = 0x22
      end

      should_increase_pc_by 2
      should_increase_cycles_by 3
      
      context "one or more bits are set" do
        should "not set the zero flag" do
          @cpu.ram[0x45] = 0x12
          @cpu.runop(@op, 0x45)
          assert_equal 0, @cpu.flag[:Z]
        end
      end

      context "no bits are set" do
        should "set the zero flag" do
          @cpu.ram[0x45] = 0x80
          @cpu.runop(@op, 0x45)
          assert_equal 1, @cpu.flag[:Z]
        end
      end

      should "set the overflow flag to bit 6 of the memory value" do
        @cpu.ram[0x45] = 0x4A
        @cpu.runop(@op, 0x45)
        assert_equal 1, @cpu.flag[:V]
      end

      should "set the negative flag to bit 7 of the memory value" do
        @cpu.ram[0x45] = 0x84
        @cpu.runop(@op, 0x45)
        assert_equal 1, @cpu.flag[:N]
      end

      should "not change the value in the accumulator" do
        @cpu.ram[0x45] = 0x80
        @cpu.runop(@op, 0x45)
        assert_equal 0x22, @cpu.register[:A]
      end
    end
    
    context "absolute mode" do
      setup do
        @op = 0x2C
        @cpu.register[:A] = 0x22
      end

      should_increase_pc_by 3
      should_increase_cycles_by 4

      context "one or more bits are set" do
        should "not set the zero flag" do
          @cpu.ram[0x456A] = 0x12
          @cpu.runop(@op, 0x45, 0x6A)
          assert_equal 0, @cpu.flag[:Z]
        end
      end

      context "no bits are set" do
        should "set the zero flag" do
          @cpu.ram[0x456A] = 0x80
          @cpu.runop(@op, 0x45, 0x6A)
          assert_equal 1, @cpu.flag[:Z]
        end
      end

      should "set the overflow flag to bit 6 of the memory value" do
        @cpu.ram[0x456A] = 0x4A
        @cpu.runop(@op, 0x45, 0x6A)
        assert_equal 1, @cpu.flag[:V]
      end

      should "set the negative flag to bit 7 of the memory value" do
        @cpu.ram[0x456A] = 0x84
        @cpu.runop(@op, 0x45, 0x6A)
        assert_equal 1, @cpu.flag[:N]
      end

      should "not change the value in the accumulator" do
        @cpu.ram[0x456A] = 0x80
        @cpu.runop(@op, 0x45, 0x6A)
        assert_equal 0x22, @cpu.register[:A]
      end
    end
  end
end