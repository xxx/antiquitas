module Antiquitas
  class Monitor
    attr_reader :hardware, :breakpoints

    def initialize
      @breakpoints = []
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
        when /^b(?:p|reak(?:point)?)(?:\s+\$([0-9a-fA-F]+))?(?:\s+(.+))?$/i
          opts[:address] = $1.hex if $1
          opts[:condition] = $2 if $2
          breakpoint opts

        when /^watch(?:\s+(\$[0-9a-fA-F]+|f(?:lag)?:\w+|r(?:eg(?:ister)?)?:\w+))?(?:\s+(.+))?$/i
          if $1
            if $1[0, 1] == '$'
              opts[:address] = $1[1..-1].hex
            elsif $1[0, 4] == 'flag'
              opts[:flag] = $1.gsub(/^flag:/, '').to_sym
            elsif $1[0, 3] == 'reg'
              opts[:register] = $1.gsub(/^reg(?:ister)?:/, '').to_sym
            end
          end

          opts[:condition] = $2 if $2
          watchpoint(opts)

        when /^trap(?:\s+(r(?:ead)?|w(?:rite)?|rw|readwrite))?(?:\s+(\$[0-9a-fA-F]+|flag:\w+|reg(?:ister)?:\w+))?$/i
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

        when /^(?:cont(?:inue)?)$/i
          continue

        when /^(?:s(?:tep)?|n(?:ext)?)$/i
          step

        when /bt|backtrace/i
          backtrace

        when /^d(?:ump)?$/i
          dump

        when /^dis(?:assemble)?(?:\s+(\$[0-9a-fA-F]+|\d+|\$[0-9a-fA-F]+\s+\d+))?$/i
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

        when /^label(?:\s+(\$[0-9a-fA-F]+|\$[0-9a-fA-F]+\s+[\w\s]+))?$/i
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

      end
    end
    
    def method_missing(method, *args, &block)
      @hardware.send(method, *args, &block)
    end

    private

    def breakpoint(opts = {})
    end

    def watchpoint(opts = {})
    end

    def trap(opts = {})
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

  end
end