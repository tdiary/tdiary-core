if defined? RSpec
	require 'rspec/core/rake_task'

	desc 'Run the code in spec'
	RSpec::Core::RakeTask.new(:spec) do |t|
		t.pattern = "spec/**/*_spec.rb"
	end

	namespace :spec do
		%w(core plugin acceptance).each do |dir|
			desc "Run the code examples in spec/#{dir}"
			RSpec::Core::RakeTask.new(dir.to_sym) do |t|
				t.pattern = "spec/#{dir}/**/*_spec.rb"
			end
		end

		namespace :acceptance do
			desc 'Run the code examples in spec/acceptance with cgi mode'
			task :cgi do
				ENV['TEST_MODE'] = 'webrick'
				Rake::Task["spec:acceptance"].invoke
			end

			desc 'Run the code examples in spec/acceptance with secure mode'
			task :secure do
				ENV['TEST_MODE'] = 'secure'
				Rake::Task["spec:acceptance"].invoke
			end
		end

		desc 'Displayed code coverage with SimpleCov'
		task :coverage do
			ENV['COVERAGE'] = 'simplecov'
			Rake::Task["spec"].invoke
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
