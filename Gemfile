source :rubygems

gem 'rake'

# Use rack environment
gem 'rack'
gem 'sprockets'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-github'

# To use memcached for CacheIO
# gem 'dalli'

platforms :mri do
  # To use CoffeeScript
  gem 'coffee-script'
  gem 'therubyracer'

  # To use GFM style or To covert tDiary document.
  gem 'redcarpet'
  gem 'pygments.rb'
  gem 'rubypython', '0.5.1'

  # To use rack based application server
  gem 'thin', :require => false
  # gem 'unicorn', :require => false

  # To use RdbIO
  # gem 'sequel'
  # gem 'pg'

  # If you use other database adapter
  # gem 'mysql'
  # gem 'sqlite3'
end

# platforms :jruby do
#   gem 'trinidad', :require => false
#   gem 'jdbc-postgres', :require => 'jdbc/postgres'
# end

group :development do
  gem 'capistrano', :require => false
  gem 'capistrano_colors', :require => false
  gem 'pit', :require => false
  gem 'racksh', :require => false

  group :test do
    gem 'tapp'
    gem 'test-unit', :require => 'test/unit'
    gem 'rspec'
    gem 'capybara', :require => 'capybara/rspec'
    gem 'launchy'

    gem 'rcov', :platforms => :mri_18
    platforms :mri_19 do
      gem 'simplecov', :require => false
      gem 'simplecov-rcov', :require => false
    end
    gem 'ci_reporter'
  end
end
