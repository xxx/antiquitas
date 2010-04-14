require File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper')

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

      should "set the sign flag to bit 7 of the memory value" do
        @cpu.ram[0x45] = 0x84
        @cpu.runop(@op, 0x45)
        assert_equal 1, @cpu.flag[:S]
      end

      should "not change the value in the accumulator" do
        @cpu.ram[0x45] = 0x80
        @cpu.runop(@op, 0x45)
        assert_equal 0x22, @cpu.register[:A]
      end
      
      should "increase the pc by the number of bytes for the op" do
        pc = @cpu.pc
        @cpu.runop(@op, 0xA0)
        assert_equal pc + 2, @cpu.pc
      end
    end
    
    context "absolute mode" do
      setup do
        @op = 0x2C
        @cpu.register[:A] = 0x22
      end

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

      should "set the sign flag to bit 7 of the memory value" do
        @cpu.ram[0x456A] = 0x84
        @cpu.runop(@op, 0x45, 0x6A)
        assert_equal 1, @cpu.flag[:S]
      end

      should "not change the value in the accumulator" do
        @cpu.ram[0x456A] = 0x80
        @cpu.runop(@op, 0x45, 0x6A)
        assert_equal 0x22, @cpu.register[:A]
      end

      should "increase the pc by the number of bytes for the op" do
        pc = @cpu.pc
        @cpu.runop(@op, 0xA0, 0x45)
        assert_equal pc + 3, @cpu.pc
      end
    end
  end
end