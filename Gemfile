source :rubygems

gem 'rack'
gem 'rake'

group :development do
  gem 'thin', :platforms => :ruby
  gem 'capistrano', :require => false
  gem 'capistrano_colors', :require => false
  gem 'pit', :require => false

  group :test do
    gem 'test-unit', :require => 'test/unit'
    gem 'turn'
    gem 'rspec'
    gem 'fuubar'
    gem 'tapp'

    gem 'rcov', :platforms => :mri_18
    gem 'simplecov', :require => false, :platforms => :mri_19

    gem 'capybara', :require => 'capybara/rspec'
    gem 'capybara-mechanize', '~> 0.3.0.rc3', :require => 'capybara/mechanize'
    gem 'launchy'
  end
end
