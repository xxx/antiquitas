module Antiquitas
  class Monitor
    class Watchpoint
      include Comparable

      attr_accessor :watch_type, :watch_location, :enabled
      
      def initialize(watch_type, watch_location, enabled = true)
        @watch_type = watch_type
        @watch_location = watch_location
        @enabled = enabled
      end
      
      def <=>(other)
        @address <=> other.address
      end
    end
  end
end