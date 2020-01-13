source 'https://rubygems.org'

gem 'rack', '~> 2.1' # ~> 2.0 requires ruby 2.2.2 or later.
gem 'hikidoc'
gem 'fastimage'
gem 'emot'
gem 'mail'
gem 'rake'

group :development do
  gem 'pit', require: false
  gem 'racksh', require: false
  gem 'redcarpet'
  gem 'octokit'
  gem 'mime-types'

  platforms :ruby_23, :ruby_24 do
    gem 'ruby-debug-ide'
    gem 'debase'
  end

  group :test do
    gem 'pry-byebug', platforms: [:ruby_23, :ruby_24]
    gem 'test-unit'
    gem 'rspec'
    gem 'capybara', require: 'capybara/rspec'
    gem 'selenium-webdriver'
    gem 'launchy'
    gem 'sequel'
    gem 'sqlite3'
    gem 'jasmine', '< 3'
    gem 'simplecov', require: false
    gem 'coveralls', require: false
  end
end

# https://github.com/redmine/redmine/blob/master/Gemfile#L89
local_gemfile = File.join(File.dirname(__FILE__), "Gemfile.local")
if File.exist?(local_gemfile)
  puts "Loading Gemfile.local ..." if $DEBUG # `ruby -d` or `bundle -v`
  instance_eval File.read(local_gemfile)
end
