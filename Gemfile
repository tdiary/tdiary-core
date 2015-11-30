source 'https://rubygems.org'

gem 'rack'
gem 'sprockets'
gem 'hikidoc'
gem 'fastimage'
gem 'gemoji'
gem 'mail'

group :coffee do
  gem 'coffee-script'
  gem 'therubyracer'
end

group :development do
  gem 'pit', require: false
  gem 'racksh', require: false
  gem 'rake'
  gem 'redcarpet'

  group :test do
    gem 'pry-byebug', platforms: [:ruby_20, :ruby_21]
    gem 'test-unit'
    gem 'rspec'
    gem 'capybara', require: 'capybara/rspec'
    gem 'selenium-webdriver'
    gem 'launchy'
    gem 'sequel'
    gem 'sqlite3'
    gem 'jasmine'
    gem 'simplecov', require: false
    gem 'coveralls', '~> 0.7.12', require: false
  end
end

# https://github.com/redmine/redmine/blob/master/Gemfile#L89
local_gemfile = File.join(File.dirname(__FILE__), "Gemfile.local")
if File.exist?(local_gemfile)
  puts "Loading Gemfile.local ..." if $DEBUG # `ruby -d` or `bundle -v`
  instance_eval File.read(local_gemfile)
end
