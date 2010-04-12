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

#  desc "Run the request tests"
#  Rake::TestTask.new do |t|
#    t.name = 'requests'
#    t.libs << "test"
#    t.test_files = FileList['test/requests/*_test.rb']
#    t.verbose = true
#  end
end

task :test do
  Rake::Task["test:cpu"].invoke
#  Rake::Task["test:requests"].invoke
end

task :default => :test
