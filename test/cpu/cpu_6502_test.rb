require File.join(File.dirname(__FILE__), '..', 'test_helper')

class Cpu6502Test < Test::Unit::TestCase
  include RR::Adapters::TestUnit
  
  def setup
    @cpu = Cpu6502.new
  end

  context "initialization" do
    should "initialize the registers" do
      assert_equal 0, @cpu.register[:A]
      assert_equal 0, @cpu.register[:X]
      assert_equal 0, @cpu.register[:Y]
      assert_equal 0xFF, @cpu.register[:SP]
      assert_equal 0, @cpu.register[:SR]
    end

    should "zero the flags" do
      assert_equal 0, @cpu.flag[:S]
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

  context "opcodes" do
    context "LDA" do
      context "immediate mode" do
        should "load the accumulator with arg" do
          @cpu.runop(0xA9, 69)
          assert_equal 69, @cpu.register[:A]
        end

        should "set the zero flag if the accumulator is zero" do
          @cpu.runop(0xA9, 0)
          assert_equal 1, @cpu.flag[:Z]
        end

        should "clear the zero flag if the accumulator is not zero" do
          @cpu.runop(0xA9, 4)
          assert_equal 0, @cpu.flag[:Z]
        end

        should "set the sign flag if bit 7 of the accumulator is set" do
          @cpu.runop(0xA9, -1)
          assert_equal 1, @cpu.flag[:S]
        end

        should "clear the sign flag if bit 7 of the accumulator is not set" do
          @cpu.runop(0xA9, 1)
          assert_equal 0, @cpu.flag[:S]
        end

        should "increase the pc by the number of bytes for the op" do
          pc = @cpu.pc
          @cpu.runop(0xA9, 1)
          assert_equal pc + 2, @cpu.pc
        end
        
      end
    end

    context "TXA" do
      context "implied mode" do
        should "transfer the contents of the X register to the accumulator" do
          @cpu.register = {:A => 0, :X => 69}
          @cpu.runop(0x8A)
          assert_equal 69, @cpu.register[:A]
        end

        should "set the zero flag if the accumulator is zero" do
          @cpu.register = {:A => 69, :X => 0}
          @cpu.runop(0x8A)
          assert_equal 1, @cpu.flag[:Z]
        end

        should "clear the zero flag if the accumulator is not zero" do
          @cpu.register = {:A => 0, :X => 69}
          @cpu.runop(0x8A)
          assert_equal 0, @cpu.flag[:Z]
        end

        should "set the sign flag if bit 7 of the accumulator is set" do
          @cpu.register = {:A => 0, :X => -1}
          @cpu.runop(0x8A)
          assert_equal 1, @cpu.flag[:S]
        end

        should "clear the sign flag if bit 7 of the accumulator is not set" do
          @cpu.register = {:A => 0, :X => 69}
          @cpu.runop(0x8A)
          assert_equal 0, @cpu.flag[:S]
        end

        should "increase the pc by the number of bytes for the op" do
          pc = @cpu.pc
          @cpu.runop(0x8A)
          assert_equal pc + 1, @cpu.pc
        end
      end
    end

    context "TYA" do
      context "implied mode" do
        should "transfer the contents of the Y register to the accumulator" do
          @cpu.register = {:A => 0, :Y => 69}
          @cpu.runop(0x98)
          assert_equal 69, @cpu.register[:A]
        end

        should "set the zero flag if the accumulator is zero" do
          @cpu.register = {:A => 69, :Y => 0}
          @cpu.runop(0x98)
          assert_equal 1, @cpu.flag[:Z]
        end

        should "clear the zero flag if the accumulator is not zero" do
          @cpu.register = {:A => 0, :Y => 69}
          @cpu.runop(0x98)
          assert_equal 0, @cpu.flag[:Z]
        end

        should "set the sign flag if bit 7 of the accumulator is set" do
          @cpu.register = {:A => 0, :Y => -1}
          @cpu.runop(0x98)
          assert_equal 1, @cpu.flag[:S]
        end

        should "clear the sign flag if bit 7 of the accumulator is not set" do
          @cpu.register = {:A => 0, :Y => 69}
          @cpu.runop(0x98)
          assert_equal 0, @cpu.flag[:S]
        end

        should "increase the pc by the number of bytes for the op" do
          pc = @cpu.pc
          @cpu.runop(0x98)
          assert_equal pc + 1, @cpu.pc
        end
      end
    end

    context "JSR" do
      context "absolute mode" do
        should "push the current pc - 1 (after incrementing it for this op) onto the stack" do
          @cpu.pc = 2100
          @cpu.runop(0x20, 0x40, 0x25)
          low_end = @cpu.pull
          high_end = @cpu.pull
          assert_equal 2102, (high_end << 8) | low_end
        end

        should "set the program counter to the passed 16-bit memory address" do
          @cpu.runop(0x20, 0x40, 0x25)
          assert_equal (0x40 << 8) | 0x25, @cpu.pc
        end
      end
    end

    context "INX" do
      context "implied mode" do
        should "increment the X register" do
          @cpu.register = {:X => 8}
          @cpu.runop(0xE8)
          assert_equal 9, @cpu.register[:X]
        end

        should "set the sign flag of the bit 7 of the X register is set" do
          @cpu.register = {:X => -2}
          @cpu.runop(0xE8)
          assert_equal 1, @cpu.flag[:S]
        end

        should "clear the sign flag of the bit 7 of the X register is not set" do
          @cpu.register = {:X => -1}
          @cpu.runop(0xE8)
          assert_equal 0, @cpu.flag[:S]
        end

        should "set the zero flag if the X register is now 0" do
          @cpu.register = {:X => -1}
          @cpu.runop(0xE8)
          assert_equal 1, @cpu.flag[:Z]
        end

        should "clear the zero flag if the X register is now 0" do
          @cpu.register = {:X => 0}
          @cpu.runop(0xE8)
          assert_equal 0, @cpu.flag[:Z]
        end

        should "increase the pc by the number of bytes for the op" do
          pc = @cpu.pc
          @cpu.runop(0x8A)
          assert_equal pc + 1, @cpu.pc
        end
      end
    end

    context "CPX" do
      context "immediate mode" do
        setup do
          @cpu.register = {:X => 0x30}
        end

        should "set the carry flag if the value in the X register is the same or greater than the passed value" do
          @cpu.runop(0xE0, 0x30)
          assert_equal 1, @cpu.flag[:C]

          @cpu.runop(0xE0, 0)
          assert_equal 1, @cpu.flag[:C]
        end

        should "clear the carry flag if the value in the X register is less than the passed value" do
          @cpu.runop(0xE0, 0x40)
          assert_equal 0, @cpu.flag[:C]
        end

        should "set the zero flag if the value in the X register is the same as the passed value" do
          @cpu.runop(0xE0, 0x30)
          assert_equal 1, @cpu.flag[:Z]
        end

        should "clear the zero flag if the value in the X register is not the same as the passed value" do
          @cpu.runop(0xE0, 0)
          assert_equal 0, @cpu.flag[:Z]
        end

        should "set the sign flag of the value if the result of X minus the value is negative" do
          @cpu.runop(0xE0, 0x40)
          assert_equal 1, @cpu.flag[:S]
        end

        should "clear the sign flag of the value if the result of X minus the value is not negative" do
          @cpu.runop(0xE0, 0x30)
          assert_equal 0, @cpu.flag[:S]
        end

        should "increase the pc by the number of bytes for the op" do
          pc = @cpu.pc
          @cpu.runop(0xE0, 0x30)
          assert_equal pc + 2, @cpu.pc
        end
      end
    end

    context "BNE" do
      context "relative mode" do
        context "zero flag is set" do
          setup do
            @cpu.flag[:Z] = 1
          end

          should "increase the pc by the number of bytes for the op" do
            pc = @cpu.pc
            @cpu.runop(0xD0, 0xA0)
            assert_equal pc + 2, @cpu.pc
          end
        end

        context "zero flag is not set" do
          setup do
            @cpu.flag[:Z] = 0
          end

          should "increase or decrease the pc by the number of bytes for the op" do
            pc = @cpu.pc
            @cpu.runop(0xD0, 0x20)
            assert_equal pc + 0x20 + 2, @cpu.pc

            pc = @cpu.pc
            @cpu.runop(0xD0, 0xE0)
            assert_equal (pc - (~0xE0 & 0x00FF)) + 2, @cpu.pc
          end
        end
      end
    end

    context "NOP" do
      context "implied mode" do
        should "increase the pc by the number of bytes for the op" do
          pc = @cpu.pc
          @cpu.runop(0xEA)
          assert_equal pc + 1, @cpu.pc
        end
      end
    end
  end

end
