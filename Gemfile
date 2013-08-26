source 'https://rubygems.org'

gem 'rack'
gem 'sprockets'
gem 'hikidoc'
gem 'rdtool'
gem 'fastimage'

group :coffee do
  gem 'coffee-script'
  gem 'therubyracer'
end

group :memcached do
  gem 'dalli'
end

group :redis do
  gem 'redis'
  gem 'redis-namespace'
end

group :gfm do
  gem 'redcarpet'
  gem 'pygments.rb'
  gem 'twitter-text', :require => false
end

group :server do
  platforms :mri do
    gem 'thin'
  end

  platforms :jruby do
    gem 'trinidad'
  end
end

group :development do
  gem 'pit', :require => false
  gem 'racksh', :require => false
  gem 'rake'

  group :test do
    gem 'pry'
    gem 'tapp'
    gem 'test-unit', :require => 'test/unit'
    gem 'rspec'
    gem 'capybara', :require => 'capybara/rspec'
    gem 'selenium-webdriver'
    gem 'launchy'
    gem 'sequel'
    gem 'sqlite3'
    gem 'jasmine'
    gem 'simplecov', :require => false
    gem 'coveralls', :require => false
  end
end

# https://github.com/redmine/redmine/blob/master/Gemfile#L89
local_gemfile = File.join(File.dirname(__FILE__), "Gemfile.local")
if File.exists?(local_gemfile)
  puts "Loading Gemfile.local ..." if $DEBUG # `ruby -d` or `bundle -v`
  instance_eval File.read(local_gemfile)
end
