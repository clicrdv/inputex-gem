require 'rake/testtask'

Rake::TestTask.new do |t|
  if RUBY_VERSION >= "1.9.2"
     require 'coveralls'
     Coveralls.wear!
  end
  t.libs << 'test'
end

desc "Run tests"
task :default => :test