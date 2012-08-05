# -*- coding: utf-8 -*-
require 'coffee-script'
require 'fileutils'

module TDiary
	module Rack
		module Assets
			class Precompile
				def initialize(app, environment = nil)
					@app = app
					@environment = environment
				end

				def call( env )
					@environment.each_file do |script|
						next unless script.to_s =~ /\.coffee\z/
						js_path = Pathname.new(script.to_s.gsub(/\.coffee\z/, '.js'))

						if !FileTest.exist?(js_path) || FileUtils.uptodate?(script, [js_path])
							File.open(js_path, 'w') do |js|
								js.write CoffeeScript.compile(File.read(script))
							end
						end
					end if @environment
					@app.call( env )
				end
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
