require File.join(File.dirname(__FILE__), '..', 'test_helper')

class MonitorTest < Test::Unit::TestCase
  context Antiquitas::Monitor do
    setup do
      @monitor = Antiquitas::Monitor.new
    end

    context "#monitor" do
      should "return itself, monitoring the passed hardware instance as the hardware" do
        @cpu = Cpu6502.new
        mon = @monitor.monitor(@cpu)
        assert_equal @monitor, mon
        assert_equal @cpu, mon.hardware
      end

      should "return itself, monitoring a new instance of the passed class" do
        mon = @monitor.monitor(Cpu6502)
        assert_equal @monitor, mon
        assert @monitor.hardware.kind_of?(Cpu6502)
      end

      should "make the hardware instance disassemblable" do
        @monitor.monitor(Cpu6502)
        assert @monitor.hardware.respond_to?(:disassemble)
      end
    end

    should "dynamically delegate methods it doesn't know about to the hardware" do
      @monitor.monitor(Cpu6502)
      assert_equal @monitor.hardware.flag, @monitor.flag
    end

    context "#parse_command" do
      setup do
        @monitor.monitor Cpu6502
      end
      
      should "strip out any whitespace from the passed command" do
        mock(@monitor).breakpoint({})
        @monitor.parse_command '   break   '
      end

      context "%break" do
        context "no arguments" do
          should "call the command" do
            mock(@monitor).breakpoint({})
            @monitor.parse_command('break')
          end
        end

        context "hex address" do
          should "convert to a real hex address" do
            mock(@monitor).breakpoint(:address => 0xFFAB)
            @monitor.parse_command('break $FFAB')
          end
        end

        context "alternate invocations" do
          should "work with alternate invocations" do
            mock(@monitor).breakpoint({}).twice
            @monitor.parse_command 'bp'
            @monitor.parse_command 'breakpoint'
          end
        end

        context "conditionals" do
          should "parse and pass the conditional" do
            mock(@monitor).breakpoint(:address => 0xFFAB, :condition => "@flag[:Z] == 1")
            @monitor.parse_command 'bp $FFAB @flag[:Z] == 1'
          end
        end
      end

      context "%watch" do
        context "no args" do
          should "call the command" do
            mock(@monitor).watchpoint({})
            @monitor.parse_command('watch')
          end
        end

        context "single hex address arg" do
          should "pass the arg as a real hex value" do
            mock(@monitor).watchpoint(:address => 0x69)
            @monitor.parse_command('watch $69')
          end
        end

        context "flag arg" do
          should "call with the correct argument" do
            mock(@monitor).watchpoint(:flag => :z)
            @monitor.parse_command('watch flag:z')
          end
        end

        context "register arg" do
          should "call with the correct argument" do
            mock(@monitor).watchpoint(:register => :x)
            @monitor.parse_command('watch register:x')
          end
        end

        context "conditions" do
          should "pass all of the args correctly" do
            mock(@monitor).watchpoint(:address => 0x69, :condition => "@register[:X] < 0xFF")
            @monitor.parse_command('watch $69 @register[:X] < 0xFF')
          end
        end
      end

      context "trap" do
        context "read traps" do
          context "no address" do
            should "call the command" do
              mock(@monitor).trap({:type => :read})
              @monitor.parse_command('trap read')
            end
          end

          context "single hex address arg" do
            should "pass the arg as a real hex value" do
              mock(@monitor).trap(:address => 0x69, :type => :read)
              @monitor.parse_command('trap read $69')
            end
          end

          context "flag arg" do
            should "call with the correct argument" do
              mock(@monitor).trap(:type => :read, :flag => :z)
              @monitor.parse_command('trap read flag:z')
            end
          end

          context "register arg" do
            should "call with the correct argument" do
              mock(@monitor).trap(:type => :read, :register => :x)
              @monitor.parse_command('trap read register:x')
            end
          end

          context "alternate invocation" do
            should "call with the correct argument" do
              mock(@monitor).trap(:type => :read, :register => :x)
              @monitor.parse_command('trap r reg:x')
            end
          end
        end

        context "write traps" do
          context "no address" do
            should "call the command" do
              mock(@monitor).trap({:type => :write})
              @monitor.parse_command('trap write')
            end
          end

          context "single hex address arg" do
            should "pass the arg as a real hex value" do
              mock(@monitor).trap(:address => 0x69, :type => :write)
              @monitor.parse_command('trap write $69')
            end
          end

          context "flag arg" do
            should "call with the correct argument" do
              mock(@monitor).trap(:type => :write, :flag => :z)
              @monitor.parse_command('trap write flag:z')
            end
          end

          context "register arg" do
            should "call with the correct argument" do
              mock(@monitor).trap(:type => :write, :register => :x)
              @monitor.parse_command('trap write register:x')
            end
          end

          context "alternate invocation" do
            should "call with the correct argument" do
              mock(@monitor).trap(:type => :write, :flag => :z)
              @monitor.parse_command('trap w flag:z')
            end
          end
        end

        context "read-write traps" do
          context "no address" do
            should "call the command" do
              mock(@monitor).trap({:type => :readwrite})
              @monitor.parse_command('trap readwrite')
            end
          end

          context "single hex address arg" do
            should "pass the arg as a real hex value" do
              mock(@monitor).trap(:address => 0x69, :type => :readwrite)
              @monitor.parse_command('trap readwrite $69')
            end
          end

          context "flag arg" do
            should "call with the correct argument" do
              mock(@monitor).trap(:type => :readwrite, :flag => :z)
              @monitor.parse_command('trap readwrite flag:z')
            end
          end

          context "register arg" do
            should "call with the correct argument" do
              mock(@monitor).trap(:type => :readwrite, :register => :x)
              @monitor.parse_command('trap readwrite register:x')
            end
          end

          context "alternate invocation" do
            should "call with the correct argument" do
              mock(@monitor).trap(:type => :readwrite, :address => 0x6969)
              @monitor.parse_command('trap rw $6969')
            end
          end
        end
      end

      context "continue" do
        context "no args" do
          should "call the command" do
            mock(@monitor).continue
            @monitor.parse_command('continue')
          end
        end

        context "alternate invocations" do
          should "call the command" do
            mock(@monitor).continue
            @monitor.parse_command('cont')
          end
        end
      end

      context "step/next" do
        context "no args" do
          should "call the command" do
            mock(@monitor).step
            @monitor.parse_command('step')
          end
        end

        context "alternate invocations" do
          should "call the command" do
            mock(@monitor).step.times(3)
            @monitor.parse_command('next')
            @monitor.parse_command('n')
            @monitor.parse_command('s')
          end
        end

      end

      context "backtrace" do
        context "no args" do
          should "call the command" do
            mock(@monitor).backtrace
            @monitor.parse_command('backtrace')
          end
        end

        context "alternate invocations" do
          should "call the command" do
            mock(@monitor).backtrace
            @monitor.parse_command('bt')
          end
        end
      end

      context "dump" do
        context "no args" do
          should "call the command" do
            mock(@monitor).dump
            @monitor.parse_command('dump')
          end
        end

        context "alternate invocations" do
          should "call the command" do
            mock(@monitor).dump
            @monitor.parse_command('d')
          end
        end
      end

      context "disassemble" do
        context "no args" do
          should "call the command" do
            mock(@monitor).disassemble({})
            @monitor.parse_command('disassemble')
          end
        end

        context "alternate invocations" do
          should "call the command" do
            mock(@monitor).disassemble({})
            @monitor.parse_command('dis')
          end
        end

        context "with address" do
          should "pass the arg as a real hex value" do
            mock(@monitor).disassemble(:address => 0x69)
            @monitor.parse_command('disassemble $69')
          end
        end

        context "with byte count" do
          should "pass the correct byte count" do
            mock(@monitor).disassemble(:bytes => 50)
            @monitor.parse_command('dis 50')
          end
        end
        
        context "with address and byte count" do
          should "call disassemble with the correct arguments" do
            mock(@monitor).disassemble(:bytes => 50, :address => 0x69)
            @monitor.parse_command('dis $69 50')
          end
        end
      end

      context "label" do
        context "no args" do
          should "call the command" do
            mock(@monitor).label({})
            @monitor.parse_command('label')
          end
        end

        context "with an address" do
          should "call the command" do
            mock(@monitor).label(:address => 0x69)
            @monitor.parse_command('label $69')
          end
        end

        context "with address and name" do
          should "call the command" do
            mock(@monitor).label(:address => 0x69, :name => 'foobar baz')
            @monitor.parse_command('label $69 foobar baz')
          end
        end
      end

      context "help" do
        context "no args" do
          should "call the command" do
            mock(@monitor).help
            @monitor.parse_command('help')
          end
        end

        context "alternate invocations" do
          should "still call the command" do
            mock(@monitor).help.twice
            @monitor.parse_command('h')
            @monitor.parse_command('?')
          end
        end
      end
    end

    context "operations" do
      context "#breakpoint" do
        context "no address" do
          should "print out the breakpoints, sorted by address" do
            bp = Antiquitas::Monitor::Breakpoint.new(0x0080)
            bp2 = Antiquitas::Monitor::Breakpoint.new(0x0040)
            mock(@monitor).puts(bp)
            mock(@monitor).puts(bp2)
            @monitor.breakpoints << bp
            @monitor.breakpoints << bp2
            @monitor.breakpoint
          end
        end

        context "with address" do
          setup do
            @address = 0x69
          end

          context "no current breakpoint with address" do
            should "create a new breakpoint with the address and add it to the list" do
              @monitor.breakpoint(:address => @address)
              assert_equal 1, @monitor.breakpoints.length
              assert_equal @address, @monitor.breakpoints.first.address
            end
          end

          context "current breakpoint with address, no condition" do
            setup do
              @monitor.breakpoint(:address => @address)
            end

            context "breakpoint enabled" do
              should "disable the breakpoint, but not remove it" do
                assert_equal true, @monitor.breakpoints.first.enabled
                @monitor.breakpoint(:address => @address)
                assert_equal 1, @monitor.breakpoints.length
                assert_equal @address, @monitor.breakpoints.first.address
                assert !@monitor.breakpoints.first.enabled
              end
            end

            context "breakpoint disabled" do
              setup do
                @monitor.breakpoints.first.enabled = false
              end

              should "enable the breakpoint" do
                @monitor.breakpoint(:address => @address)
                assert_equal 1, @monitor.breakpoints.length
                assert_equal @address, @monitor.breakpoints.first.address
                assert @monitor.breakpoints.first.enabled
              end
            end
          end

          context "current breakpoint with address and condition" do
            setup do
              @monitor.breakpoint(:address => @address, :condition => "@flag[:Z] == 1")
            end

            context "breakpoint enabled" do
              should "disable the breakpoint, but not remove it" do
                assert_equal true, @monitor.breakpoints.first.enabled
                @monitor.breakpoint(:address => @address)
                assert_equal 1, @monitor.breakpoints.length
                assert_equal @address, @monitor.breakpoints.first.address
                assert !@monitor.breakpoints.first.enabled
              end
            end

            context "breakpoint disabled" do
              setup do
                @monitor.breakpoints.first.enabled = false
              end

              should "enable the breakpoint" do
                @monitor.breakpoint(:address => @address)
                assert_equal 1, @monitor.breakpoints.length
                assert_equal @address, @monitor.breakpoints.first.address
                assert @monitor.breakpoints.first.enabled
              end
            end

          end
        end

        context "with address and condition" do
          setup do
            @address = 0x69
            @condition = "@foo = bar"
          end

          context "no current breakpoint with address" do
            should "create a new breakpoint with the address and condition and add it to the list" do
              @monitor.breakpoint(:address => @address, :condition => @condition)
              assert_equal 1, @monitor.breakpoints.length
              assert_equal @address, @monitor.breakpoints.first.address
              assert_equal @condition, @monitor.breakpoints.first.condition
            end
          end

          context "current breakpoint with address, no condition" do
            setup do
              @monitor.breakpoint(:address => @address)
              @monitor.breakpoint(:address => @address, :condition => @condition)
            end

            should "set the condition on the breakpoint to the passed value" do
              assert_equal @condition, @monitor.breakpoints.first.condition
            end

            should "not change the breakpoint's enabled status" do
              assert @monitor.breakpoints.first.enabled
            end
          end

          context "current breakpoint with address and different condition" do
            setup do
              @monitor.breakpoint(:address => @address, :condition => "foo == bar")
              @monitor.breakpoint(:address => @address, :condition => @condition)
            end

            should "set the condition on the breakpoint to the passed value" do
              assert_equal @condition, @monitor.breakpoints.first.condition
            end

            should "not change the breakpoint's enabled status" do
              assert @monitor.breakpoints.first.enabled
            end
          end

          context "current breakpoint with address and same condition" do
            setup do
              @monitor.breakpoint(:address => @address, :condition => @condition)
            end

            context "breakpoint enabled" do
              setup do
                @monitor.breakpoints.first.enabled = true
                @monitor.breakpoint(:address => @address, :condition => @condition)
              end

              should "disable the breakpoint" do
                assert !@monitor.breakpoints.first.enabled
              end
            end

            context "breakpoint disabled" do
              setup do
                @monitor.breakpoints.first.enabled = false
                @monitor.breakpoint(:address => @address, :condition => @condition)
              end

              should "enable the breakpoint" do
                assert @monitor.breakpoints.first.enabled
              end
            end
          end
        end
      end
    end
  end
end
