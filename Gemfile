source 'https://rubygems.org'

gem 'rack'
gem 'rack-session'
gem 'rackup'
gem 'hikidoc'
gem 'fastimage'
gem 'emot'
gem 'mail'
gem 'rake'

group :development do
  gem 'pit', require: false
  gem 'racksh', require: false
  gem 'redcarpet'
  gem 'octokit'
  gem 'mime-types'

  group :test do
    gem 'test-unit'
    gem 'rspec'
    gem 'capybara', require: 'capybara/rspec'
    gem 'date', '>= 3.1.1' # for compatibility of capybara
    gem 'selenium-webdriver'
    gem 'launchy'
    gem 'sequel'
    gem 'sqlite3'
    gem 'simplecov', require: false
    gem "rexml"
    gem "webrick"
  end
end

# https://github.com/redmine/redmine/blob/master/Gemfile#L89
local_gemfile = File.join(File.dirname(__FILE__), "Gemfile.local")
if File.exist?(local_gemfile)
  puts "Loading Gemfile.local ..." if $DEBUG # `ruby -d` or `bundle -v`
  instance_eval File.read(local_gemfile)
end
