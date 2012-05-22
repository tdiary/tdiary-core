unless ENV['RACK_ENV'] == 'production'
	Bundler.require :test
	require 'rake/testtask'
	require 'ci/reporter/rake/test_unit'

	Rake::TestTask.new do |t|
		t.libs << "test"
		t.test_files = FileList['test/**/*_test.rb']
		t.verbose = true
	end
end
