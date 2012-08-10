require 'rd/search-file'

module RD
  class RBLFile
    include SearchFile

    SUFFIX = "rbl"
    attr_reader :labels
    attr_reader :filename

    def initialize(filename)
      @filename = RBLFile.basename(filename)
      @labels = []
    end

    def RBLFile.create_rbl_file(filename, resolver)
      file = File.open(RBLFile.rbl_file_path(filename), "w")
      file.print(RBLFile.labels_to_string(resolver))
      file.close
    end

    def RBLFile.rbl_file_path(filename)
      basename(filename) + "." + SUFFIX
    end

    def RBLFile.basename(path)
      if /\.(rd|rb)$/ === path
	$`
      else
	path
      end
    end
    
    def RBLFile.labels_to_string(resolver)
      (resolver.collect do |i|
	 i.to_label + " => " + resolver.get_anchor(i)
       end).join("\n")
    end

    def load_rbl_file(search_paths)
      f = search_file(@filename, search_paths, [SUFFIX])
      raise "RBLFile not found." unless f
      src = File.readlines(f).join("")
      @labels = string_to_labels(src)
    end
		   
    def string_to_labels(src)
      labels = []
      src.each_line do |i|
	labels << parse_line(i)
      end
      labels
    end

    def parse_line(src)
      col = src.rindex("=>")
      raise "RBL file parse error." unless col
      label = src[0 .. col - 1].strip
      anchor = src[col + 2 .. -1].strip
      [label, anchor]
    end

    def refer(label)
      label = @labels.find{|i| i[0] == label}
      return nil unless label
      label[1]
    end
  end
end
