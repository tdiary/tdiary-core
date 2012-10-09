if defined? RSpec
	require 'rspec/core/rake_task'
	require 'ci/reporter/rake/rspec'

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

			desc 'Run the code examples in spec/acceptance with RdbIO mode'
			task :rdb do
				ENV['TEST_MODE'] = 'rdb'
				Rake::Task["spec:acceptance"].invoke
			end
		end

		if defined?(Rcov)
			desc 'Run the code in specs with RCov'
			RSpec::Core::RakeTask.new(:report) do |t|
				t.pattern = "spec/**/*_spec.rb"
				t.rcov = true
				t.rcov_opts = IO.readlines(File.join('spec', 'rcov.opts')).map {|line| line.chomp.split(" ") }.flatten
			end
		else
			desc 'Displayed code coverage with SimpleCov'
			task :report do
				ENV['COVERAGE'] = 'simplecov'
				Rake::Task["spec"].invoke
			end
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
