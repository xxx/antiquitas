require 'rubygems'
require 'bundler'
Bundler.require(:default, :test)

Dir.glob(File.join(File.dirname(__FILE__), '..', 'cpu', '*.rb')).each do |f|
  require f
end

#require File.join(File.dirname(__FILE__), 'blueprints')

