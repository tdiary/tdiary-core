namespace :assets do
	if defined? CoffeeScript
		desc "compile coffeescript"
		task :compile do
			FileList['js/**/*.coffee'].each do |coffee|
				File.open(coffee.sub(/\.coffee\z/, '.js'), 'w') do |js|
					js.write CoffeeScript.compile(File.read(coffee))
				end
			end
		end
	end

	desc "copy assets files"
	task :copy do
		require 'fileutils'
		assets_path = File.dirname(__FILE__) + '/../../../public/assets'

		FileUtils.mkdir_p assets_path
		FileList['{js,theme}/*'].each do |file|
			FileUtils.cp_r(file, "#{assets_path}/#{Pathname.new(file).basename}")
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
