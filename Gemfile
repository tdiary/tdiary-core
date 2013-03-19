source 'https://rubygems.org'

gem 'rake'

# Use rack environment
gem 'rack'
gem 'sprockets'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-github'

# To use memcached for CacheIO
# gem 'dalli'

# To use redis for CacheIO
# gem 'redis'

platforms :mri do
  # To use CoffeeScript
  gem 'coffee-script'

  # if you don't have JavaScript processor, uncomment this line.
  # gem 'therubyracer'

  # To use GFM style or To covert tDiary document.
  gem 'redcarpet'
  gem 'twitter-text', :require => false
  gem 'pygments.rb'

  # To use rack based application server
  gem 'thin', :require => false
  # gem 'unicorn', :require => false
end

# platforms :jruby do
#   gem 'trinidad', :require => false
# end

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
    gem 'launchy'
    gem 'sequel'
    gem 'sqlite3'
    gem 'jasmine'

    gem 'rcov', :platforms => :mri_18
    if RUBY_VERSION > '1.9' # bundler did't provide :mri_20 platform
      gem 'simplecov', :require => false
      gem 'simplecov-rcov', :require => false
      gem 'coveralls', :require => false
    end
    gem 'ci_reporter'
  end
end
