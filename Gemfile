source :rubygems

gem 'rake'
gem 'coffee-script'

# Use rack environment
gem 'rack'
gem 'sprockets'

# To use GFM style
platforms :mri do
  gem 'redcarpet'
  gem 'pygments.rb'
  gem 'rubypython', '0.5.1'
end

# Use tDiary in Heroku
# gem 'sequel'
#
# Use memcached addon
# gem 'dalli'
#
# To use CRuby
# platforms :mri do
#   gem 'thin', :require => false
#   gem 'pg'
# end
#
# To use JRuby
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
