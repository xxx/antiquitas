module Antiquitas
  class Options < OpenStruct
    def self.parse(argv)
      instance = self.new

      opts = OptionParser.new do |opts|
        opts.banner = "Usage: antiquitas.rb [OPTIONS] rom"
        opts.separator ""
        opts.separator "Accepted options:"

        opts.on("-d", "--[no-]debug", "-m", "--[no-]monitor", "run in debugger") do |debug|
          instance.debug = debug
        end

        opts.on("-w", "--[no-]wall", "Run in wall mode") do |wall|
          instance.wall_mode = wall
        end

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end

        opts.on_tail("--version", "Show version") do
          puts "$%02X" % 0x00
          exit
        end

      end

      opts.parse! argv
      instance
    end
  end
end

