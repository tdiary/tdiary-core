require 'spec_helper'

Dir["#{File.dirname(__FILE__)}/acceptance/support/**/*.rb"].each {|f| require f}

require 'tdiary/application'
Capybara.app = Rack::Builder.new do
	map '/' do
		run TDiary::Dispatcher.index
	end

	map '/index.rb' do
		run TDiary::Dispatcher.index
	end

	map '/update.rb' do
		run TDiary::Dispatcher.update
	end
end

# FIXME: TDiary::Application has auth middleware in update.rb, so it cannot be tested.
# Capybara.app = TDiary::Application.new

Capybara.save_and_open_page_path = File.dirname(__FILE__) + '/../tmp/capybara'

RSpec.configure do |config|
	fixture_conf = File.expand_path('../fixtures/just_installed.conf', __FILE__)
	work_data_dir = File.expand_path('../../tmp/data', __FILE__)

	tdiary_conf = File.expand_path("../fixtures/tdiary.conf.#{ENV['TEST_MODE'] || 'rack'}", __FILE__)
	work_conf = File.expand_path('../../tdiary.conf', __FILE__)

	config.before(:all) do
		FileUtils.cp_r tdiary_conf, work_conf, :verbose => false
	end

	config.after(:all) do
		FileUtils.rm_rf work_conf
	end

	config.before(:each) do
		FileUtils.mkdir_p work_data_dir
	end

	config.after(:each) do
		FileUtils.rm_rf work_data_dir
	end

	if ENV['TEST_MODE'] == 'rdb'
		work_db = 'sqlite://tmp/tdiary_test.db'
		config.before(:each) do
			Sequel.connect(work_db) do |db|
				db.drop_table(:conf) if db.table_exists?(:conf)
				db.create_table :conf do
					String :body, :text => true
				end
				db[:conf].insert(:body => File.read(fixture_conf))
			end
		end

		config.after(:each) do
			Sequel.connect(work_db) do |db|
				[:diaries, :comments, :conf].each do |table|
					db.drop_table(table) if db.table_exists? table
				end
			end
			Dalli::Client.new(nil, {:namespace => 'test'}).flush
		end
	else
		config.before(:each) do
			FileUtils.cp_r(fixture_conf, File.join(work_data_dir, "tdiary.conf"), :verbose => false) unless fixture_conf.empty?
		end

		config.after(:each) do
			FileUtils.rm_r File.join(work_data_dir, "tdiary.conf")
		end
	end

	if ENV['TEST_MODE'] == 'webrick'
		Capybara.default_driver = :selenium
		Capybara.app_host = 'http://localhost:' + (ENV['PORT'] || '19292')
	end

	excludes = case ENV['TEST_MODE']
				  when 'webrick'
					  [:exclude_selenium, :exclude_no_secure]
				  when 'secure'
					  [:exclude_rack, :exclude_secure]
				  when 'rdb'
					  [:exclude_rdb, :exclude_rack, :exclude_no_secure]
				  else
					  # TEST_MODE = rack
					  [:exclude_rack, :exclude_no_secure]
				  end
	excludes.each do |exclude|
		config.filter_run_excluding exclude
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
