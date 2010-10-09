require File.expand_path('../../test_helper', File.dirname(__FILE__))

class MonitorTrapOperationTest < Test::Unit::TestCase
  context "#trap" do
    setup do
      @monitor = Antiquitas::Monitor.new
    end

    context "no args" do
      should "print out the trappoints, sorted" do
        tp = Antiquitas::Monitor::Trappoint.new(:read, :address, 0x0080)
        tp2 = Antiquitas::Monitor::Trappoint.new(:write, :flag, :Z)
        mock(@monitor).puts(tp)
        mock(@monitor).puts(tp2)
        @monitor.trappoints << tp
        @monitor.trappoints << tp2
        @monitor.trap
      end
    end

    context "illegal options" do
      context "existing trap point at location" do
        should "not change the point's type" do
          @monitor.trap(:type => :read, :address => 0x69)
          assert_equal :read, @monitor.trappoints.last.trap_type
          @monitor.trap(:type => :asdf, :address => 0x69)
          assert_equal :read, @monitor.trappoints.last.trap_type
        end
      end

      context "no existing trap point at passed location" do
        should "not add a new trap point" do
          len = @monitor.trappoints.length
          @monitor.trap(:type => :aldjkf, :address => 0x69)
          assert_equal len, @monitor.trappoints.length
        end
      end

      context "bad location type" do
        should "not add a new trap point" do
          len = @monitor.trappoints.length
          @monitor.trap(:type => :read, :asd => 0x69)
          assert_equal len, @monitor.trappoints.length
        end
      end
    end

    context "legal options" do
      context "existing trap point at passed location" do
        should "set the point's type to the passed type" do
          @monitor.trap(:type => :read, :address => 0x69)
          assert_equal :read, @monitor.trappoints.last.trap_type
          @monitor.trap(:type => :readwrite, :address => 0x69)
          assert_equal :readwrite, @monitor.trappoints.last.trap_type
        end

        should "not create a new trap point" do
          @monitor.trap(:type => :read, :address => 0x69)
          len = @monitor.trappoints.length
          @monitor.trap(:type => :readwrite, :address => 0x69)
          assert_equal len, @monitor.trappoints.length
        end
      end

      context "nonexistent trap point at the passed location" do
        should "create a new trap point with the correct info" do
          len = @monitor.trappoints.length
          @monitor.trap(:type => :write, :flag => :Z)
          assert_equal len + 1, @monitor.trappoints.length

          tp = @monitor.trappoints.last
          assert_equal :write, tp.trap_type
          assert_equal :flag, tp.trap_location_type
          assert_equal :Z, tp.trap_location
        end
      end
    end
  end
end
