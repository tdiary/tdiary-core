source :rubygems

gem 'rack'
gem 'rake', '0.9.2'

group :development do
  gem 'thin', :platforms => :ruby
  gem 'capistrano', :require => false
  gem 'capistrano_colors', :require => false
  gem 'pit'
end

group :test do
  gem 'rspec'
  gem 'fuubar'
  gem 'rcov', :platforms => :mri_18
  gem 'cover_me', :platforms => :mri_19
  gem 'nokogiri', '~> 1.4.7' # for ruby-1.8.6
  gem 'steak'
  gem 'capybara', :require => 'capybara/rspec'
  gem 'capybara-mechanize', :require => 'capybara/mechanize'
  gem 'launchy'
end
