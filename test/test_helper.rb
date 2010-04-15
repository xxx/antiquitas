require 'rubygems'
require 'bundler'
Bundler.require(:default, :test)

Dir.glob(File.join(File.dirname(__FILE__), '..', 'cpu', '*.rb')).each do |f|
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
      assert_equal (0x6950 + 2) - (~(0xF8) & 0xff), @cpu.pc
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
end