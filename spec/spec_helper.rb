dir = File.dirname(__FILE__)
$LOAD_PATH.unshift "#{dir}/../lib"

require 'rubygems'
require 'rspec'
require 'rspec/autorun'

Dir["spec/support/**/*.rb"].each { |f| require File.expand_path(f) }


