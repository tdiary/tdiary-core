# Tiny Tiny eRuby --- ERbLight
# 	Copyright (c) 1999-2000 Masatoshi SEKI 
#       You can redistribute it and/or modify it under the same term as Ruby.
# 	$Id: erbl.rb,v 1.1.1.1 2001/06/08 06:09:39 spc Exp $
# 	$Author: spc $

require 'erb/compile'

class ERbLight
  Revision = '$Date: 2001/06/08 06:09:39 $'

  def self.version
    "erbl.rb [1.3.3 #{ERbLight::Revision.split[1]}]"
  end

  def initialize(str, safe_level=nil, trim_mode=nil, eoutvar='_erbout')
    @safe_level = safe_level
    compiler = ERbCompiler.new
    compiler.trim_mode = trim_mode
    set_eoutvar(compiler, eoutvar)
    @src = compiler.compile(str)
  end
  attr :src

  def set_eoutvar(compiler, eoutvar = '_erbout')
    compiler.put_cmd = "#{eoutvar}.concat"

    cmd = []
    cmd.push 'begin'
    cmd.push("$SAFE = #{@safe_level}") if @safe_level
    cmd.push "#{eoutvar} = ''"
    
    compiler.pre_cmd = cmd

    cmd = []
    cmd.push('ensure')
    cmd.push(eoutvar)
    cmd.push('end')

    compiler.post_cmd = cmd
  end

  def run(b=TOPLEVEL_BINDING)
    print self.result(b)
  end

  def result(b=TOPLEVEL_BINDING)
    if @safe_level
      th = Thread.start { 
	eval(@src, b)
      }
      return th.value
    else
      return eval(@src, b)
    end
  end
end

if __FILE__ == $0
  require 'erb/main'

  ERbModule.run(ERbLight)
end
