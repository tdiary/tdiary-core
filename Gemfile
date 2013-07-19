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

group :coffee do
  gem 'coffee-script'
  gem 'therubyracer'
end

group :memcached do
  gem 'dalli'
end

group :redis do
  gem 'redis'
  gem 'redis-namespace'
end

group :gfm do
  gem 'redcarpet'
  gem 'pygments.rb'
  gem 'twitter-text', :require => false
end

group :server do
  platforms :mri do
    gem 'thin'
  end

  platforms :jruby do
    gem 'trinidad'
  end
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
