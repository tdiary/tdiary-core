source 'https://rubygems.org'

if File.exist?('tdiary.gemspec')
	# directly installed (e.g. git clone, archive file)
	gemspec
else
	# installed by gem
	gem 'tdiary'

	# use edge tDiary
	# gem 'tdiary', :git => 'git@github.com:tdiary/tdiary-core.git'
end

# if you use tdiary-contrib gem, uncomment this line.
# gem 'tdiary-contrib'
# use edge tDiary contrib
# gem 'tdiary-contrib', :git => 'git@github.com:tdiary/tdiary-contrib.git'

gem 'sprockets'
gem 'coffee-script', :group => [:development, :test]

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
    gem 'coveralls', :require => false
  end
end
