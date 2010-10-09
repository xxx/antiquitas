module Antiquitas
  class Monitor
    class Trappoint
      include Comparable

      attr_accessor :trap_type, :trap_location_type, :trap_location, :enabled
      
      def initialize(trap_type, trap_location_type, trap_location, enabled = true)
        @trap_type = trap_type
        @trap_location = trap_location
        @trap_location_type = trap_location_type
        @enabled = enabled
      end
      
      def <=>(other)
        @trap_type <=> other.trap_type || @trap_location_type <=> other.trap_location_type || @trap_location <=> other.trap_location
      end
    end
  end
end