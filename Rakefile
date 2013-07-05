require 'rake/testtask'

task default: :test

Rake::TestTask.new do |t|
  t.pattern = 'test/snp/*_test.rb'
  t.libs.push 'test'
  t.libs.push 'spec'
  t.verbose = true
end
