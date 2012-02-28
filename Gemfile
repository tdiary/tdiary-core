source :rubygems

gem 'rack'
gem 'rake'
gem 'sprockets'
gem 'coffee-script'

gem 'redcarpet'
gem 'pygments.rb'
gem 'rubypython', '0.5.1'

group :development do
  gem 'thin', :require => false, :platforms => :ruby
  gem 'racksh', :require => false

  gem 'capistrano', :require => false
  gem 'capistrano_colors', :require => false
  gem 'pit', :require => false

  group :test do
    gem 'tapp'

    gem 'test-unit', :require => 'test/unit'
    gem 'rspec'

    gem 'capybara', :require => 'capybara/rspec'
    gem 'capybara-mechanize', '~> 0.3.0.rc3', :require => 'capybara/mechanize'
    gem 'launchy'
    gem 'multi_json', '~> 1.0.4'

    gem 'rcov', :platforms => :mri_18
    platforms :mri_19 do
      gem 'simplecov', :require => false
      gem 'simplecov-rcov', :require => false
    end
    gem 'ci_reporter'
  end
end
