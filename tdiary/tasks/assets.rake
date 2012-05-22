namespace :assets do
	desc "compile coffeescript"
	task :compile do
		require 'coffee-script'
		FileList['js/**/*.coffee'].each do |coffee|
			File.open(coffee.sub(/\.coffee\z/, '.js'), 'w') do |js|
				js.write CoffeeScript.compile(File.read(coffee))
			end
		end
	end

	desc "copy assets files"
	task :copy do
		require 'fileutils'
		assets_path = File.dirname(__FILE__) + '/public/assets'
		FileUtils.mkdir_p assets_path unless FileTest.exist? assets_path

		FileList['{js,theme}/*'].each do |file|
			FileUtils.cp_r(file, "#{assets_path}/#{Pathname.new(file).basename}")
		end
	end
end
