require 'rake'
require 'rake/testtask'

namespace :test do
  desc "Run the cpu tests"
  Rake::TestTask.new do |t|
    t.name = 'cpu'
    t.libs << "test"
    t.test_files = FileList['test/cpu/**/*_test.rb']
    t.verbose = true
  end

  desc "Run the disassembler tests"
  Rake::TestTask.new do |t|
    t.name = 'disassembler'
    t.libs << "test"
    t.test_files = FileList['test/disassembler/**/*_test.rb']
    t.verbose = true
  end

  desc "Run the monitor/debugger tests"
  Rake::TestTask.new do |t|
    t.name = 'monitor'
    t.libs << "test"
    t.test_files = FileList['test/monitor/**/*_test.rb']
    t.verbose = true
  end
end

desc "Run all tests"
Rake::TestTask.new do |t|
  t.name = 'test'
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

task :default => :test
