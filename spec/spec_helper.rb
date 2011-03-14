# -*- coding: utf-8 -*-
$:.unshift File.expand_path('../..', __FILE__)
require 'tdiary/environment'
Bundler.require :test if defined?(Bundler)

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  # config.mock_with :rr
end
