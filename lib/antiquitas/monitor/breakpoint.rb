module Antiquitas
  class Monitor
    Breakpoint = Struct.new("AntiquitasMonitorBreakpoint", :address, :condition, :enabled) do
      include Comparable

      def initialize(*args)
        super *args
        self.enabled = true unless args.length == 3 # i.e. enabled value passed-in
      end
      
      def <=>(other)
        address <=> other.address
      end
    end
  end
end