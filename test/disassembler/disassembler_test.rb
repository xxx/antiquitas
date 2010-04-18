require File.join(File.dirname(__FILE__), '..', 'test_helper')

class DisassemblerTest < Test::Unit::TestCase
  context "use with 6502 CPU" do
    should "inject itself into an existing instance" do
      @cpu = Cpu6502.new
      Antiquitas::Disassembler.inject_into(@cpu)
      assert @cpu.respond_to?(:disassemble)
    end

    should "not inject itself info an instance that already can disassemble" do
      @cpu = Cpu6502.new
      def @cpu.disassemble(foo)
        'foobar'
      end
      Antiquitas::Disassembler.inject_into(@cpu)
      assert_equal 'foobar', @cpu.disassemble(0x69)
    end

    should "create a new disassemblable instance" do
      @cpu = Antiquitas::Disassembler.create_disassemblable_instance_of(Cpu6502)
      assert @cpu.respond_to?(:disassemble)
    end

    context "op disassembly" do
      setup do
        @cpu = Antiquitas::Disassembler.create_disassemblable_instance_of(Cpu6502)
      end
      
      should_disassemble(0x69, 'ADC #$12')
      should_disassemble(0x65, 'ADC $12')
      should_disassemble(0x75, 'ADC $12,X')
      should_disassemble(0x6D, 'ADC $1234')
      should_disassemble(0x7D, 'ADC $1234,X')
      should_disassemble(0x79, 'ADC $1234,Y')
      should_disassemble(0x61, 'ADC ($12,X)')
      should_disassemble(0x71, 'ADC ($12),Y')

      should_disassemble(0x29, 'AND #$12')
      should_disassemble(0x25, 'AND $12')
      should_disassemble(0x35, 'AND $12,X')
      should_disassemble(0x2D, 'AND $1234')
      should_disassemble(0x3D, 'AND $1234,X')
      should_disassemble(0x39, 'AND $1234,Y')
      should_disassemble(0x21, 'AND ($12,X)')
      should_disassemble(0x31, 'AND ($12),Y')

      should_disassemble(0x0A, 'ASL A')
      should_disassemble(0x06, 'ASL $12')
      should_disassemble(0x16, 'ASL $12,X')
      should_disassemble(0x0E, 'ASL $1234')
      should_disassemble(0x1E, 'ASL $1234,X')

      should_disassemble(0x90, 'BCC $12')

      should_disassemble(0xB0, 'BCS $12')

      should_disassemble(0xF0, 'BEQ $12')

      should_disassemble(0x24, 'BIT $12')
      should_disassemble(0x2C, 'BIT $1234')

      should_disassemble(0x30, 'BMI $12')

      should_disassemble(0xD0, 'BNE $12')

      should_disassemble(0x10, 'BPL $12')

      should_disassemble(0x00, 'BRK')

      should_disassemble(0x50, 'BVC $12')

      should_disassemble(0x70, 'BVS $12')

      should_disassemble(0x18, 'CLC')

      should_disassemble(0xD8, 'CLD')

      should_disassemble(0x58, 'CLI')

      should_disassemble(0xB8, 'CLV')

      should_disassemble(0xC9, 'CMP #$12')
      should_disassemble(0xC5, 'CMP $12')
      should_disassemble(0xD5, 'CMP $12,X')
      should_disassemble(0xCD, 'CMP $1234')
      should_disassemble(0xDD, 'CMP $1234,X')
      should_disassemble(0xD9, 'CMP $1234,Y')
      should_disassemble(0xC1, 'CMP ($12,X)')
      should_disassemble(0xD1, 'CMP ($12),Y')

      should_disassemble(0xE0, 'CPX #$12')
      should_disassemble(0xE4, 'CPX $12')
      should_disassemble(0xEC, 'CPX $1234')

      should_disassemble(0xC0, 'CPY #$12')
      should_disassemble(0xC4, 'CPY $12')
      should_disassemble(0xCC, 'CPY $1234')

      should_disassemble(0xC6, 'DEC $12')
      should_disassemble(0xD6, 'DEC $12,X')
      should_disassemble(0xCE, 'DEC $1234')
      should_disassemble(0xDE, 'DEC $1234,X')

      should_disassemble(0xCA, 'DEX')

      should_disassemble(0x88, 'DEY')

      should_disassemble(0x49, 'EOR #$12')
      should_disassemble(0x45, 'EOR $12')
      should_disassemble(0x55, 'EOR $12,X')
      should_disassemble(0x4D, 'EOR $1234')
      should_disassemble(0x5D, 'EOR $1234,X')
      should_disassemble(0x59, 'EOR $1234,Y')
      should_disassemble(0x41, 'EOR ($12,X)')
      should_disassemble(0x51, 'EOR ($12),Y')

      should_disassemble(0xE6, 'INC $12')
      should_disassemble(0xF6, 'INC $12,X')
      should_disassemble(0xEE, 'INC $1234')
      should_disassemble(0xFE, 'INC $1234,X')

      should_disassemble(0xE8, 'INX')

      should_disassemble(0xC8, 'INY')

      should_disassemble(0x4C, 'JMP $1234')
      should_disassemble(0x6C, 'JMP ($1234)')

      should_disassemble(0x20, 'JSR $1234')

      should_disassemble(0xA9, 'LDA #$12')
      should_disassemble(0xA5, 'LDA $12')
      should_disassemble(0xB5, 'LDA $12,X')
      should_disassemble(0xAD, 'LDA $1234')
      should_disassemble(0xBD, 'LDA $1234,X')
      should_disassemble(0xB9, 'LDA $1234,Y')
      should_disassemble(0xA1, 'LDA ($12,X)')
      should_disassemble(0xB1, 'LDA ($12),Y')

      should_disassemble(0xA2, 'LDX #$12')
      should_disassemble(0xA6, 'LDX $12')
      should_disassemble(0xB6, 'LDX $12,Y')
      should_disassemble(0xAE, 'LDX $1234')
      should_disassemble(0xBE, 'LDX $1234,Y')
      
      should_disassemble(0xA0, 'LDY #$12')
      should_disassemble(0xA4, 'LDY $12')
      should_disassemble(0xB4, 'LDY $12,X')
      should_disassemble(0xAC, 'LDY $1234')
      should_disassemble(0xBC, 'LDY $1234,X')

      should_disassemble(0x4A, 'LSR A')
      should_disassemble(0x46, 'LSR $12')
      should_disassemble(0x56, 'LSR $12,X')
      should_disassemble(0x4E, 'LSR $1234')
      should_disassemble(0x5E, 'LSR $1234,X')

      should_disassemble(0xEA, 'NOP')

      should_disassemble(0x09, 'ORA #$12')
      should_disassemble(0x05, 'ORA $12')
      should_disassemble(0x15, 'ORA $12,X')
      should_disassemble(0x0D, 'ORA $1234')
      should_disassemble(0x1D, 'ORA $1234,X')
      should_disassemble(0x19, 'ORA $1234,Y')
      should_disassemble(0x01, 'ORA ($12,X)')
      should_disassemble(0x11, 'ORA ($12),Y')

      should_disassemble(0x48, 'PHA')

      should_disassemble(0x08, 'PHP')

      should_disassemble(0x68, 'PLA')

      should_disassemble(0x28, 'PLP')

      should_disassemble(0x2A, 'ROL A')
      should_disassemble(0x26, 'ROL $12')
      should_disassemble(0x36, 'ROL $12,X')
      should_disassemble(0x2E, 'ROL $1234')
      should_disassemble(0x3E, 'ROL $1234,X')

      should_disassemble(0x6A, 'ROR A')
      should_disassemble(0x66, 'ROR $12')
      should_disassemble(0x76, 'ROR $12,X')
      should_disassemble(0x6E, 'ROR $1234')
      should_disassemble(0x7E, 'ROR $1234,X')
      
      should_disassemble(0x40, 'RTI')

      should_disassemble(0x60, 'RTS')
      
      should_disassemble(0xE9, 'SBC #$12')
      should_disassemble(0xE5, 'SBC $12')
      should_disassemble(0xF5, 'SBC $12,X')
      should_disassemble(0xED, 'SBC $1234')
      should_disassemble(0xFD, 'SBC $1234,X')
      should_disassemble(0xF9, 'SBC $1234,Y')
      should_disassemble(0xE1, 'SBC ($12,X)')
      should_disassemble(0xF1, 'SBC ($12),Y')

      should_disassemble(0x38, 'SEC')

      should_disassemble(0xF8, 'SED')

      should_disassemble(0x78, 'SEI')

      should_disassemble(0x85, 'STA $12')
      should_disassemble(0x95, 'STA $12,X')
      should_disassemble(0x8D, 'STA $1234')
      should_disassemble(0x9D, 'STA $1234,X')
      should_disassemble(0x99, 'STA $1234,Y')
      should_disassemble(0x81, 'STA ($12,X)')
      should_disassemble(0x91, 'STA ($12),Y')

      should_disassemble(0x86, 'STX $12')
      should_disassemble(0x96, 'STX $12,Y')
      should_disassemble(0x8E, 'STX $1234')

      should_disassemble(0x84, 'STY $12')
      should_disassemble(0x94, 'STY $12,X')
      should_disassemble(0x8C, 'STY $1234')

      should_disassemble(0xAA, 'TAX')

      should_disassemble(0xA8, 'TAY')

      should_disassemble(0xBA, 'TSX')

      should_disassemble(0x8A, 'TXA')

      should_disassemble(0x9A, 'TXS')

      should_disassemble(0x98, 'TYA')
    end
  end
end
