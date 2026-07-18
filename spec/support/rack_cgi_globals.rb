# RackCGI reads the request from the $RACK_ENV and $stdin globals set up by
# TDiary::Dispatcher#call. Specs faking them must restore the originals.
RSpec.shared_context 'preserving RackCGI globals' do
	around do |example|
		orig_stdin = $stdin
		orig_rack_env = $RACK_ENV
		begin
			example.run
		ensure
			$stdin = orig_stdin
			$RACK_ENV = orig_rack_env
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
