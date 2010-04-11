class Cpu6502
  attr_accessor :debug, :register, :flag, :ram, :pc
  attr_reader :imagesize


  @@opcodes = {
    # mnemonic, mode, bytes, cycles
    0xA2 => [ "LDX", :immediate, 2, 2 ],
    0xA9 => [ "LDA", :immediate, 2, 2 ],
    0xA6 => [ "LDX", :zeropage,  2, 3 ],
    0xB6 => [ "LDX", :zeropagey, 2, 4 ],
    0xAE => [ "LDX", :absolute,  2, 4 ],
    0xBE => [ "LDX", :absolutey, 2, [4, 5] ],
    0x8A => [ "TXA", :implied,   1, 2 ],
    0x98 => [ "TYA", :implied,   1, 2 ],
    0x20 => [ "JSR", :absolute,  3, 6 ],
    0xE8 => [ "INX", :absolute,  1, 2 ],
    0xE0 => [ "CPX", :absolute,  2, 2 ],
    0xD0 => [ "BNE", :absolute,  2, [2, 3, 4] ],
    0x00 => [ "BRK", :absolute,  2, 7 ],
    0x69 => [ "ADC", :immediate, 2, 2 ]
  }

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

  def display_status
    if (@debug)
      printf("PC=%04x SP=%04x A=%02x X=%02x Y=%02x S=%02x C=%d Z=%d\n\n", @pc,@register[:SP],@register[:A],@register[:X],@register[:Y],@flag[:S],@flag[:C]?1:0,@flag[:Z])
    end
  end

  def push(oper1)
    #display_status
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

  def loadi(filen)
    @prog = File.open(filen, "rb") { |io| io.read }
    @imagesize = @prog.size
  end

  def runop(opcode, oper1 = nil, oper2 = nil)
#    display_status
    case opcode
      when 0xA2 #LDX
        @register[:X] = oper1
        @pc += 2
        set_sign(@register[:X])
        set_zero(@register[:X])
      when 0x8A #TXA
        set_sign(@register[:X])
        set_zero(@register[:X])
        @register[:A] = @register[:X]
        @pc += 1
      when 0x20 #JSR
        @pc = @pc + 3 - 1 #was +3
        
        # push one byte at a time ont the stack
        push((@pc >> 8) & 0xff)
        push(@pc & 0xff)

        @pc = (oper1 << 8) | oper2
#        if @pc == 0xFFEE
#          putc(@register[:A])
#        end
#        display_status
#        @pc = pull
#        @pc |= (pull << 8)
#        @pc += 1
      when 0xE8 #INX
        @pc += 1
        @register[:X] = (@register[:X]+1) & 0xff
        set_sign(@register[:X])
        set_zero(@register[:X])
      when 0xE0 #CPX
        @pc += 2
        tmp = @register[:X] - oper1
        set_carry(@register[:X] >= oper1) #was < 0x100
        set_sign(tmp)
        set_zero(tmp)
      when 0xD0 #BNE
        @pc += 2
        if (@flag[:Z] == 0)
          if (oper1 > 0x7F)
            @pc = @pc - (~(oper1) & 0x00FF)
          else
            @pc = @pc + (oper1 & 0x00FF)
          end
        end
      when 0xA9 #LDA
        @pc += 2
        set_sign(oper1)
        set_zero(oper1)
        @register[:A] = oper1
      when 0x98 # TYA
        @pc += 1
        @register[:A] = @register[:Y]
        set_sign(@register[:A])
        set_zero(@register[:A])
      when 0x00 #BRK
        #puts "************** IN BREAK **************"
        # 
        @pc += 1
        push(@pc >> 8)
        push(@pc & 0x00FF)
        push(register[:SR])
        @flag[:B] = 1
        @pc = (@ram[0xFFFE] << 8) | @ram[0xFFFF]
      when 0x69 # ADC
        @pc += 2
        p @register[:A]
        p oper1
        @register[:A] += (@flag[:C] + oper1)
        set_zero @register[:A]

      when 0xEA # NOP
        @pc += 1

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
