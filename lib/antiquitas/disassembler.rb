module Antiquitas
  module Disassembler
    def self.inject_into(instance)
      return if instance.respond_to? :disassemble

      # need to pass access to this private method into the
      # injected method.
      dressed_address = method(:dressed_address)

      imeta = class << instance; self; end;

      # pass MSB as first arg to disassemble if multiple args.
      # keeping MSB as first on all endianness types to
      # keep the internal API consistent with itself.
      imeta.send :define_method, :disassemble do |op, *args|
        op_info = opcodes[op]
        mnemonic = op_info[0]
        address = case args.length
          when 2
            ((args.first << 8) | args.last)
          when 1
            args.first
          else
            nil
        end

        # op_info[1] is address mode
        address = dressed_address.call(address, op_info[1])

        # BRK is broken and 2 bytes are read.
        # we only want to output 'BRK'
        # this will need to be broken into a separate module
        # if more cpu types are tested with this suite.
        address = '' if mnemonic == 'BRK'
        
        ("%3s %s" % [mnemonic, address]).strip
      end
    end

    def self.create_disassemblable_instance_of(klass)
      instance = klass.new
      inject_into(instance)
      instance
    end

    private

    def self.dressed_address(address, address_mode)

      address = address ? "$%02X" % address : ""
      
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

        when :accumulator
          "A"
        
        else
          "#{address}"
      end
    end
  end
end