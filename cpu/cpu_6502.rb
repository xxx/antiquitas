class Cpu6502
  attr_accessor :debug, :register, :flag, :ram, :pc
  attr_reader :imagesize

  class << self
    attr_reader :opcodes, :to_bin, :to_bcd
  end

  @opcodes = {
    # mnemonic, mode, bytes, cycles
    0x69 => [ "ADC", :immediate,   2, 2 ],
    0x65 => [ "ADC", :zeropage,    2, 3 ],
    0x75 => [ "ADC", :zeropagex,   2, 4 ],
    0x6D => [ "ADC", :absolute,    3, 4 ],
    0x7D => [ "ADC", :absolutex,   3, [4, 5] ],
    0x79 => [ "ADC", :absolutey,   3, [4, 5] ],
    0x61 => [ "ADC", :indirectx,   2, 6 ],
    0x71 => [ "ADC", :indirecty,   2, [5, 6] ],

    0x29 => [ "AND", :immediate,   2, 2 ],
    0x25 => [ "AND", :zeropage,    2, 3 ],
    0x35 => [ "AND", :zeropagex,   2, 4 ],
    0x2D => [ "AND", :absolute,    3, 4 ],
    0x3D => [ "AND", :absolutex,   3, [4, 5] ],
    0x39 => [ "AND", :absolutey,   3, [4, 5] ],
    0x21 => [ "AND", :indirectx,   2, 6 ],
    0x31 => [ "AND", :indirecty,   2, [5, 6] ],

    0x0A => [ "ASL", :accumulator, 1, 2 ],
    0x06 => [ "ASL", :zeropage,    2, 5 ],
    0x16 => [ "ASL", :zeropagex,   2, 6 ],
    0x0E => [ "ASL", :absolute,    3, 6 ],
    0x1E => [ "ASL", :absolutex,   3, 7 ],

    0x90 => [ "BCC", :relative,    2, [2, 3, 4] ],

    0xB0 => [ "BCS", :relative,    2, [2, 3, 4] ],

    0xF0 => [ "BEQ", :relative,    2, [2, 3, 4] ],

    0x24 => [ "BIT", :zeropage,    2, 3 ],
    0x2C => [ "BIT", :absolute,    3, 4 ],

    0x30 => [ "BMI", :relative,    2, [2, 3, 4] ],

    0xD0 => [ "BNE", :relative,    2, [2, 3, 4] ],

    0x10 => [ "BPL", :relative,    2, [2, 3, 4] ],

    0x00 => [ "BRK", :implied,     1, 7 ],
    
    0x50 => [ "BVC", :relative,    2, [2, 3, 4] ],

    0x70 => [ "BVS", :relative,    2, [2, 3, 4] ],

    0x18 => [ "CLC", :implied,     1, 2 ],

    0xD8 => [ "CLD", :implied,     1, 2 ],

    0x58 => [ "CLI", :implied,     1, 2 ],

    0xB8 => [ "CLV", :implied,     1, 2 ],

    0xC9 => [ "CMP", :immediate,   2, 2 ],
    0xC5 => [ "CMP", :zeropage,    2, 3 ],
    0xD5 => [ "CMP", :zeropagex,   2, 4 ],
    0xCD => [ "CMP", :absolute,    3, 4 ],
    0xDD => [ "CMP", :absolutex,   3, [4, 5] ],
    0xD9 => [ "CMP", :absolutey,   3, [4, 5] ],
    0xC1 => [ "CMP", :indirectx,   2, 6 ],
    0xD1 => [ "CMP", :indirecty,   2, [5, 6] ],

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
    0x5D => [ "EOR", :absolutex,   3, [4, 5] ],
    0x59 => [ "EOR", :absolutey,   3, [4, 5] ],
    0x41 => [ "EOR", :indirectx,   2, 6 ],
    0x51 => [ "EOR", :indirecty,   2, [5, 6] ],

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
    0xBD => [ "LDA", :absolutex,   3, [4, 5] ],
    0xB9 => [ "LDA", :absolutey,   3, [4, 5] ],
    0xA1 => [ "LDA", :indirectx,   2, 6 ],
    0xB1 => [ "LDA", :indirecty,   2, [5, 6] ],

    0xA2 => [ "LDX", :immediate,   2, 2 ],
    0xA6 => [ "LDX", :zeropage,    2, 3 ],
    0xB6 => [ "LDX", :zeropagey,   2, 4 ],
    0xAE => [ "LDX", :absolute,    3, 4 ],
    0xBE => [ "LDX", :absolutey,   3, [4, 5] ],

    0xA0 => [ "LDY", :immediate,   2, 2 ],
    0xA4 => [ "LDY", :zeropage,    2, 3 ],
    0xB4 => [ "LDY", :zeropagex,   2, 4 ],
    0xAC => [ "LDY", :absolute,    3, 4 ],
    0xBC => [ "LDY", :absolutex,   3, [4, 5] ],

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
    0x1D => [ "ORA", :absolutex,   3, [4, 5] ],
    0x19 => [ "ORA", :absolutey,   3, [4, 5] ],
    0x01 => [ "ORA", :indirectx,   2, 6 ],
    0x11 => [ "ORA", :indirecty,   2, [5, 6] ],

    0x48 => [ "PHA", :implied,     1, 3 ],

    0x08 => [ "PHP", :implied,     1, 3 ],

    0x8A => [ "TXA", :implied,     1, 2 ],

    0x98 => [ "TYA", :implied,     1, 2 ],

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
    @register = { :A => 0, :X => 0, :Y => 0, :SP => 0xFF, :SR => 0 }
    @flag = { :S => 0, :V => 0, :B => 0, :D => 0, :I => 0, :Z => 0, :C => 0 }
    @operand = Array.new(2)
  end

  def opcodes
    self.class.opcodes
  end

  def display_status
    if (@debug)
      printf("PC=%04x SP=%04x A=%02x X=%02x Y=%02x S=%02x C=%d Z=%d\n\n", @pc,@register[:SP],@register[:A],@register[:X],@register[:Y],@flag[:S],@flag[:C]?1:0,@flag[:Z])
    end
  end

  def push(oper1)
    @ram[@register[:SP]+0x100] = oper1
    @register[:SP]-=1
  end

  def pull
    @register[:SP]+=1
    @ram[@register[:SP]+0x100]
  end

  def set_sign(accumulator)
    @flag[:S] = (accumulator & 0x80) == 0x80 ? 1 : 0 #bit 7 of A
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
    case opcode
      when 0x69 # ADC immediate
        @pc += op[2]
        op_adc(oper1)

      when 0x65 # ADC zeropage
        @pc += op[2]
        op_adc(@ram[oper1])
      
      when 0x75 # ADC zeropagex
        @pc += op[2]
        address = oper1 + @register[:X]
        address -= 0xFF while address > 0xFF 

        op_adc(@ram[address])

      when 0x6D # ADC absolute
        @pc += op[2]
        op_adc(@ram[(oper1 << 8) | oper2])

      when 0x7D # ADC absolutex
        @pc += op[2]
        op_adc(@ram[((oper1 << 8) | oper2) + @register[:X]])

      when 0x79 # ADC absolutey
        @pc += op[2]
        op_adc(@ram[((oper1 << 8) | oper2) + @register[:Y]])

      when 0x61 # ADC indirectx
        @pc += op[2]
        op_adc(@ram[indirect_x_address(oper1)])

      when 0x71 # ADC indirecty
        @pc += op[2]
        op_adc(@ram[indirect_y_address(oper1)])

      when 0x29 # AND immediate
        @pc += op[2]
        @register[:A] &= oper1
        set_sz(@register[:A])

      when 0x25 # AND zeropage
        @pc += op[2]
        @register[:A] &= @ram[oper1]
        set_sz(@register[:A])

      when 0x35 # AND zeropagex
        @pc += op[2]
        address = oper1 + @register[:X]
        address -= 0xFF while address > 0xFF
        @register[:A] &= @ram[address]
        set_sz(@register[:A])

      when 0x2D # AND absolute
        @pc += op[2]
        @register[:A] &= @ram[(oper1 << 8) | oper2]
        set_sz(@register[:A])

      when 0x3D # AND absolutex
        @pc += op[2]
        @register[:A] &= @ram[((oper1 << 8) | oper2) + @register[:X]]
        set_sz(@register[:A])

      when 0x39 # AND absolutey
        @pc += op[2]
        @register[:A] &= @ram[((oper1 << 8) | oper2) + @register[:Y]]
        set_sz(@register[:A])

      when 0x21 # AND indirectx
        @pc += op[2]

        @register[:A] &= @ram[indirect_x_address(oper1)]
        set_sz(@register[:A])

      when 0x31 # AND indirecty
        @pc += op[2]

        @register[:A] &= @ram[indirect_y_address(oper1)]
        set_sz(@register[:A])

      when 0x0A # ASL accumulator
        @pc += op[2]
        set_carry(@register[:A] & 0x80 == 0x80)
        @register[:A] <<= 1
        @register[:A] &= 0xFF
        set_sz(@register[:A])

      when 0x06 # ASL zeropage
        @pc += op[2]
        op_asl(oper1)

      when 0x16 # ASL zeropagex
        @pc += op[2]
        address = oper1 + @register[:X]
        op_asl(address)

      when 0x0E # ASL absolute
        @pc += op[2]
        address = (oper1 << 8) | oper2
        op_asl(address)

      when 0x1E # ASL absolutex
        @pc += op[2]
        address = ((oper1 << 8) | oper2) + @register[:X]
        op_asl(address)

      when 0x90 # BCC relative
        @pc += op[2]
        if @flag[:C] == 0
          branch_pc(oper1)
        end

      when 0xB0 # BCS relative
        @pc += op[2]
        if @flag[:C] == 1
          branch_pc(oper1)
        end

      when 0xF0 # BEQ relative
        @pc += op[2]
        if @flag[:Z] == 1
          branch_pc(oper1)
        end

      when 0x30 # BMI relative
        @pc += op[2]
        if @flag[:S] == 1
          branch_pc(oper1)
        end

      when 0xD0 # BNE relative
        @pc += op[2]
        if (@flag[:Z] == 0)
          branch_pc(oper1)
        end

      when 0x10 # BPL relative
        @pc += op[2]
        if @flag[:S] == 0
          branch_pc(oper1)
        end

      when 0x00 # BRK implied
        #puts "************** IN BREAK **************"
        #
        @pc += op[2]
        push(@pc >> 8)
        push(@pc & 0x00FF)
        push(register[:SR])
        @flag[:B] = 1
        @pc = (@ram[0xFFFE] << 8) | @ram[0xFFFF]
      
      when 0x50 # BVC relative
        @pc += op[2]
        if @flag[:V] == 0
          branch_pc(oper1)
        end

      when 0x70 # BVS relative
        @pc += op[2]
        if @flag[:V] == 1
          branch_pc(oper1)
        end

      when 0x24 # BIT zeropage
        @pc += op[2]
        set_zero(@register[:A] & @ram[oper1])
        set_sign(@ram[oper1])
        set_overflow(@ram[oper1] & 0x40 == 0x40 ? 1 : 0)

      when 0x2C # BIT absolute
        @pc += op[2]
        address = (oper1 << 8) | oper2
        set_zero(@register[:A] & @ram[address])
        set_sign(@ram[address])
        set_overflow(@ram[address] & 0x40 == 0x40 ? 1 : 0)

      when 0x18 # CLC implied
        @pc += op[2]
        @flag[:C] = 0

      when 0xD8 # CLD implied
        @pc += op[2]
        @flag[:D] = 0

      when 0x58 # CLI implied
        @pc += op[2]
        @flag[:I] = 0

      when 0xB8 # CLV implied
        @pc += op[2]
        @flag[:V] = 0

      when 0XC9 # CMP immediate
        @pc += op[2]
        set_carry(@register[:A] >= oper1)
        result = (@register[:A] - oper1) & 0xFF
        set_sz(result)

      when 0XC5 # CMP zeropage
        @pc += op[2]
        address = oper1
        op_cmp(address)

      when 0XD5 # CMP zeropagex
        @pc += op[2]
        address = oper1 + @register[:X]
        address -= 0xFF while address > 0xFF
        op_cmp(address)

      when 0XCD # CMP absolute
        @pc += op[2]
        address = (oper1 << 8) | oper2
        op_cmp(address)

      when 0XDD # CMP absolutex
        @pc += op[2]
        address = ((oper1 << 8) | oper2) + @register[:X]
        op_cmp(address)

      when 0XD9 # CMP absolutey
        @pc += op[2]
        address = ((oper1 << 8) | oper2) + @register[:Y]
        op_cmp(address)

      when 0XC1 # CMP indirectx
        @pc += op[2]
        address = indirect_x_address(oper1)
        op_cmp(address)

      when 0XD1 # CMP indirecty
        @pc += op[2]
        address = indirect_y_address(oper1)
        op_cmp(address)

      when 0xE0 # CPX immediate
        @pc += op[2]
        tmp = @register[:X] - oper1
        set_carry(@register[:X] >= oper1) #was < 0x100
        set_sz(tmp)

      when 0xE4 # CPX zeropage
        @pc += op[2]
        tmp = @register[:X] - @ram[oper1]
        set_carry(@register[:X] >= @ram[oper1])
        set_sz(tmp)

      when 0xEC # CPX absolute
        @pc += op[2]
        address = (oper1 << 8) | oper2
        tmp = @register[:X] - @ram[address]
        set_carry(@register[:X] >= @ram[address])
        set_sz(tmp)

      when 0xC0 # CPY immediate
        @pc += op[2]
        tmp = @register[:Y] - oper1
        set_carry(@register[:Y] >= oper1) #was < 0x100
        set_sz(tmp)

      when 0xC4 # CPY zeropage
        @pc += op[2]
        tmp = @register[:Y] - @ram[oper1]
        set_carry(@register[:Y] >= @ram[oper1])
        set_sz(tmp)

      when 0xCC # CPY absolute
        @pc += op[2]
        address = (oper1 << 8) | oper2
        tmp = @register[:Y] - @ram[address]
        set_carry(@register[:Y] >= @ram[address])
        set_sz(tmp)

      when 0xC6 # DEC zeropage
        @pc += op[2]
        @ram[oper1] -= 0x01
        set_sz(@ram[oper1])

      when 0xD6 # DEC zeropagex
        @pc += op[2]
        address = (oper1 + @register[:X])
        address -= 0xFF while address > 0xFF
        @ram[address] -= 0x01
        set_sz(@ram[address])

      when 0xCE # DEC absolute
        @pc += op[2]
        address = (oper1 << 8) | oper2
        @ram[address] -= 0x01
        set_sz(@ram[address])

      when 0xDE # DEC absolutex
        @pc += op[2]
        address = ((oper1 << 8) | oper2) + @register[:X]
        @ram[address] -= 0x01
        set_sz(@ram[address])

      when 0xCA # DEX implied
        @pc += op[2]
        @register[:X] = (@register[:X] - 1) & 0xFF
        set_sz(@register[:X])

      when 0x88 # DEY implied
        @pc += op[2]
        @register[:Y] = (@register[:Y] - 1) & 0xFF
        set_sz(@register[:Y])

      when 0x49 # EOR immediate
        @pc += op[2]
        @register[:A] = (@register[:A] ^ oper1) & 0xFF
        set_sz(@register[:A])

      when 0x45 # EOR zeropage
        @pc += op[2]
        @register[:A] = (@register[:A] ^ @ram[oper1]) & 0xFF
        set_sz(@register[:A])

      when 0x55 # EOR zeropagex
        @pc += op[2]
        address = oper1 + @register[:X]
        address -= 0xFF while address > 0xFF
        @register[:A] = (@register[:A] ^ @ram[address]) & 0xFF
        set_sz(@register[:A])

      when 0x4D # EOR absolute
        @pc += op[2]
        address = (oper1 << 8) | oper2
        @register[:A] = (@register[:A] ^ @ram[address]) & 0xFF
        set_sz(@register[:A])

      when 0x5D # EOR absolutex
        @pc += op[2]
        address = ((oper1 << 8) | oper2) + @register[:X]
        @register[:A] = (@register[:A] ^ @ram[address]) & 0xFF
        set_sz(@register[:A])

      when 0x59 # EOR absolutey
        @pc += op[2]
        address = ((oper1 << 8) | oper2) + @register[:Y]
        @register[:A] = (@register[:A] ^ @ram[address]) & 0xFF
        set_sz(@register[:A])

      when 0x41 # EOR indirectx
        @pc += op[2]
        address = indirect_x_address(oper1)
        @register[:A] = (@register[:A] ^ @ram[address]) & 0xFF
        set_sz(@register[:A])

      when 0x51 # EOR indirecty
        @pc += op[2]
        address = indirect_y_address(oper1)
        @register[:A] = (@register[:A] ^ @ram[address]) & 0xFF
        set_sz(@register[:A])

      when 0xE6 # INC zeropage
        @pc += op[2]
        address = oper1
        @ram[address] = (@ram[address] + 1) & 0xFF
        set_sz(@ram[address])

      when 0xF6 # INC zeropagex
        @pc += op[2]
        address = oper1 + @register[:X]
        address -= 0xFF while address > 0xFF
        @ram[address] = (@ram[address] + 1) & 0xFF
        set_sz(@ram[address])

      when 0xEE # INC absolute
        @pc += op[2]
        address = (oper1 << 8) | oper2
        @ram[address] = (@ram[address] + 1) & 0xFF
        set_sz(@ram[address])

      when 0xFE # INC absolutex
        @pc += op[2]
        address = ((oper1 << 8) | oper2) + register[:X]
        @ram[address] = (@ram[address] + 1) & 0xFF
        set_sz(@ram[address])

      when 0xE8 # INX implied
        @pc += op[2]
        @register[:X] = (@register[:X] + 1) & 0xFF
        set_sz(register[:X])

      when 0xC8 # INY implied
        @pc += op[2]
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
#        @pc = @pc + 3 - 1 # we subtract 1 because the JSR docs say to
        @pc -= 1 # we subtract 1 because the JSR docs say to

        # push one byte at a time ont the stack
        push((@pc >> 8) & 0xFF)
        push(@pc & 0xFF)

        @pc = (oper1 << 8) | oper2
#        if @pc == 0xFFEE
#          putc(@register[:A])
#        end
#        display_status
#        @pc = pull
#        @pc |= (pull << 8)
#        @pc += 1
      
      when 0xA9 # LDA immediate
        @pc += op[2]
        @register[:A] = oper1
        set_sz(oper1)

      when 0xA5 # LDA zeropage
        @pc += op[2]
        value = @ram[oper1]
        @register[:A] = value
        set_sz(value)

      when 0xB5 # LDA zeropagex
        @pc += op[2]
        address = oper1 + @register[:X]
        address -= 0xFF while address > 0xFF
        value = @ram[address]
        @register[:A] = value
        set_sz(value)

      when 0xAD # LDA absolute
        @pc += op[2]
        value = @ram[(oper1 << 8) | oper2]
        @register[:A] = value
        set_sz(value)

      when 0xBD # LDA absolutex
        @pc += op[2]
        address = ((oper1 << 8) | oper2) + @register[:X]
        value = @ram[address]
        @register[:A] = value
        set_sz(value)

      when 0xB9 # LDA absolutey
        @pc += op[2]
        address = ((oper1 << 8) | oper2) + @register[:Y]
        value = @ram[address]
        @register[:A] = value
        set_sz(value)

      when 0xA1 # LDA indirectx
        @pc += op[2]
        value = @ram[indirect_x_address(oper1)]
        @register[:A] = value
        set_sz(value)

      when 0xB1 # LDA indirecty
        @pc += op[2]
        value = @ram[indirect_y_address(oper1)]
        @register[:A] = value
        set_sz(value)

      when 0xA2 # LDX immediate
        @pc += op[2]
        @register[:X] = oper1
        set_sz(@register[:X])
      
      when 0xA6 # LDX zeropage
        @pc += op[2]
        @register[:X] = @ram[oper1]
        set_sz(@register[:X])

      when 0xB6 # LDX zeropagey
        @pc += op[2]
        address = oper1 + register[:Y]
        address -= 0xFF while address > 0xFF
        @register[:X] = @ram[address]
        set_sz(@register[:X])

      when 0xAE # LDX absolute
        @pc += op[2]
        @register[:X] = @ram[(oper1 << 8) | oper2]
        set_sz(@register[:X])

      when 0xBE # LDX absolutey
        @pc += op[2]
        @register[:X] = @ram[((oper1 << 8) | oper2) + @register[:Y]]
        set_sz(@register[:X])

      when 0xA0 # LDY immediate
        @pc += op[2]
        @register[:Y] = oper1
        set_sz(@register[:Y])

      when 0xA4 # LDY zeropage
        @pc += op[2]
        @register[:Y] = @ram[oper1]
        set_sz(@register[:Y])

      when 0xB4 # LDY zeropagex
        @pc += op[2]
        address = oper1 + register[:X]
        address -= 0xFF while address > 0xFF
        @register[:Y] = @ram[address]
        set_sz(@register[:Y])

      when 0xAC # LDY absolute
        @pc += op[2]
        @register[:Y] = @ram[(oper1 << 8) | oper2]
        set_sz(@register[:Y])

      when 0xBC # LDY absolutex
        @pc += op[2]
        @register[:Y] = @ram[((oper1 << 8) | oper2) + @register[:X]]
        set_sz(@register[:Y])

      when 0x4A # LSR accumulator
        @pc += op[2]
        @flag[:C] = @register[:A] & 0x01 == 0x01 ? 1 : 0
        @register[:A] >>= 1
        set_zero(@register[:A])
      
      when 0x46 # LSR zeropage
        @pc += op[2]
        @flag[:C] = @ram[oper1] & 0x01 == 0x01 ? 1 : 0
        @ram[oper1] >>= 1
        set_zero(@ram[oper1])

      when 0x56 # LSR zeropagex
        @pc += op[2]
        address = oper1 + @register[:X]
        address -= 0xFF while address > 0xFF
        @flag[:C] = @ram[address] & 0x01 == 0x01 ? 1 : 0
        @ram[address] >>= 1
        set_zero(@ram[address])

      when 0x4E # LSR absolute
        @pc += op[2]
        address = (oper1 << 8) | oper2
        @flag[:C] = @ram[address] & 0x01 == 0x01 ? 1 : 0
        @ram[address] >>= 1
        set_zero(@ram[address])

      when 0x5E # LSR absolutex
        @pc += op[2]
        address = ((oper1 << 8) | oper2) + @register[:X]
        @flag[:C] = @ram[address] & 0x01 == 0x01 ? 1 : 0
        @ram[address] >>= 1
        set_zero(@ram[address])

      when 0xEA # NOP
        @pc += op[2]

      when 0x09 # ORA immediate
        @pc += op[2]
        @register[:A] |= oper1
        set_sz(@register[:A])

      when 0x05 # ORA zeropage
        @pc += op[2]
        @register[:A] |= @ram[oper1]
        set_sz(@register[:A])

      when 0x15 # ORA zeropagex
        @pc += op[2]
        address = oper1 + @register[:X]
        address -= 0xFF while address > 0xFF
        @register[:A] |= @ram[address]
        set_sz(@register[:A])

      when 0x0D # ORA absolute
        @pc += op[2]
        @register[:A] |= @ram[(oper1 << 8) | oper2]
        set_sz(@register[:A])

      when 0x1D # ORA absolutex
        @pc += op[2]
        @register[:A] |= @ram[((oper1 << 8) | oper2) + @register[:X]]
        set_sz(@register[:A])

      when 0x19 # ORA absolutey
        @pc += op[2]
        @register[:A] |= @ram[((oper1 << 8) | oper2) + @register[:Y]]
        set_sz(@register[:A])

      when 0x01 # ORA indirectx
        @pc += op[2]
        @register[:A] |= @ram[indirect_x_address(oper1)]
        set_sz(@register[:A])

      when 0x11 # ORA indirecty
        @pc += op[2]
        @register[:A] |= @ram[indirect_y_address(oper1)]
        set_sz(@register[:A])

      when 0x48 # PHA implied
        @pc += 1
        push(@register[:A])

      when 0x08 # PHP implied
        @pc += 1
        value = (
            (@flag[:S] << 7) |
            (@flag[:V] << 6) |
            (@flag[:B] << 4) |
            (@flag[:D] << 3) |
            (@flag[:I] << 2) |
            (@flag[:Z] << 1) |
            (@flag[:C])
          )
        push(value)


      when 0x8A #TXA
        @pc += op[2]
        set_sign(@register[:X])
        set_zero(@register[:X])
        @register[:A] = @register[:X]

      when 0x98 # TYA
        @pc += op[2]
        @register[:A] = @register[:Y]
        set_sign(@register[:A])
        set_zero(@register[:A])

    end
    #display_status
  end

  def readmem(pc)
    @prog[pc]
  end

  def decode
    @pc=0
    while @pc <= (@pc_offset + @imagesize)
      #puts "inside decode loop - #{@pc} #{@prog.size}"
      opcode=readmem(@pc)
      info = @@opcodes[opcode]
      case info[2]
        when 2
          @operand[0] = readmem(@pc+1)
#          printf("%04X\t%s #%02X\t\t # %02X%02X -- (%d)\n", @pc,desc, @operand[0], opc, @operand[0], bytes) if @debug
          runop(opcode, @operand[0], @operand[1])
        when 1
#          printf("%04X\t%s \t\t #%02X -- (%d)\n", @pc,desc, opc, bytes) if @debug
          runop(opcode, @operand[0], @operand[1])
        when 3
          @operand[0] = readmem(@pc+2)
          @operand[1] = readmem(@pc+1)
#          printf("%04X\t%s $%02X%02X\t\t # %02X%02X%02X -- (%d)\n", @pc,desc, @operand[0], @operand[1], opc, @operand[0],@operand[1], bytes) if @debug
          runop(opcode, @operand[0], @operand[1])
      end
    end
  end

  private

  def indirect_x_address(arg)
    lsb_address = arg + @register[:X]

    lsb_address -= 0xFF while lsb_address > 0xFF
    hsb_address = lsb_address == 0xFF ? 0x00 : lsb_address + 1

    @ram[hsb_address] << 8 | @ram[lsb_address]
  end

  def indirect_y_address(arg)
    lsb = arg
    lsb -= 0xFF while lsb > 0xFF
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
      set_overflow(result > 99) # no idea what to do here.
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

  def branch_pc(arg)
    if (arg > 0x7F)
      @pc -= ~arg & 0x00FF
    else
      @pc += arg & 0x00FF
    end
  end

  # so, so common to call these together.
  def set_sz(arg)
    set_sign(arg)
    set_zero(arg)
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
