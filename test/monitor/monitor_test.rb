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

      end

      context "step/next" do

      end

      context "backtrace" do
        
      end

      context "dump" do
        
      end

      context "disassemble" do

      end

      context "label" do
        
      end
    end

    context "operations" do
      
    end
  end
end
