=begin
= filter.rb
Definition of Filter structure.
=end

module RD
  class Filter
    attr_accessor :mode
    
    def initialize(mode = :target, &block)
      @mode = mode
      @block = block
    end
  
    # inn, out: RD::Part
    def call(inn)
      out = RD::Part.new("", nil, "w")
      result = @block.call(inn, out)
      if out.empty?
	result
      else
	out.to_s
      end
    end

    module FileInclude
      def find_file(file, part)
	for dir in part.tree.include_path
	  begin
	    return open(dir + "/" + file)
	  rescue
	    next
	  end
	end
	nil
      end
      module_function :find_file
    end # Filter::Include
  end # Filter
  
  # Build-in Filter
  # Simple inclusion
  INCLUDE_FILTER = Filter.new(:target) do |inn, out|
    inn.each do |line|
      out.print(line)
    end
  end

  # Simple RD inclusion
  RD_FILTER = Filter.new(:rd) do |inn, out|
    out.print("=begin\n")
    inn.each do |line|
      out.print(line)
    end
    out.print("\n=end\n")
  end
  
  # Eval ruby script
  # "out.print" to output.
  EVAL_FILTER = Filter.new(:target) do |inn, out|
    begin
      eval(inn.to_s)
    rescue
      out.print "!!Error occured when eval!!\n"
    end
  end
  
  # RD::Part is a pseudo IO class 
  class Part
    attr(:tree)
    attr_accessor :lineno
    attr_accessor :pos
    
    def initialize(content = "", tree = nil, mode = "r")
      @content = content
      if mode == "r"
	@content.freeze
      end
      @tree = tree
      @pos = 0
      @lineno = 0
      @unget = nil
    end
    
    def each_line(rs = $/)
      while line = gets
	yield(line)
      end
    end
    alias each each_line
    
    def each_byte
      while char = getc
	yield(char)
      end
    end
    
    def eof?
      @pos == @content.size
    end
    alias eof eof?

    def get_char(ex)
      ret = nil
      if @unget
	ret = @unget
      else
	unless eof?
	  ret = @content[@pos]
	  @pos += 1
	else
	  raise EOFError if ex
	end
      end
      ret
    end
    private :get_char
    
    def getc
      get_char(nil)
    end
    
    def readchar
      get_char(true)
    end
    
    def ungetc(char)
      @ungetc = char
      nil
    end
    
    def get_line(ex, rs)
      ret = nil
      unless eof?
	new_pos = @content.index(rs, @pos)
	if new_pos
	  ret = @content[@pos .. new_pos]
	  @pos = new_pos + 1
	  @lineno += 1
	else
	  ret = @content[@pos .. @content.size - 1]
	  @pos = @content.size
	  @lineno += 1
	end
      else
	raise EOFError if ex
      end
      $_ = ret
    end
    private :get_line
    
    def gets(rs = $/)
      get_line(nil, rs)
    end
    
    def readline(rs = $/)
      get_line(true, $/)
    end
    
    def read(length = @content.size - @pos)
      ret = ""
      length.times do 
	ret << getc
      end
      ret
    end
    
    def readlines(rs = $/)
      ret = []
      each_line(rs) do |line|
	ret.push(line)
      end
      ret
    end
    
    def rewind
      @pos = 0
    end
    
    def seek(offset, whence)
      case whence
      when 0
	@pos = offset
      when 1
	@pos += offset
      when 2
	@pos += @content.size - 1
      else
	raise Errno::EINVAL
      end
    end
    
    alias tell pos
    
    def << (arg)
      begin
	@content << arg.to_s
	self
      rescue
	raise IOError
      end
    end
          
    def print(*args)
      begin
	args.each do |i|
	  @content << i.to_s
	end
	nil
      rescue
	raise IOError
      end
    end
    
    def printf(format, *args)
      str = sprintf(format, *args)
      begin
	@content << str
	nil
      rescue
	raise IOError
      end
    end
    
    def putc(char)
      self.printf("%c", char)
      char
    end
    
    def puts(*args)
      args.flatten.each do |i|
	self.print(i, "\n")
      end
    end
    
    def write(str)
      @content << str.to_s
      str.to_s.size
    end
    
    def empty?
      @content.empty?
    end
    
    def to_s
      @content
    end
  end
end

=begin
== script info.
 filter structure.
 $Id: filter.rb,v 1.7 2001/03/19 15:20:08 toshirok Exp $
=end
