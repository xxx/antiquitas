module Antiquitas
  class Monitor
    class Breakpoint
      include Comparable

      attr_accessor :address, :condition, :enabled
      
      def initialize(address = nil, condition = nil, enabled = true)
        self.address = address
        self.condition = condition
        self.enabled = enabled
      end
      
      def <=>(other)
        address <=> other.address
      end
    end
  end
end