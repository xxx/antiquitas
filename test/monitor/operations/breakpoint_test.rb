require File.expand_path('../../test_helper', File.dirname(__FILE__))

class MonitorBreakpointOperationTest < Test::Unit::TestCase
  context "#breakpoint" do
    setup do
      @monitor = Antiquitas::Monitor.new
    end
    
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
