module Antiquitas
  class Monitor
    attr_reader :hardware, :breakpoints, :watchpoints, :trappoints

    def initialize
      @breakpoints = []
      @watchpoints = []
      @trappoints = []
    end

    def monitor(hardware)
      @hardware = hardware.is_a?(Class) ? hardware.new : hardware
      Disassembler.inject_into @hardware
      self
    end

    def run
    end
    
    def parse_command(command)
      opts = {}
      case command.strip
        when /\Ab(?:p|reak(?:point)?)(?:\s+\$([0-9a-fA-F]+))?(?:\s+(.+))?\Z/i
          opts[:address] = $1.hex if $1
          opts[:condition] = $2 if $2
          breakpoint opts

        when /\Awatch(?:\s+(\$[0-9a-fA-F]+|f(?:lag)?:\w+|r(?:eg(?:ister)?)?:\w+))?(?:\s+(.+))?\Z/i
          if $1
            if $1[0, 1] == '$'
              opts[:address] = $1[1..-1].hex
            elsif $1[0, 1] == 'f'
              opts[:flag] = $1.gsub(/^f(?:lag)?:/, '').to_sym
            elsif $1[0, 3] == 'reg'
              opts[:register] = $1.gsub(/^reg(?:ister)?:/, '').to_sym
            end
          end

          opts[:condition] = $2 if $2
          watchpoint(opts)

        when /\Atrap(?:\s+(r(?:ead)?|w(?:rite)?|rw|readwrite))?(?:\s+(\$[0-9a-fA-F]+|flag:\w+|reg(?:ister)?:\w+))?\Z/i
          if $1
            opts[:type] = case $1.downcase
              when 'r'
                :read
              when 'read'
                :read
              when 'w'
                :write
              when 'write'
                :write
              else
                :readwrite
            end
          end

          if $2
            if $2[0, 1] == '$'
              opts[:address] = $2[1..-1].hex
            elsif $2[0, 4] == 'flag'
              opts[:flag] = $2.gsub(/^flag:/, '').to_sym
            elsif $2[0, 3] == 'reg'
              opts[:register] = $2.gsub(/^reg(?:ister)?:/, '').to_sym
            end
          end
          trap(opts)

        when /\Acont(?:inue)?\Z/i
          continue

        when /\As(?:tep)?|n(?:ext)?\Z/i
          step

        when /\Abt|backtrace\Z/i
          backtrace

        when /\Ad(?:ump)?\Z/i
          dump

        when /\Adis(?:assemble)?(?:\s+(\$[0-9a-fA-F]+|\d+|\$[0-9a-fA-F]+\s+\d+))?\Z/i
          if $1
            match = $1
            if match[0, 1] == '$'
              if match.include? ' ' # address and bytes
                address, bytes = match.split(/\s+/)
                opts[:address] = address[1..-1].hex
                opts[:bytes] = bytes.to_i
              else # just address
                opts[:address] = match[1..-1].hex
              end
            else # just bytes
              opts[:bytes] = match.to_i
            end
          end

          disassemble(opts)

        when /\Alabel(?:\s+(\$[0-9a-fA-F]+|\$[0-9a-fA-F]+\s+[\w\s]+))?\Z/i
          if $1
            match = $1
            if match.include? ' ' # address and name
              address, opts[:name] = match.split(/\s+/, 2)
              opts[:address] = address[1..-1].hex
            else # just address
              opts[:address] = match[1..-1].hex
            end
          end

          label(opts)

        when /\A(?:h(?:elp)?|\?)(?:\s+(.+))?\Z/i
          help
      end
    end
    
    def method_missing(method, *args, &block)
      @hardware.send(method, *args, &block)
    end

    def breakpoint(opts = {})
      if opts[:address]
        bp = @breakpoints.detect { |brk| opts[:address] == brk.address }
        if bp
          if opts[:condition]
            if bp.condition == opts[:condition]
              bp.enabled = !bp.enabled
            else
              bp.condition = opts[:condition]
            end
          else
            bp.enabled = !bp.enabled
          end
        else
          @breakpoints << Breakpoint.new(opts[:address], opts[:condition])
        end
      else
        @breakpoints.sort.each do |bp|
          puts bp
        end
      end
    end

    def watchpoint(opts = {})
      if opts.empty?
        @watchpoints.each do |wp|
          puts wp
        end
      else
        [:address, :flag, :register].each do |watch_type|
          if opts[watch_type]
            wp = @watchpoints.detect { |w| w.watch_type == watch_type and w.watch_location == opts[watch_type] }
            if wp
              wp.enabled = !wp.enabled
            else
              @watchpoints << Watchpoint.new(watch_type, opts[watch_type])
            end
            
            break
          end
        end
      end
    end

    def trap(opts = {})
      if opts.empty?
        @trappoints.each do |tp|
          puts tp
        end
      else
        return unless [:read, :write, :readwrite, :r, :w, :rw].include?(trap_type = opts.delete(:type))

        trap_location_type = opts.keys.detect { |k| [:address, :register, :flag].include?(k) }
        return unless trap_location_type
        trap_location = opts[trap_location_type]
        tp = @trappoints.detect { |tp| tp.trap_location_type == trap_location_type && tp.trap_location == trap_location }
        if tp
          tp.trap_type = trap_type
        else
          @trappoints << Trappoint.new(trap_type, trap_location_type, trap_location)
        end
      end

    end

    def continue
    end

    def step
    end

    def backtrace
    end

    def dump
    end

    def disassemble(opts = {})
    end

    def label(opts = {})
    end

    def help(opts = {})
      
    end
  end
end