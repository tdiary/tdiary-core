# Tiny Tiny eRuby --- compiler
# 	Copyright (c) 1999-2000 Masatoshi SEKI 
#       You can redistribute it and/or modify it under the same term as Ruby.
#	$Id: compile.rb,v 1.1.1.1 2001/06/08 06:09:39 spc Exp $
# 	$Author: spc $

class ERbCompiler
  ERbTag = "<%% %%> <%= <%# <% %>".split
  private
  def self.is_erb_tag?(s)
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
	  content.join.each do |line|
	    cmd.push("#{@put_cmd} #{line.dump}")
	  end
	  content = []
	else
	  content.push(token)
	end
      else
	if token == '%>'
	  content = content.join
	  case stag
	  when '<%'
	    cmd.push(content)
	  when '<%='
	    cmd.push("#{@put_cmd}((#{content}).to_s)")
	  when '<%#'
	    #	  cmd.push('=begin')
	    #	  cmd.push(content)
	    #	  cmd.push('=end')
	    cmd.push("# #{content.dump}")
	  end
	  stag = nil
	  content = []
	else
	  content.push(token)
	end
      end
    end
    content.join.each do |line|
      cmd.push("#{@put_cmd} #{line.dump}")
    end
    cmd.concat(@post_cmd)
    cmd.join("\n")
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

