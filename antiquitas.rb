#!/usr/bin/env ruby
require 'ostruct'
require 'optparse'
require 'rubygems'
require 'bundler'

Bundler.require :default

Dir.glob(File.join(File.dirname(__FILE__), '{cpu,lib}', '**', '*.rb')).each do |f|
  require f
end

$options = Antiquitas::Options.parse(ARGV)

# here, the only thing left in ARGV should be the name of the rom
rom = ARGV.first

if $options.debug
  print '> '
  while line = $stdin.gets.chomp
    puts line
    print '> '
  end
else
  puts  'cool'
end