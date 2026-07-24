source 'https://rubygems.org'

ruby '~> 3.4' if ENV['BUNDLE_WITH'].to_s.split(/[:,\s]/).include?('heroku')

gem 'rack'
gem 'rack-session'
gem 'rackup'
gem 'hikidoc'
gem 'fastimage'
gem 'emot'
gem 'mail'
gem 'rake'
gem 'cgi'
gem 'pstore'
gem 'logger'

group :development do
  gem 'pit', require: false
  gem 'racksh', require: false
  gem 'redcarpet'
  gem 'mime-types'

  group :test do
    gem 'test-unit'
    gem 'rspec'
    gem 'capybara', require: 'capybara/rspec'
    gem 'date', '>= 3.1.1' # for compatibility of capybara
    gem 'selenium-webdriver', '< 4.45' # 4.45+ requires Ruby >= 3.3
    gem 'launchy'
    gem 'sequel'
    gem 'sqlite3'
    gem 'simplecov', require: false
    gem "rexml"
    gem "webrick"
  end
end

# Installed on Heroku (BUNDLE_WITH=heroku) and in the Docker image
# (BUNDLE_WITH=docker), see misc/paas/heroku and Dockerfile
group :heroku, :docker, optional: true do
  gem 'puma', require: false
  gem 'tdiary-contrib', git: 'https://github.com/tdiary/tdiary-contrib.git'
  gem 'tdiary-style-gfm'
  gem 'tdiary-style-rd'
  gem 'racc', require: false # rdtool needs racc, a bundled gem since Ruby 3.3
end

# Installed only on Heroku via BUNDLE_WITH=heroku
group :heroku, optional: true do
  gem 'tdiary-io-mongodb', git: 'https://github.com/tdiary/tdiary-io-mongodb.git'
  gem 'omniauth'
  gem 'omniauth-github'
  gem 'dalli'
  gem 'connection_pool'
  gem 'memcachier'
end

# https://github.com/redmine/redmine/blob/master/Gemfile#L89
local_gemfile = File.join(File.dirname(__FILE__), "Gemfile.local")
if File.exist?(local_gemfile)
  puts "Loading Gemfile.local ..." if $DEBUG # `ruby -d` or `bundle -v`
  instance_eval File.read(local_gemfile)
end
