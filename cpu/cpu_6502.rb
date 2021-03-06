class Cpu6502
  attr_accessor :debug, :register, :flag, :ram, :pc, :cycles
  attr_reader :imagesize

  class << self
    attr_reader :opcodes, :to_bin, :to_bcd
  end

  @opcodes = {
    # mnemonic, addressing mode, bytes, cycles, total possible extra cycles
    0x69 => [ "ADC", :immediate,   2, 2 ],
    0x65 => [ "ADC", :zeropage,    2, 3 ],
    0x75 => [ "ADC", :zeropagex,   2, 4 ],
    0x6D => [ "ADC", :absolute,    3, 4 ],
    0x7D => [ "ADC", :absolutex,   3, 4, 1 ],
    0x79 => [ "ADC", :absolutey,   3, 4, 1 ],
    0x61 => [ "ADC", :indirectx,   2, 6 ],
    0x71 => [ "ADC", :indirecty,   2, 5, 1 ],

    0x29 => [ "AND", :immediate,   2, 2 ],
    0x25 => [ "AND", :zeropage,    2, 3 ],
    0x35 => [ "AND", :zeropagex,   2, 4 ],
    0x2D => [ "AND", :absolute,    3, 4 ],
    0x3D => [ "AND", :absolutex,   3, 4, 1 ],
    0x39 => [ "AND", :absolutey,   3, 4, 1 ],
    0x21 => [ "AND", :indirectx,   2, 6 ],
    0x31 => [ "AND", :indirecty,   2, 5, 1 ],

    0x0A => [ "ASL", :accumulator, 1, 2 ],
    0x06 => [ "ASL", :zeropage,    2, 5 ],
    0x16 => [ "ASL", :zeropagex,   2, 6 ],
    0x0E => [ "ASL", :absolute,    3, 6 ],
    0x1E => [ "ASL", :absolutex,   3, 7 ],

    0x90 => [ "BCC", :relative,    2, 2, 2 ],

    0xB0 => [ "BCS", :relative,    2, 2, 2 ],

    0xF0 => [ "BEQ", :relative,    2, 2, 2 ],

    0x24 => [ "BIT", :zeropage,    2, 3 ],
    0x2C => [ "BIT", :absolute,    3, 4 ],

    0x30 => [ "BMI", :relative,    2, 2, 2 ],

    0xD0 => [ "BNE", :relative,    2, 2, 2 ],

    0x10 => [ "BPL", :relative,    2, 2, 2 ],

    0x00 => [ "BRK", :implied,     2, 7 ],
    
    0x50 => [ "BVC", :relative,    2, 2, 2 ],

    0x70 => [ "BVS", :relative,    2, 2, 2 ],

    0x18 => [ "CLC", :implied,     1, 2 ],

    0xD8 => [ "CLD", :implied,     1, 2 ],

    0x58 => [ "CLI", :implied,     1, 2 ],

    0xB8 => [ "CLV", :implied,     1, 2 ],

    0xC9 => [ "CMP", :immediate,   2, 2 ],
    0xC5 => [ "CMP", :zeropage,    2, 3 ],
    0xD5 => [ "CMP", :zeropagex,   2, 4 ],
    0xCD => [ "CMP", :absolute,    3, 4 ],
    0xDD => [ "CMP", :absolutex,   3, 4, 1 ],
    0xD9 => [ "CMP", :absolutey,   3, 4, 1 ],
    0xC1 => [ "CMP", :indirectx,   2, 6 ],
    0xD1 => [ "CMP", :indirecty,   2, 5, 1 ],

    0xE0 => [ "CPX", :immediate,   2, 2 ],
    0xE4 => [ "CPX", :zeropage,    2, 3 ],
    0xEC => [ "CPX", :absolute,    3, 4 ],

    0xC0 => [ "CPY", :immediate,   2, 2 ],
    0xC4 => [ "CPY", :zeropage,    2, 3 ],
    0xCC => [ "CPY", :absolute,    3, 4 ],

    0xC6 => [ "DEC", :zeropage,    2, 5 ],
    0xD6 => [ "DEC", :zeropagex,   2, 6 ],
    0xCE => [ "DEC", :absolute,    3, 6 ],
    0xDE => [ "DEC", :absolutex,   3, 7 ],

    0xCA => [ "DEX", :implied,     1, 2 ],

    0x88 => [ "DEY", :implied,     1, 2 ],

    0x49 => [ "EOR", :immediate,   2, 2 ],
    0x45 => [ "EOR", :zeropage,    2, 3 ],
    0x55 => [ "EOR", :zeropagex,   2, 4 ],
    0x4D => [ "EOR", :absolute,    3, 4 ],
    0x5D => [ "EOR", :absolutex,   3, 4, 1 ],
    0x59 => [ "EOR", :absolutey,   3, 4, 1 ],
    0x41 => [ "EOR", :indirectx,   2, 6 ],
    0x51 => [ "EOR", :indirecty,   2, 5, 1 ],

    0xE6 => [ "INC", :zeropage,    2, 5 ],
    0xF6 => [ "INC", :zeropagex,   2, 6 ],
    0xEE => [ "INC", :absolute,    3, 6 ],
    0xFE => [ "INC", :absolutex,   3, 7 ],

    0xE8 => [ "INX", :implied,     1, 2 ],

    0xC8 => [ "INY", :implied,     1, 2 ],

    0x4C => [ "JMP", :absolute,    3, 3 ],
    0x6C => [ "JMP", :indirect,    3, 5 ],

    0x20 => [ "JSR", :absolute,    3, 6 ],

    0xA9 => [ "LDA", :immediate,   2, 2 ],
    0xA5 => [ "LDA", :zeropage,    2, 3 ],
    0xB5 => [ "LDA", :zeropagex,   2, 4 ],
    0xAD => [ "LDA", :absolute,    3, 4 ],
    0xBD => [ "LDA", :absolutex,   3, 4, 1 ],
    0xB9 => [ "LDA", :absolutey,   3, 4, 1 ],
    0xA1 => [ "LDA", :indirectx,   2, 6 ],
    0xB1 => [ "LDA", :indirecty,   2, 5, 1 ],

    0xA2 => [ "LDX", :immediate,   2, 2 ],
    0xA6 => [ "LDX", :zeropage,    2, 3 ],
    0xB6 => [ "LDX", :zeropagey,   2, 4 ],
    0xAE => [ "LDX", :absolute,    3, 4 ],
    0xBE => [ "LDX", :absolutey,   3, 4, 1 ],

    0xA0 => [ "LDY", :immediate,   2, 2 ],
    0xA4 => [ "LDY", :zeropage,    2, 3 ],
    0xB4 => [ "LDY", :zeropagex,   2, 4 ],
    0xAC => [ "LDY", :absolute,    3, 4 ],
    0xBC => [ "LDY", :absolutex,   3, 4, 1 ],

    0x4A => [ "LSR", :accumulator, 1, 2 ],
    0x46 => [ "LSR", :zeropage,    2, 5 ],
    0x56 => [ "LSR", :zeropagex,   2, 6 ],
    0x4E => [ "LSR", :absolute,    3, 6 ],
    0x5E => [ "LSR", :absolutex,   3, 7 ],

    0xEA => [ "NOP", :implied,     1, 2 ],

    0x09 => [ "ORA", :immediate,   2, 2 ],
    0x05 => [ "ORA", :zeropage,    2, 3 ],
    0x15 => [ "ORA", :zeropagex,   2, 4 ],
    0x0D => [ "ORA", :absolute,    3, 4 ],
    0x1D => [ "ORA", :absolutex,   3, 4, 1 ],
    0x19 => [ "ORA", :absolutey,   3, 4, 1 ],
    0x01 => [ "ORA", :indirectx,   2, 6 ],
    0x11 => [ "ORA", :indirecty,   2, 5, 1 ],

    0x48 => [ "PHA", :implied,     1, 3 ],

    0x08 => [ "PHP", :implied,     1, 3 ],

    0x68 => [ "PLA", :implied,     1, 4 ],

    0x28 => [ "PLP", :implied,     1, 4 ],

    0x2A => [ "ROL", :accumulator, 1, 2],
    0x26 => [ "ROL", :zeropage,    2, 5],
    0x36 => [ "ROL", :zeropagex,   2, 6],
    0x2E => [ "ROL", :absolute,    3, 6],
    0x3E => [ "ROL", :absolutex,   3, 7],

    0x6A => [ "ROR", :accumulator, 1, 2],
    0x66 => [ "ROR", :zeropage,    2, 5],
    0x76 => [ "ROR", :zeropagex,   2, 6],
    0x6E => [ "ROR", :absolute,    3, 6],
    0x7E => [ "ROR", :absolutex,   3, 7],

    0x40 => [ "RTI", :implied,     1, 6],

    0x60 => [ "RTS", :implied,     1, 6],

    0xE9 => [ "SBC", :immediate,   2, 2 ],
    0xE5 => [ "SBC", :zeropage,    2, 3 ],
    0xF5 => [ "SBC", :zeropagex,   2, 4 ],
    0xED => [ "SBC", :absolute,    3, 4 ],
    0xFD => [ "SBC", :absolutex,   3, 4, 1 ],
    0xF9 => [ "SBC", :absolutey,   3, 4, 1 ],
    0xE1 => [ "SBC", :indirectx,   2, 6 ],
    0xF1 => [ "SBC", :indirecty,   2, 5, 1 ],

    0x38 => [ "SEC", :implied,     1, 2 ],

    0xF8 => [ "SED", :implied,     1, 2 ],

    0x78 => [ "SEI", :implied,     1, 2 ],

    0x85 => [ "STA", :zeropage,    2, 3 ],
    0x95 => [ "STA", :zeropagex,   2, 4 ],
    0x8D => [ "STA", :absolute,    3, 4 ],
    0x9D => [ "STA", :absolutex,   3, 5 ],
    0x99 => [ "STA", :absolutey,   3, 5 ],
    0x81 => [ "STA", :indirectx,   2, 6 ],
    0x91 => [ "STA", :indirecty,   2, 6 ],

    0x86 => [ "STX", :zeropage,    2, 3 ],
    0x96 => [ "STX", :zeropagey,   2, 4 ],
    0x8E => [ "STX", :absolute,    3, 4 ],

    0x84 => [ "STY", :zeropage,    2, 3 ],
    0x94 => [ "STY", :zeropagex,   2, 4 ],
    0x8C => [ "STY", :absolute,    3, 4 ],

    0xAA => [ "TAX", :implied,     1, 2 ],

    0xA8 => [ "TAY", :implied,     1, 2 ],

    0xBA => [ "TSX", :implied,     1, 2 ],

    0x8A => [ "TXA", :implied,     1, 2 ],

    0x9A => [ "TXS", :implied,     1, 2 ],

    0x98 => [ "TYA", :implied,     1, 2 ]

  }

  # tables cribbed from py65. illegal bytes not supported. don't use 'em.
  @to_bin = [
      0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, # 0x00
     10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, # 0x10
     20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, # 0x20
     30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, # 0x30
     40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, # 0x40
     50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, # 0x50
     60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, # 0x60
     70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, # 0x70
     80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, # 0x80
     90, 91, 92, 93, 94, 95, 96, 97, 98, 99                          # 0x90
  ]
  
  @to_bcd = [
    0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,
    0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,
    0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,
    0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,
    0x40,0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,
    0x50,0x51,0x52,0x53,0x54,0x55,0x56,0x57,0x58,0x59,
    0x60,0x61,0x62,0x63,0x64,0x65,0x66,0x67,0x68,0x69,
    0x70,0x71,0x72,0x73,0x74,0x75,0x76,0x77,0x78,0x79,
    0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,
    0x90,0x91,0x92,0x93,0x94,0x95,0x96,0x97,0x98,0x99
  ]

  def initialize
    @debug = false
    @imagesize = 0
    @pc = 0
    @pc_offset = 0
    @ram = Array.new(65536, 0)
    @register = { :A => 0, :X => 0, :Y => 0, :S => 0xFF, :P => 0 }
    # unused flag is always 1, according to the bug lists
    # 'real' bits 7 to 0 are: N V - B D I Z C
    # 'B' really only exists in the context of pushing or pulling
    # the status register from the stack. There is no actual direct way to
    # set or clear the flag in the 6502, and is ALWAYS set to 0 in the status
    # register
    @flag = { :N => 0, :V => 0, :B => 0, :D => 0, :I => 0, :Z => 0, :C => 0}
    @operand = Array.new(2)
    @cycles = 0
  end

  def reset
    @pc = (@ram[0xFFFD] << 8) | @ram[0xFFFC]
    @flag[:I] = 1
  end

  def nmi
    service_interrupt(0xFFFA)
  end

  def irq
    service_interrupt(0xFFFE) if @flag[:I] == 0
  end

  def opcodes
    self.class.opcodes
  end

  def endianness
    :little
  end

  def display_status
    if (@debug)
      printf("PC=%04x SP=%04x A=%02x X=%02x Y=%02x S=%02x C=%d Z=%d\n\n", @pc,@register[:S],@register[:A],@register[:X],@register[:Y],@flag[:N],@flag[:C]?1:0,@flag[:Z])
    end
  end

  def push(oper1)
    @ram[@register[:S] + 0x100] = oper1
    @register[:S] -= 1
  end

  def pull
    @register[:S] += 1
    @ram[@register[:S] + 0x100]
  end

  def set_sign(accumulator)
    @flag[:N] = (accumulator & 0x80) == 0x80 ? 1 : 0
  end

  def set_zero(accumulator)
    @flag[:Z] = (accumulator == 0) ? 1 : 0
  end

  def set_carry(accumulator)
    @flag[:C] = accumulator ? 1 : 0
  end

  def set_overflow(val)
    @flag[:V] = val
  end

  def loadi(filen)
    @prog = File.open(filen, "rb") { |io| io.read }
    @imagesize = @prog.size
  end

  def runop(opcode, oper1 = nil, oper2 = nil)
    op = opcodes[opcode]
    @pc += op[2]
    @cycles += op[3]

    case opcode
      when 0x69 # ADC immediate
        op_adc(oper1)

      when 0x65 # ADC zeropage
        op_adc(@ram[oper1])
      
      when 0x75 # ADC zeropagex
        address = oper1 + @register[:X]
        address -= 0xFF while address > 0xFF 

        op_adc(@ram[address])

      when 0x6D # ADC absolute
        op_adc(@ram[(oper1 << 8) | oper2])

      when 0x7D # ADC absolutex
        sixteen = to_16_bit(oper1, oper2)
        add_cycle_if_crossing_boundary(sixteen, @register[:X])
        address = (sixteen + @register[:X])
        op_adc(@ram[address])

      when 0x79 # ADC absolutey
        sixteen = to_16_bit(oper1, oper2)
        add_cycle_if_crossing_boundary(sixteen, @register[:Y])
        address = (sixteen + @register[:Y])
        op_adc(@ram[address])

      when 0x61 # ADC indirectx
        op_adc(@ram[indirect_x_address(oper1)])

      when 0x71 # ADC indirecty
        add_cycle_if_crossing_boundary(oper1, @register[:Y])
        op_adc(@ram[indirect_y_address(oper1)])

      when 0x29 # AND immediate
        @register[:A] &= oper1
        set_sz(@register[:A])

      when 0x25 # AND zeropage
        @register[:A] &= @ram[oper1]
        set_sz(@register[:A])

      when 0x35 # AND zeropagex
        address = oper1 + @register[:X]
        address -= 0xFF while address > 0xFF
        @register[:A] &= @ram[address]
        set_sz(@register[:A])

      when 0x2D # AND absolute
        @register[:A] &= @ram[(oper1 << 8) | oper2]
        set_sz(@register[:A])

      when 0x3D # AND absolutex
        sixteen = to_16_bit(oper1, oper2)
        add_cycle_if_crossing_boundary(sixteen, @register[:X])
        address = (sixteen + @register[:X])
        @register[:A] &= @ram[address]
        set_sz(@register[:A])

      when 0x39 # AND absolutey
        sixteen = to_16_bit(oper1, oper2)
        add_cycle_if_crossing_boundary(sixteen, @register[:Y])
        address = (sixteen + @register[:Y])
        @register[:A] &= @ram[address]
        set_sz(@register[:A])

      when 0x21 # AND indirectx
        @register[:A] &= @ram[indirect_x_address(oper1)]
        set_sz(@register[:A])

      when 0x31 # AND indirecty
        add_cycle_if_crossing_boundary(oper1, @register[:Y])
        @register[:A] &= @ram[indirect_y_address(oper1)]
        set_sz(@register[:A])

      when 0x0A # ASL accumulator
        set_carry(@register[:A] & 0x80 == 0x80)
        @register[:A] <<= 1
        @register[:A] &= 0xFF
        set_sz(@register[:A])

      when 0x06 # ASL zeropage
        op_asl(oper1)

      when 0x16 # ASL zeropagex
        address = oper1 + @register[:X]
        op_asl(address)

      when 0x0E # ASL absolute
        address = (oper1 << 8) | oper2
        op_asl(address)

      when 0x1E # ASL absolutex
        address = ((oper1 << 8) | oper2) + @register[:X]
        op_asl(address)

      when 0x90 # BCC relative
        if @flag[:C] == 0
          add_branching_cycles(oper1)
          branch_pc(oper1)
        end

      when 0xB0 # BCS relative
        if @flag[:C] == 1
          add_branching_cycles(oper1)
          branch_pc(oper1)
        end

      when 0xF0 # BEQ relative
        if @flag[:Z] == 1
          add_branching_cycles(oper1)
          branch_pc(oper1)
        end

      when 0x30 # BMI relative
        if @flag[:N] == 1
          add_branching_cycles(oper1)
          branch_pc(oper1)
        end

      when 0xD0 # BNE relative
        if (@flag[:Z] == 0)
          add_branching_cycles(oper1)
          branch_pc(oper1)
        end

      when 0x10 # BPL relative
        if @flag[:N] == 0
          add_branching_cycles(oper1)
          branch_pc(oper1)
        end

      when 0x00 # BRK implied
        #puts "************** IN BREAK **************"
        #
        @flag[:B] = 1
        push(@pc >> 8)
        push(@pc & 0xFF)
        push(packed_flags)
        @flag[:I] = 1
        @pc = (@ram[0xFFFF] << 8) | @ram[0xFFFE]
      
      when 0x50 # BVC relative
        if @flag[:V] == 0
          add_branching_cycles(oper1)
          branch_pc(oper1)
        end

      when 0x70 # BVS relative
        if @flag[:V] == 1
          add_branching_cycles(oper1)
          branch_pc(oper1)
        end

      when 0x24 # BIT zeropage
        set_zero(@register[:A] & @ram[oper1])
        set_sign(@ram[oper1])
        set_overflow(@ram[oper1] & 0x40 == 0x40 ? 1 : 0)

      when 0x2C # BIT absolute
        address = (oper1 << 8) | oper2
        set_zero(@register[:A] & @ram[address])
        set_sign(@ram[address])
        set_overflow(@ram[address] & 0x40 == 0x40 ? 1 : 0)

      when 0x18 # CLC implied
        @flag[:C] = 0

      when 0xD8 # CLD implied
        @flag[:D] = 0

      when 0x58 # CLI implied
        @flag[:I] = 0

      when 0xB8 # CLV implied
        @flag[:V] = 0

      when 0XC9 # CMP immediate
        set_carry(@register[:A] >= oper1)
        result = (@register[:A] - oper1) & 0xFF
        set_sz(result)

      when 0XC5 # CMP zeropage
        address = oper1
        op_cmp(address)

      when 0XD5 # CMP zeropagex
        address = oper1 + @register[:X]
        address -= 0xFF while address > 0xFF
        op_cmp(address)

      when 0XCD # CMP absolute
        address = (oper1 << 8) | oper2
        op_cmp(address)

      when 0XDD # CMP absolutex
        sixteen = to_16_bit(oper1, oper2)
        add_cycle_if_crossing_boundary(sixteen, @register[:X])
        address = (sixteen + @register[:X])
        op_cmp(address)

      when 0XD9 # CMP absolutey
        sixteen = to_16_bit(oper1, oper2)
        add_cycle_if_crossing_boundary(sixteen, @register[:Y])
        address = (sixteen + @register[:Y])
        op_cmp(address)

      when 0XC1 # CMP indirectx
        address = indirect_x_address(oper1)
        op_cmp(address)

      when 0XD1 # CMP indirecty
        add_cycle_if_crossing_boundary(oper1, @register[:Y])
        address = indirect_y_address(oper1)
        op_cmp(address)

      when 0xE0 # CPX immediate
        tmp = @register[:X] - oper1
        set_carry(@register[:X] >= oper1) #was < 0x100
        set_sz(tmp)

      when 0xE4 # CPX zeropage
        tmp = @register[:X] - @ram[oper1]
        set_carry(@register[:X] >= @ram[oper1])
        set_sz(tmp)

      when 0xEC # CPX absolute
        address = (oper1 << 8) | oper2
        tmp = @register[:X] - @ram[address]
        set_carry(@register[:X] >= @ram[address])
        set_sz(tmp)

      when 0xC0 # CPY immediate
        tmp = @register[:Y] - oper1
        set_carry(@register[:Y] >= oper1) #was < 0x100
        set_sz(tmp)

      when 0xC4 # CPY zeropage
        tmp = @register[:Y] - @ram[oper1]
        set_carry(@register[:Y] >= @ram[oper1])
        set_sz(tmp)

      when 0xCC # CPY absolute
        address = (oper1 << 8) | oper2
        tmp = @register[:Y] - @ram[address]
        set_carry(@register[:Y] >= @ram[address])
        set_sz(tmp)

      when 0xC6 # DEC zeropage
        @ram[oper1] = (@ram[oper1] - 0x01) & 0xFF
        set_sz(@ram[oper1])

      when 0xD6 # DEC zeropagex
        address = (oper1 + @register[:X])
        address -= 0xFF while address > 0xFF
        @ram[address] = (@ram[address] - 0x01) & 0xFF
        set_sz(@ram[address])

      when 0xCE # DEC absolute
        address = (oper1 << 8) | oper2
        @ram[address] = (@ram[address] - 0x01) & 0xFF
        set_sz(@ram[address])

      when 0xDE # DEC absolutex
        address = ((oper1 << 8) | oper2) + @register[:X]
        @ram[address] = (@ram[address] - 0x01) & 0xFF
        set_sz(@ram[address])

      when 0xCA # DEX implied
        @register[:X] = (@register[:X] - 1) & 0xFF
        set_sz(@register[:X])

      when 0x88 # DEY implied
        @register[:Y] = (@register[:Y] - 1) & 0xFF
        set_sz(@register[:Y])

      when 0x49 # EOR immediate
        @register[:A] = (@register[:A] ^ oper1) & 0xFF
        set_sz(@register[:A])

      when 0x45 # EOR zeropage
        op_eor(oper1)

      when 0x55 # EOR zeropagex
        address = oper1 + @register[:X]
        address -= 0xFF while address > 0xFF
        op_eor(address)

      when 0x4D # EOR absolute
        op_eor((oper1 << 8) | oper2)

      when 0x5D # EOR absolutex
        sixteen = to_16_bit(oper1, oper2)
        add_cycle_if_crossing_boundary(sixteen, @register[:X])
        op_eor(sixteen + @register[:X])

      when 0x59 # EOR absolutey
        sixteen = to_16_bit(oper1, oper2)
        add_cycle_if_crossing_boundary(sixteen, @register[:Y])
        op_eor(sixteen + @register[:Y])

      when 0x41 # EOR indirectx
        op_eor(indirect_x_address(oper1))

      when 0x51 # EOR indirecty
        add_cycle_if_crossing_boundary(oper1, @register[:Y])
        op_eor(indirect_y_address(oper1))

      when 0xE6 # INC zeropage
        address = oper1
        @ram[address] = (@ram[address] + 1) & 0xFF
        set_sz(@ram[address])

      when 0xF6 # INC zeropagex
        address = oper1 + @register[:X]
        address -= 0xFF while address > 0xFF
        @ram[address] = (@ram[address] + 1) & 0xFF
        set_sz(@ram[address])

      when 0xEE # INC absolute
        address = (oper1 << 8) | oper2
        @ram[address] = (@ram[address] + 1) & 0xFF
        set_sz(@ram[address])

      when 0xFE # INC absolutex
        address = ((oper1 << 8) | oper2) + register[:X]
        @ram[address] = (@ram[address] + 1) & 0xFF
        set_sz(@ram[address])

      when 0xE8 # INX implied
        @register[:X] = (@register[:X] + 1) & 0xFF
        set_sz(register[:X])

      when 0xC8 # INY implied
        @register[:Y] = (@register[:Y] + 1) & 0xFF
        set_sz(@register[:Y])

      when 0x4C # JMP absolute
        address = (oper1 << 8) | oper2
        lo_byte = @ram[address]

        # bug emulation
        hi_byte = (address & 0xFF == 0xFF) ? @ram[address - 0xFF] : @ram[address + 1]
        @pc = (hi_byte << 8) | lo_byte

      when 0x6C # JMP indirect
        address = (oper1 << 8) | oper2
        lo_byte = @ram[address]
        hi_byte = @ram[address + 1]

        new_address = (hi_byte << 8) | lo_byte
        real_lo_byte = @ram[new_address]

        # bug emulation
        real_hi_byte = (new_address & 0xFF == 0xFF) ? @ram[new_address - 0xFF] : @ram[new_address + 1]

        @pc = (real_hi_byte << 8) | real_lo_byte

      when 0x20 # JSR absolute
        @pc -= 1 # we subtract 1 because the JSR docs say to

        # push one byte at a time onto the stack
        push((@pc >> 8) & 0xFF)
        push(@pc & 0xFF)

        @pc = (oper1 << 8) | oper2
      
      when 0xA9 # LDA immediate
        @register[:A] = oper1
        set_sz(oper1)

      when 0xA5 # LDA zeropage
        value = @ram[oper1]
        @register[:A] = value
        set_sz(value)

      when 0xB5 # LDA zeropagex
        address = oper1 + @register[:X]
        address -= 0xFF while address > 0xFF
        value = @ram[address]
        @register[:A] = value
        set_sz(value)

      when 0xAD # LDA absolute
        value = @ram[(oper1 << 8) | oper2]
        @register[:A] = value
        set_sz(value)

      when 0xBD # LDA absolutex
        sixteen = to_16_bit(oper1, oper2)
        add_cycle_if_crossing_boundary(sixteen, @register[:X])
        address = (sixteen + @register[:X])
        value = @ram[address]
        @register[:A] = value
        set_sz(value)

      when 0xB9 # LDA absolutey
        sixteen = to_16_bit(oper1, oper2)
        add_cycle_if_crossing_boundary(sixteen, @register[:Y])
        address = (sixteen + @register[:Y])
        value = @ram[address]
        @register[:A] = value
        set_sz(value)

      when 0xA1 # LDA indirectx
        value = @ram[indirect_x_address(oper1)]
        @register[:A] = value
        set_sz(value)

      when 0xB1 # LDA indirecty
        add_cycle_if_crossing_boundary(oper1, @register[:Y])
        value = @ram[indirect_y_address(oper1)]
        @register[:A] = value
        set_sz(value)

      when 0xA2 # LDX immediate
        @register[:X] = oper1
        set_sz(@register[:X])
      
      when 0xA6 # LDX zeropage
        @register[:X] = @ram[oper1]
        set_sz(@register[:X])

      when 0xB6 # LDX zeropagey
        address = oper1 + register[:Y]
        address -= 0xFF while address > 0xFF
        @register[:X] = @ram[address]
        set_sz(@register[:X])

      when 0xAE # LDX absolute
        @register[:X] = @ram[(oper1 << 8) | oper2]
        set_sz(@register[:X])

      when 0xBE # LDX absolutey
        sixteen = to_16_bit(oper1, oper2)
        add_cycle_if_crossing_boundary(sixteen, @register[:Y])
        @register[:X] = @ram[sixteen + @register[:Y]]
        set_sz(@register[:X])

      when 0xA0 # LDY immediate
        @register[:Y] = oper1
        set_sz(@register[:Y])

      when 0xA4 # LDY zeropage
        @register[:Y] = @ram[oper1]
        set_sz(@register[:Y])

      when 0xB4 # LDY zeropagex
        address = oper1 + register[:X]
        address -= 0xFF while address > 0xFF
        @register[:Y] = @ram[address]
        set_sz(@register[:Y])

      when 0xAC # LDY absolute
        @register[:Y] = @ram[(oper1 << 8) | oper2]
        set_sz(@register[:Y])

      when 0xBC # LDY absolutex
        sixteen = to_16_bit(oper1, oper2)
        add_cycle_if_crossing_boundary(sixteen, @register[:X])
        @register[:Y] = @ram[sixteen + @register[:X]]
        set_sz(@register[:Y])

      when 0x4A # LSR accumulator
        @flag[:C] = @register[:A] & 0x01 == 0x01 ? 1 : 0
        @register[:A] >>= 1
        set_zero(@register[:A])
      
      when 0x46 # LSR zeropage
        @flag[:C] = @ram[oper1] & 0x01 == 0x01 ? 1 : 0
        @ram[oper1] >>= 1
        set_zero(@ram[oper1])

      when 0x56 # LSR zeropagex
        address = oper1 + @register[:X]
        address -= 0xFF while address > 0xFF
        @flag[:C] = @ram[address] & 0x01 == 0x01 ? 1 : 0
        @ram[address] >>= 1
        set_zero(@ram[address])

      when 0x4E # LSR absolute
        address = (oper1 << 8) | oper2
        @flag[:C] = @ram[address] & 0x01 == 0x01 ? 1 : 0
        @ram[address] >>= 1
        set_zero(@ram[address])

      when 0x5E # LSR absolutex
        address = ((oper1 << 8) | oper2) + @register[:X]
        @flag[:C] = @ram[address] & 0x01 == 0x01 ? 1 : 0
        @ram[address] >>= 1
        set_zero(@ram[address])

      when 0xEA # NOP

      when 0x09 # ORA immediate
        @register[:A] |= oper1
        set_sz(@register[:A])

      when 0x05 # ORA zeropage
        @register[:A] |= @ram[oper1]
        set_sz(@register[:A])

      when 0x15 # ORA zeropagex
        address = oper1 + @register[:X]
        address -= 0xFF while address > 0xFF
        @register[:A] |= @ram[address]
        set_sz(@register[:A])

      when 0x0D # ORA absolute
        @register[:A] |= @ram[(oper1 << 8) | oper2]
        set_sz(@register[:A])

      when 0x1D # ORA absolutex
        sixteen = to_16_bit(oper1, oper2)
        add_cycle_if_crossing_boundary(sixteen, @register[:X])
        @register[:A] |= @ram[sixteen + @register[:X]]
        set_sz(@register[:A])

      when 0x19 # ORA absolutey
        sixteen = to_16_bit(oper1, oper2)
        add_cycle_if_crossing_boundary(sixteen, @register[:Y])
        @register[:A] |= @ram[sixteen + @register[:Y]]
        set_sz(@register[:A])

      when 0x01 # ORA indirectx
        @register[:A] |= @ram[indirect_x_address(oper1)]
        set_sz(@register[:A])

      when 0x11 # ORA indirecty
        add_cycle_if_crossing_boundary(oper1, @register[:Y])
        @register[:A] |= @ram[indirect_y_address(oper1)]
        set_sz(@register[:A])

      when 0x48 # PHA implied
        push(@register[:A])

      when 0x08 # PHP implied
        # break flag is always 1 when pushed via PHP.
        push(packed_flags | 0x10)

      when 0x68 # PLA implied
        @register[:A] = pull
        set_sz(@register[:A])

      when 0x28 # PLP implied
        val = pull
        @flag[:N] = val & 0x80 == 0 ? 0 : 1
        @flag[:V] = val & 0x40 == 0 ? 0 : 1
        # no flag at 0x20
#        @flag[:B] = 0 # break flag doesn't really exist
        @flag[:D] = val & 0x08 == 0 ? 0 : 1
        @flag[:I] = val & 0x04 == 0 ? 0 : 1
        @flag[:Z] = val & 0x02 == 0 ? 0 : 1
        @flag[:C] = val & 0x01 == 0 ? 0 : 1

      when 0x2A # ROL accumulator
        carry = @flag[:C]
        @flag[:C] = @register[:A] & 0x80 == 0x80 ? 1 : 0
        @register[:A] = (@register[:A] << 1) & 0xFF
        @register[:A] |= carry
        set_sz(@register[:A])
        
      when 0x26 # ROL zeropage
        address = oper1
        op_rol(address)

      when 0x36 # ROL zeropagex
        op_rol(zeropage_address(oper1 + @register[:X]))

      when 0x2E # ROL absolute
        address = (oper1 << 8) | oper2
        op_rol(address)

      when 0x3E # ROL absolutex
        address = ((oper1 << 8) | oper2) + @register[:X]
        op_rol(address)

      when 0x6A # ROR accumulator
        carry = @flag[:C]
        @flag[:C] = @register[:A] & 0x01 == 0x01 ? 1 : 0
        @register[:A] = (@register[:A] >> 1) & 0xFF
        @register[:A] |= (carry << 7)
        set_sz(@register[:A])

      when 0x66 # ROR zeropage
        address = oper1
        op_ror(address)

      when 0x76 # ROR zeropagex
        op_ror(zeropage_address(oper1 + @register[:X]))

      when 0x6E # ROR absolute
        address = (oper1 << 8) | oper2
        op_ror(address)

      when 0x7E # ROR absolutex
        address = ((oper1 << 8) | oper2) + @register[:X]
        op_ror(address)

      when 0x40 # RTI implied
        status = pull
        # flag bits 7 to 0 are: N V - B D I Z C

        # break flag is always set to 0 because it doesn't really exist
        @flag[:C] = status & 0x01 == 0x01 ? 1 : 0
        @flag[:Z] = status & 0x02 == 0x02 ? 1 : 0
        @flag[:I] = status & 0x04 == 0x04 ? 1 : 0
        @flag[:D] = status & 0x08 == 0x08 ? 1 : 0
        @flag[:B] = 0
        @flag[:V] = status & 0x40 == 0x40 ? 1 : 0
        @flag[:N] = status & 0x80 == 0x80 ? 1 : 0

        lo = pull
        hi = pull
        @pc = (hi << 8) | lo

      when 0x60 # RTS implied
        lo = pull
        hi = pull
        @pc = ((hi << 8) | lo) + 1

      when 0xE9 # SBC immediate
        op_sbc(oper1)

      when 0xE5 # SBC zeropage
        op_sbc(@ram[oper1])

      when 0xF5 # SBC zeropagex
        op_sbc(@ram[zeropage_address(oper1 + @register[:X])])

      when 0xED # SBC absolute
        op_sbc(@ram[(oper1 << 8) | oper2])

      when 0xFD # SBC absolutex
        sixteen = to_16_bit(oper1, oper2)
        add_cycle_if_crossing_boundary(sixteen, @register[:X])
        op_sbc(@ram[sixteen + @register[:X]])

      when 0xF9 # SBC absolutey
        sixteen = to_16_bit(oper1, oper2)
        add_cycle_if_crossing_boundary(sixteen, @register[:Y])
        op_sbc(@ram[sixteen + @register[:Y]])

      when 0xE1 # SBC indirectx
        op_sbc(@ram[indirect_x_address(oper1)])

      when 0xF1 # SBC indirecty
        add_cycle_if_crossing_boundary(oper1, @register[:Y])
        op_sbc(@ram[indirect_y_address(oper1)])

      when 0x38 # SEC implied
        @flag[:C] = 1

      when 0xF8 # SED implied
        @flag[:D] = 1

      when 0x78 # SEI implied
        @flag[:I] = 1

      when 0x85 # STA zeropage
        @ram[oper1] = @register[:A]

      when 0x95 # STA zeropagex
        @ram[zeropage_address(oper1 + @register[:X])] = @register[:A]
      
      when 0x8D # STA absolute
        @ram[absolute_address(oper1, oper2)] = @register[:A]

      when 0x9D # STA absolutex
        address = ((oper1 << 8) | oper2) + @register[:X]
        @ram[address] = @register[:A]

      when 0x99 # STA absolutex
        address = ((oper1 << 8) | oper2) + @register[:Y]
        @ram[address] = @register[:A]

      when 0x81 # STA indirectx
        @ram[indirect_x_address(oper1)] = @register[:A]

      when 0x91 # STA indirecty
        @ram[indirect_y_address(oper1)] = @register[:A]

      when 0x86 # STX zeropage
        @ram[oper1] = @register[:X]

      when 0x96 # STX zeropagey
        @ram[zeropage_address(oper1 + @register[:Y])] = @register[:X]

      when 0x8E # STX absolute
        @ram[absolute_address(oper1, oper2)] = @register[:X]

      when 0x84 # STY zeropage
        @ram[oper1] = @register[:Y]

      when 0x94 # STY zeropagex
        @ram[zeropage_address(oper1 + @register[:X])] = @register[:Y]

      when 0x8C # STY absolute
        @ram[absolute_address(oper1, oper2)] = @register[:Y]

      when 0xAA # TAX implied
        @register[:X] = @register[:A]
        set_sz(@register[:X])

      when 0xA8 # TAY implied
        @register[:Y] = @register[:A]
        set_sz(@register[:Y])

      when 0xBA # TSX implied
        @register[:X] = @register[:S]
        set_sz(@register[:X])
        
      when 0x8A # TXA implied
        @register[:A] = @register[:X]
        set_sz(@register[:A])

      when 0x9A # TXS implied
        @register[:S] = @register[:X]

      when 0x98 # TYA
        @register[:A] = @register[:Y]
        set_sz(@register[:A])

    end
    #display_status
  end

  def readmem(pc)
    @prog[pc]
  end

  def decode
    @pc = 0
    while @pc <= (@pc_offset + @imagesize)
      #puts "inside decode loop - #{@pc} #{@prog.size}"
      opcode=readmem(@pc)
      info = opcodes[opcode]
      case info[2]
        when 2
          @operand[0] = readmem(@pc + 1)
#          printf("%04X\t%s #%02X\t\t # %02X%02X -- (%d)\n", @pc,desc, @operand[0], opc, @operand[0], bytes) if @debug
          runop(opcode, @operand[0], @operand[1])
        when 1
#          printf("%04X\t%s \t\t #%02X -- (%d)\n", @pc,desc, opc, bytes) if @debug
          runop(opcode, @operand[0], @operand[1])
        when 3
          @operand[0] = readmem(@pc + 2) # 6502 args are lo-byte first
          @operand[1] = readmem(@pc + 1)
#          printf("%04X\t%s $%02X%02X\t\t # %02X%02X%02X -- (%d)\n", @pc,desc, @operand[0], @operand[1], opc, @operand[0],@operand[1], bytes) if @debug
          runop(opcode, @operand[0], @operand[1])
      end
    end
  end

  def opcodes(op = nil)
    if op
      self.class.opcodes[op]
    else
      self.class.opcodes
    end
  end
  
  private

  def zeropage_address(arg)
    arg -= 0xFF while arg > 0xFF
    arg
  end

  def absolute_address(arg1, arg2)
    (arg1 << 8)| arg2
  end

  def indirect_x_address(arg)
    lsb = arg + @register[:X]

    lsb &= 0xFF # stay on zero page
    hsb = lsb == 0xFF ? 0x00 : lsb + 1

    @ram[hsb] << 8 | @ram[lsb]
  end

  def indirect_y_address(arg)
    lsb = arg
    lsb &= 0xFF
    hsb = lsb == 0xFF ? 0x00 : lsb + 1
    address = @ram[hsb] << 8 | @ram[lsb]

    address + @register[:Y]
  end

  def op_adc(arg)
    if @flag[:D] == 1
      result = self.class.to_bin[@register[:A]] + @flag[:C] + self.class.to_bin[arg]
    else
      result = @register[:A] + @flag[:C] + arg
    end

    set_sz(result)

    if @flag[:D] == 1
      set_carry(result > 99)
      result -= 100 while result > 100
      @register[:A] = self.class.to_bcd[result]
    else
      set_carry(result > 255)

      if ( ~(@register[:A] ^ arg) & (@register[:A] ^ result) ) & 0x80 > 0
        set_overflow(1)
      else
        set_overflow(0)
      end

      result &= 0xFF
      @register[:A] = result
    end
  end

  def op_sbc(arg)
    if @flag[:D] == 1
      result = to_bin(@register[:A]) - to_bin(arg) - (@flag[:C] == 0 ? 1 : 0)
    else
      result = @register[:A] - arg - (@flag[:C] == 0 ? 1 : 0)
    end

    set_carry(result & 0x100 == 0)
    set_sz(result)
    
    if @flag[:D] == 1
      result &= 0xFF
#      result += 100 while result < 0
      @register[:A] = to_bcd(result)
    else
      if ( ~(@register[:A] ^ arg) & (@register[:A] ^ result) ) & 0x80 > 0
        set_overflow(1)
      else
        set_overflow(0)
      end

      @register[:A] = result & 0xFF
    end
  end

  def op_asl(address)
    set_carry(@ram[address] & 0x80 == 0x80)
    @ram[address] = (@ram[address] << 1) & 0xFF
    set_sz(@ram[address])
  end

  def op_cmp(address)
    set_carry(@register[:A] >= @ram[address])
    result = (@register[:A] - @ram[address]) & 0xFF
    set_sz(result)
  end

  def op_rol(address)
    carry = @flag[:C]
    @flag[:C] = @ram[address] & 0x80 == 0x80 ? 1 : 0
    @ram[address] = (@ram[address] << 1) & 0xFF
    @ram[address] |= carry
    set_sz(@ram[address])
  end

  def op_ror(address)
    carry = @flag[:C]
    @flag[:C] = @ram[address] & 0x01 == 0x01 ? 1 : 0
    @ram[address] = (@ram[address] >> 1) & 0xFF
    @ram[address] |= (carry << 7)
    set_sz(@ram[address])
  end

  def branch_pc(arg)
    @pc += branch_address(arg)
  end

  def op_eor(address)
    @register[:A] = (@register[:A] ^ @ram[address]) & 0xFF
    set_sz(@register[:A])
  end

  def branch_address(arg)
    if (arg > 0x7F)
      (~arg & 0xFF) * -1
    else
      arg & 0xFF
    end
  end

  def add_cycle_if_crossing_boundary(address, register)
    hi = address >> 8
    @cycles += 1 if hi != ((address + register) >> 8)
  end

  def add_branching_cycles(address)
    if (@pc + branch_address(address)) >> 8 != @pc >> 8
      @cycles += 2
    else
      @cycles += 1
    end
  end

  def service_interrupt(vector_byte)
    push(@pc >> 8)
    push(@pc & 0xFF)
    push(packed_flags & (~0x10))

    @pc = (@ram[vector_byte + 1] << 8) | @ram[vector_byte]
    @flag[:I] = 1
  end

  # so, so common to call these together.
  def set_sz(arg)
    set_sign(arg)
    set_zero(arg)
  end

  def packed_flags
    (@flag[:N] << 7) |
    (@flag[:V] << 6) |
#    (@flag[:U] << 5) |
    (@flag[:B] << 4) |
    (@flag[:D] << 3) |
    (@flag[:I] << 2) |
    (@flag[:Z] << 1) |
    (@flag[:C])
  end

  def to_16_bit(arg1, arg2)
    (arg1 << 8) | arg2
  end
  
  def to_bcd(num)
    self.class.to_bcd[num]
  end

  def to_bin(num)
    self.class.to_bin[num]
  end
end

#if ARGV.empty?
#  puts "Usage: 6502.rb [image] -d | disassemble"
#  puts "       6502.rb [image] -r | run"
#  exit 0
#end
#
#myCPU = C6502.new
#myCPU.loadi(ARGV[0])
#myCPU.debug = true if ARGV.find { |a| a == "-d" }
#
#printf("Image length: %d\n", myCPU.imagesize)
#
#myCPU.decode if ARGV.find { |a| a == "-r" }
#