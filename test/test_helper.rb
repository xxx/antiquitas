require 'rubygems'
require 'bundler'
Bundler.require(:default, :test)

Dir.glob(File.join(File.dirname(__FILE__), '..', '{cpu,lib}', '**', '*.rb')).each do |f|
  require f
end

#require File.join(File.dirname(__FILE__), 'blueprints')

class Test::Unit::TestCase
  def to16bit(high_byte, low_byte)
    (high_byte << 8) | low_byte
  end

  def self.should_branch_correctly
    should "increase the pc by the number of bytes in the arg if the arg is > 0 and less than 0x80" do
      @cpu.pc = 0x69
      @cpu.runop(@op, 0x05)
      assert_equal 0x6E + 2, @cpu.pc # + 2 due to pc increment
    end

    should "decrease the pc by the number of bytes (twos complement) in the arg if the arg is >= 0x80 and <= 0xFF" do
      @cpu.pc = 0x6950
      @cpu.runop(@op, 0xF8)
      assert_equal (0x6950 + 2) - (~(0xF8) & 0xFF), @cpu.pc
    end
  end

  def self.should_increase_pc_by(amount)
    should "increase the pc by the number of bytes for this op" do
      pc = @cpu.pc
      args = Array.new(amount - 1, 0)
      @cpu.runop(@op, *args)
      assert_equal pc + amount, @cpu.pc
    end
  end

  def self.should_increase_cycles_by(amount)
    should "increase the cycle count by the correct number" do
      # While we could pull the cycle info out of @op_info, that would mean we're
      # testing the code being tested with itself.
      # We really only do this so we can get the correct byte count (tested elsewhere)
      # so we can dummy up args and dry up the code.
      @op_info = @cpu.opcodes[@op]
      @args = Array.new(@op_info[2] - 1, 0) # @op_info[2] == op byte count
      @cycles = @cpu.cycles
      @cpu.runop(@op, *@args)
      assert_equal @cycles + amount, @cpu.cycles
    end
  end

  def self.should_increase_cycles_with_boundary_check_by(amount)
    should_increase_cycles_by(amount)

    should "add one more cycle if adding the index crosses a page boundary" do
      if block_given?
        @args = yield
      else
        # set up some default args that should work with all of the tests.
        @op_info = @cpu.opcodes[@op] # need to get op byte count to get correct # of args
        @args = @op_info[2] == 3 ? [0x06, 0xFE] : [0xFE]
      end

      @cycles = @cpu.cycles
      @cpu.runop(@op, *@args)
      assert_equal @cycles + amount + 1, @cpu.cycles
    end
  end

  def self.should_increase_cycles_with_branch_check_by(amount)
    context "increasing cycles with special branching logic" do
      setup do
        @flag, @success = yield
        @cpu.flag[@flag] = @success
        @cpu.cycles = 0
      end

      context "branch not taken" do
        setup do
          fail = 1 - @success
          @cpu.flag[@flag] = fail
        end

        should_increase_cycles_by(amount)
      end

      should "add an extra cycle if the branch was taken forward" do
        @cpu.pc = 0x00
        @cpu.runop(@op, 0x01)
        assert_equal amount + 1, @cpu.cycles
      end

      should "add an extra cycle if the branch was taken backward" do
        @cpu.pc = 0x90
        @cpu.runop(@op, 0xFE)
        assert_equal amount + 1, @cpu.cycles
      end

      should "add two extra cycles if branched forward over a page boundary" do
        @cpu.pc = 0xFC
        @cpu.runop(@op, 0x02)
        assert_equal amount + 2, @cpu.cycles
      end

      should "add two extra cycles if branched backward over a page boundary" do
        @cpu.pc = 0x04
        @cpu.runop(@op, 0xF0)
        assert_equal amount + 2, @cpu.cycles
      end
    end
  end

  def self.should_disassemble(op, result)
    context "disassembly of #{op.to_s(16)}" do
      should "disassemble into the correct string" do
        @op_info = @cpu.opcodes(op)
        args = [0x12, 0x34][0, @op_info[2] - 1] # get correct number of args
        assert_equal result, @cpu.disassemble(op, *args).gsub(/\s{2,}/, ' ')
      end
    end
  end
end