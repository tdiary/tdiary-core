# Tiny Tiny eRuby --- compiler
# 	Copyright (c) 1999-2000,2002 Masatoshi SEKI 
#       You can redistribute it and/or modify it under the same term as Ruby.

class ERbCompiler
  ERbTag = "<%% %%> <%= <%# <% %>".split
  private
  def is_erb_tag?(s)
    ERbTag.member?(s)
  end

  SplitRegexp = /(<%%)|(%%>)|(<%=)|(<%#)|(<%)|(%>)|(\n)/

  public
  def pre_compile(s, trim_mode)
    re = SplitRegexp
    if trim_mode.nil? || trim_mode == 0
      list = s.split(re)
    else
      list = []
      has_cr = (s[-1] == ?\n)
      s.each do |line|
	line = line.chomp.split(re)
	line.shift if line[0]==''
	list += line
	unless ((trim_mode == 1 && line[-1] == '%>') ||
		(trim_mode == 2 && (is_erb_tag?(line[0])) && 
		 line[-1] == '%>'))
	  list.push("\n") 
	end
      end
      list.pop unless has_cr
    end
    list
  end

  def compile(s)
    list = pre_compile(s, @trim_mode)
    cmd = []
    cmd.concat(@pre_cmd)

    stag = nil
    content = []
    while (token = list.shift) 
      if token == '<%%'
	token = '<'
	list.unshift '%'
      elsif token == '%%>'
	token = '%'
	list.unshift '>'
      end
      if stag.nil?
	if ['<%', '<%=', '<%#'].include?(token)
	  stag = token
	  str = content.join
	  if str.size > 0
	    cmd.push("#{@put_cmd} #{str.dump}")
	  end
	  content = []
	elsif token == "\n"
	  content.push("\n")
	  cmd.push("#{@put_cmd} #{content.join.dump}")
	  cmd.push(:cr)
	  content = []
	else
	  content.push(token)
	end
      else
	if token == '%>'
	  case stag
	  when '<%'
	    str = content.join
	    if str[-1] == ?\n
	      str.chop!
	      cmd.push(str)
	      cmd.push(:cr)
	    else
	      cmd.push(str)
	    end
	  when '<%='
	    cmd.push("#{@put_cmd}((#{content.join}).to_s)")
	  when '<%#'
	    # cmd.push("# #{content.dump}")
	  end
	  stag = nil
	  content = []
	else
	  content.push(token)
	end
      end
    end
    if content.size > 0
      cmd.push("#{@put_cmd} #{content.join.dump}")
    end
    cmd.push(:cr)
    cmd.concat(@post_cmd)

    ary = []
    cmd.each do |x|
      if x == :cr
	ary.pop
	ary.push("\n")
      else
	ary.push(x)
	ary.push('; ')
      end
    end
    ary.join
  end

  def initialize
    @trim_mode = nil
    @put_cmd = 'print'
    @pre_cmd = []
    @post_cmd = []
  end
  attr :trim_mode, true
  attr :put_cmd, true
  attr :pre_cmd, true
  attr :post_cmd, true
end

