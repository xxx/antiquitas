require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class MonitorWatchpointOperationTest < Test::Unit::TestCase

  def self.should_create_or_toggle(type, location)
    context "not watching that #{type}" do
      should "add a new watchpoint for the passed #{type}" do
        @monitor.watchpoint(type => location)
        assert_equal 1, @monitor.watchpoints.length
        assert_equal type, @monitor.watchpoints.first.watch_type
        assert_equal location, @monitor.watchpoints.first.watch_location
      end
    end

    context "watching that #{type}" do
      setup do
        @monitor.watchpoint(type => location)
      end

      context "watchpoint enabled" do
        should "disable the watchpoint for the passed #{type}" do
          @monitor.watchpoint(type => location)
          assert_equal 1, @monitor.watchpoints.length
          assert_equal type, @monitor.watchpoints.first.watch_type
          assert_equal location, @monitor.watchpoints.first.watch_location
          assert !@monitor.watchpoints.first.enabled
        end
      end

      context "watchpoint disabled" do
        setup do
          @monitor.watchpoints.first.enabled = false
        end

        should "enable the watchpoint for the passed #{type}" do
          @monitor.watchpoint(type => location)
          assert_equal 1, @monitor.watchpoints.length
          assert_equal type, @monitor.watchpoints.first.watch_type
          assert_equal location, @monitor.watchpoints.first.watch_location
          assert @monitor.watchpoints.first.enabled
        end
      end
    end
  end
  
  context "#watchpoint" do
    setup do
      @monitor = Antiquitas::Monitor.new
    end
    
    context "no args" do
      should "print out the watchpoints, sorted by order added" do
        wp = Antiquitas::Monitor::Watchpoint.new(:address, 0x0080)
        wp2 = Antiquitas::Monitor::Watchpoint.new(:flag, :Z)
        mock(@monitor).puts(wp)
        mock(@monitor).puts(wp2)
        @monitor.watchpoints << wp
        @monitor.watchpoints << wp2
        @monitor.watchpoint
      end
    end

    context "with memory address" do
      should_create_or_toggle(:address, 0x69)
    end

    context "with flag" do
      should_create_or_toggle(:flag, :Z)
    end

    context "with register" do
      should_create_or_toggle(:register, :A)
    end
  end
end
