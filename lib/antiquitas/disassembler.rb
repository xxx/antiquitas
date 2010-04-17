module Antiquitas
  module Disassembler
    def self.inject_into(instance)
      return if instance.respond_to? :disassemble

      # need to pass access to this private method into the
      # injected method.
      dressed_address = method(:dressed_address)

      imeta = class << instance; self; end;
      imeta.send :define_method, :disassemble do |op, *args|
        op_info = opcodes[op]
        str = op_info[0] # op_info[0] is mnemonic
        address = case args.length
          when 2
            ((args.first << 8) | args.last)
          when 1
            args.first
          else
            nil
        end

        address = address ? "$%x" % address : ""

        # op_info[1] is address mode
        address = dressed_address.call(address, op_info[1])

        # BRK is broken and 2 bytes are read.
        # we only want to output 'BRK'
        # this will need to be broken into a separate module
        # if more cpu types are tested with this suite.
        address = '' if str == 'BRK'
        
        ("%3s %s" % [str, address]).strip
      end
    end

    def self.create_disassemblable_instance_of(klass)
      instance = klass.new
      inject_into(instance)
      instance
    end

    private

    def self.dressed_address(address, address_mode)
      case address_mode
        when :immediate
          "##{address}"

        when :absolutex
          "#{address},X"
        when :zeropagex
          "#{address},X"

        when :absolutey
          "#{address},Y"
        when :zeropagey
          "#{address},Y"

        when :indirect
          "(#{address})"

        when :indirectx
          "(#{address},X)"

        when :indirecty
          "(#{address}),Y"

        else
          "#{address}"
      end
    end
  end
end