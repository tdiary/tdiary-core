
module RD
  module SearchFile
    def search_file(base, include_path, suffixes)
      include_path.each do |dir|
	suffixes.each do |suffix|
	  file = dir + "/" + base + "." + suffix
	  return file if File.exist? file
	end
      end
      nil
    end
  end
end
