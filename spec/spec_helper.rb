# -*- coding: utf-8 -*-
require File.expand_path('../../tdiary/environment', __FILE__)
Bundler.require :test if defined?(Bundler)

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  # config.mock_with :rr
end
