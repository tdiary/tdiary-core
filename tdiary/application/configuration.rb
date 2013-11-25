module TDiary
	class Application
		class Configuration
			attr_accessor :assets_paths, :plugin_paths, :path, :builder_procs, :authenticate_proc

			def initialize
				@assets_paths = []
				@plugin_paths = []
				@path = {
					index: '/',
					update: '/update.rb',
					assets: '/assets'
				}
				@builder_procs = []
				@authenticate_proc = proc { }
			end

			def builder(&block)
				@builder_procs << block
			end

			def authenticate(middleware, *params, &block)
				@authenticate_proc = proc { use middleware, *params, &block }
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
