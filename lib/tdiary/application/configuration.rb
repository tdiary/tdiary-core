module TDiary
	class Application
		class Configuration
			attr_accessor :assets_precompile, :plugin_paths, :path, :builder_procs, :authenticate_proc

			def initialize
				# if you need to auto compilation for CoffeeScript
				@assets_precompile = false;
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

			def assets_paths
				TDiary::Extensions::constants.map {|extension|
					TDiary::Extensions::const_get( extension ).assets_path
				}.flatten.uniq
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
