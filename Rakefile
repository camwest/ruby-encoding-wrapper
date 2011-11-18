require 'rubygems'
require 'bundler'
require 'rake'
require 'rspec/core/rake_task'

desc 'Default: run unit tests.'
task :default => :unit

desc 'Test the ruby_encoding_wrapper plugin.'
RSpec::Core::RakeTask.new('unit') do |t|
  t.pattern = 'spec/{*_spec.rb}'
end
