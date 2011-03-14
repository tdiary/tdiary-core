require "rd/rbl-file"

module RD
  class RBLSuite
    attr_reader :rbl_files
    
    def initialize(search_paths)
      @search_paths = search_paths
      @rbl_files = []
    end

    def refer(label, filename)
      rbl = get_rbl_file(filename)
      [rbl.filename, rbl.refer(label)]
    end

    def get_rbl_file(filename)
      rbl = @rbl_files.find{|i| i.filename == RBLFile.basename(filename)}
      if rbl
	rbl
      else
	add_rbl_file(filename)
      end
    end
      
    def add_rbl_file(filename)
      rbl = RBLFile.new(filename)
      begin
	rbl.load_rbl_file(@search_paths)
      rescue RuntimeError
      ensure
	@rbl_files.push(rbl)
      end
      rbl
    end
  end
end
