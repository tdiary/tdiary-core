source :rubygems

gem 'rack'
gem 'rake'
gem 'sprockets'
gem 'coffee-script'
gem 'sequel'
gem 'dalli'

platforms :mri do
  gem 'thin', :require => false
  gem 'pg'
  gem 'redcarpet'
  gem 'pygments.rb'
  gem 'rubypython', '0.5.1'
end

platforms :jruby do
  gem 'trinidad', :require => false
  gem 'jdbc-postgres', :require => 'jdbc/postgres'
end

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
