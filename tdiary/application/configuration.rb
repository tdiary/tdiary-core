module TDiary
	class Application
		class Configuration
			attr_accessor :assets_paths, :plugin_paths, :path

			def initialize
				@assets_paths = []
				@plugin_paths = []
				@path = {
					index: '/',
					update: '/update.rb',
					assets: '/assets'
				}
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
