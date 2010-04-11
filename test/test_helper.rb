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
end