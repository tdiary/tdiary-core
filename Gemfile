source 'https://rubygems.org'

gem 'rake'

gem 'rack'
gem 'sprockets'
gem 'coffee-script'

gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-github'

gem 'dalli'
gem 'redis'
gem 'redis-namespace'

platforms :mri do
  gem 'thin'

  # if you don't have JavaScript processor, uncomment this line.
  # gem 'therubyracer'

  gem 'redcarpet'
  gem 'pygments.rb'
  gem 'twitter-text', :require => false
end

platforms :jruby do
  gem 'trinidad'
end

group :development do
  gem 'capistrano', :require => false
  gem 'capistrano_colors', :require => false
  gem 'rvm-capistrano', :require => false
  gem 'pit', :require => false
  gem 'racksh', :require => false

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
    gem 'simplecov-rcov', :require => false
    gem 'coveralls', :require => false
    gem 'ci_reporter'
  end
end
