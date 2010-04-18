require 'optparse'
require 'ostruct'

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

        opts.on("--cpu CPU", ['6502'], "CPU type to open in the monitor.",
                "Implies -d. Mutually exclusive of --system.",
                "  (6502)") do |cpu|
          instance.debug = true
          instance.cpu = cpu
          instance.system = nil
        end

        opts.on("--system SYSTEM", ["vcs"], "System type to open in the monitor.",
                "Implies -d. Mutually exclusive of --cpu.",
                "  (vcs)") do |system|
          instance.debug = true
          instance.system = system
          instance.cpu = nil
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

      begin
        opts.parse! argv
      rescue OptionParser::InvalidArgument, OptionParser::MissingArgument => e
        puts opts
        puts ""
        puts "Error: #{e}"
        exit
      end
      instance
    end
  end
end

