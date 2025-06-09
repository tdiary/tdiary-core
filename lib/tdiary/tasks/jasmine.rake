begin
	require_relative "../../rack/server"
	
	desc "Run JavaScript tests with Jasmine"
	task :jasmine do
		puts "Running JavaScript tests with npm jasmine..."
		system("npm test") || abort("JavaScript tests failed")
	end
rescue LoadError
	task :jasmine do
		abort "Node.js and npm are required to run JavaScript tests. Please install Node.js and run 'npm install'"
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
