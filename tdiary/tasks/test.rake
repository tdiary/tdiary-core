if defined? Test::Unit
	require 'rake/testtask'

	Rake::TestTask.new do |t|
		t.libs << "test"
		t.test_files = FileList['test/**/*_test.rb']
		t.verbose = true
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
