#
# theme_convert.rb: tDiary 1.4 系用テーマを 2.0 系用に*てきとー*に変換する
#
# 使い方: $ ruby theme_convert.rb hoge.css
#         と実行すると、hoge-2.css と hoge-simple.css が作成されます。
#         hoge-2.css が 2.0 系用に変換された CSS ファイルです。
#         細かい点はその CSS ファイルを手で修正してください。
#         （hoge-simple.css は作業用の一時ファイル）
#
# Copyright (c) 2002 NT <nt@24i.net>
# Distributed under the GPL
#

=begin ChangeLog
2005-01-01 nt <nt@be.to>
	* adjusted to ruby 1.8

2003-01-19 nt <nt@be.to>
	* version 1.1.2
	* modify theme_convert().

2002-09-10 nt <nt@24i.net>
	* version 1.1.1
	* modify parse grammar.
	* add GC.start in parse_css.

2002-09-09 nt <nt@24i.net>
	* version 1.1.0
	* modify parse grammar.

2002-09-04 nt <nt@24i.net>
	* version 1.0.3
	* fix bug.

2002-09-03 nt <nt@24i.net>
	* version 1.0.2
	* enable to convert two or more files at once.

2002-09-01 nt <nt@24i.net>
	* version 1.0.1
	* modify simplify_css.
	* modify error message.

2002-08-30 nt <nt@24i.net>
	* version 1.0.0
=end

def usage
  puts "theme_convert: convert theme css file for tDiary 1.4 series to 2.0 series."
  puts "usage: ruby theme_convert.rb <css file path>"
  exit
end

require 'erb/erbl'
require 'racc/parser'

class CFParser < ::Racc::Parser

module_eval <<'..end parse.y modeval..id7aed3e8a8c', 'parse.y', 70

  def parse( f, fname )
    @fname = fname

    @q = []
    f.each do |line|
      until line.empty? do
        case line
        when /\A\s+/
          ;
        when /\A[^:"\s{}]+/
          @q.push [:IDENT, $&]
        when /\A"(?:[^"\\]+|\\.)*"/
          @q.push [:QUOTE, eval($&)]
        when /\A./
          @q.push [$&, $&]
        else
          raise RuntimeError, "must not happen"
        end
        line = $'
      end
      @q.push [:EOL, :EOL]
    end
    @q.push [false, '$']

    @lineno = 1
    @yydebug = $DEBUG
    do_parse
  end

  def next_token
    @q.shift
  end

  def on_error( t, v, _values )
    raise Racc::ParseError,
          "in #{@fname}:#{@lineno}: parse error on #{v.inspect}"
  end

..end parse.y modeval..id7aed3e8a8c

##### racc 1.4.1 generates ###

racc_reduce_table = [
 0, 0, :racc_error,
 2, 9, :_reduce_none,
 4, 10, :_reduce_2,
 3, 10, :_reduce_3,
 5, 10, :_reduce_4,
 4, 10, :_reduce_5,
 4, 14, :_reduce_6,
 3, 14, :_reduce_none,
 2, 14, :_reduce_none,
 1, 16, :_reduce_none,
 1, 16, :_reduce_none,
 1, 15, :_reduce_11,
 2, 15, :_reduce_12,
 0, 11, :_reduce_none,
 1, 11, :_reduce_none,
 1, 13, :_reduce_15,
 3, 13, :_reduce_16,
 1, 12, :_reduce_17,
 2, 12, :_reduce_18 ]

racc_reduce_n = 19

racc_shift_n = 34

racc_action_table = [
    18,    19,    24,    24,    24,     8,    26,    26,    26,    24,
    16,    14,    14,    26,     3,     3,    29,    21,     8,     3,
    15,     3,    28,     9,     3,     8,     7,    33,     3 ]

racc_action_check = [
    11,    12,    28,    23,    15,    11,    28,    23,    15,    32,
     9,     6,    17,    32,     6,    17,    20,    14,    20,    14,
     7,     5,    18,     4,    22,     2,     1,    30,     0 ]

racc_action_pointer = [
    21,    24,    18,   nil,    23,    14,     7,    17,   nil,    10,
   nil,    -2,    -1,   nil,    12,     2,   nil,     8,    19,   nil,
    11,   nil,    17,     1,   nil,   nil,   nil,   nil,     0,   nil,
    22,   nil,     7,   nil ]

racc_action_default = [
   -13,   -19,   -14,   -11,   -19,   -13,   -13,   -15,   -12,   -19,
    -1,   -14,   -19,    -3,   -13,   -19,    34,   -13,   -15,   -16,
   -14,    -8,   -13,    -2,    -9,   -17,   -10,    -5,   -19,    -7,
   -19,   -18,    -4,    -6 ]

racc_goto_table = [
    11,    10,    12,    23,    13,     5,     4,   nil,   nil,    20,
     6,   nil,    31,    12,   nil,    27,    32,    11,    30,    22,
    17,    31 ]

racc_goto_check = [
     7,     3,     3,     4,     6,     2,     1,   nil,   nil,     7,
     5,   nil,     8,     3,   nil,     6,     4,     7,     3,     2,
     5,     8 ]

racc_goto_pointer = [
   nil,     6,     5,    -4,   -12,     9,    -2,    -5,   -11 ]

racc_goto_default = [
   nil,   nil,   nil,     1,   nil,   nil,   nil,     2,    25 ]

racc_token_table = {
 false => 0,
 Object.new => 1,
 :IDENT => 2,
 ":" => 3,
 "{" => 4,
 "}" => 5,
 :QUOTE => 6,
 :EOL => 7 }

racc_use_result_var = true

racc_nt_base = 8

Racc_arg = [
 racc_action_table,
 racc_action_check,
 racc_action_default,
 racc_action_pointer,
 racc_goto_table,
 racc_goto_check,
 racc_goto_default,
 racc_goto_pointer,
 racc_nt_base,
 racc_reduce_table,
 racc_token_table,
 racc_shift_n,
 racc_reduce_n,
 racc_use_result_var ]

Racc_token_to_s_table = [
'$end',
'error',
'IDENT',
'":"',
'"{"',
'"}"',
'QUOTE',
'EOL',
'$start',
'file',
'kv_list',
'opteol',
'vals',
'idents',
'block',
'eols',
'val']

Racc_debug_parser = true

##### racc system variables end #####

 # reduce 0 omitted

 # reduce 1 omitted

module_eval <<'.,.,', 'parse.y', 11
  def _reduce_2( val, _values, result )
                result = { val[1] => val[3] }
   result
  end
.,.,

module_eval <<'.,.,', 'parse.y', 15
  def _reduce_3( val, _values, result )
                result = { val[1] => val[2] }
   result
  end
.,.,

module_eval <<'.,.,', 'parse.y', 19
  def _reduce_4( val, _values, result )
                val[0][ val[2] ] = val[4]
   result
  end
.,.,

module_eval <<'.,.,', 'parse.y', 23
  def _reduce_5( val, _values, result )
                val[0][ val[2] ] = val[3]
   result
  end
.,.,

module_eval <<'.,.,', 'parse.y', 28
  def _reduce_6( val, _values, result )
                result = val[1]
   result
  end
.,.,

 # reduce 7 omitted

 # reduce 8 omitted

 # reduce 9 omitted

 # reduce 10 omitted

module_eval <<'.,.,', 'parse.y', 38
  def _reduce_11( val, _values, result )
                @lineno += 1
   result
  end
.,.,

module_eval <<'.,.,', 'parse.y', 42
  def _reduce_12( val, _values, result )
                @lineno += 1
   result
  end
.,.,

 # reduce 13 omitted

 # reduce 14 omitted

module_eval <<'.,.,', 'parse.y', 50
  def _reduce_15( val, _values, result )
                result = val
   result
  end
.,.,

module_eval <<'.,.,', 'parse.y', 54
  def _reduce_16( val, _values, result )
                result.push val[2]
   result
  end
.,.,

module_eval <<'.,.,', 'parse.y', 59
  def _reduce_17( val, _values, result )
                result = val
   result
  end
.,.,

module_eval <<'.,.,', 'parse.y', 63
  def _reduce_18( val, _values, result )
                result.push val[1]
   result
  end
.,.,

 def _reduce_none( val, _values, result )
  result
 end

end   # class CFParser

def simplify_css ( fname )
  comment = false

  File.open( fname.sub( /\.css/i, "-simple.css" ), "w" ) do |f|
    File.open( fname, "r" ) do |file|
      file.each {|line|
        if %r[/\*] =~ line && %r[\*/] =~ line
        elsif %r[/\*] =~ line
          comment = true
        elsif %r[\*/] =~ line
          comment = false
        elsif comment == true
        else
          if /(.*)\{(.*\}?)/ =~ line
            $2 ? scnd = $2 : scnd =""
            f.puts( $1.gsub( /:/, "%" ) + "{" + scnd )
          else
            f.puts line
          end
        end
      }
    end
  end
end

def parse_css ( fname )
  result = Hash.new

  File.open( fname ) do |f|
    orig_hash = CFParser.new.parse( f, fname )
    orig_hash.each_key{|key|
      tmp = orig_hash.shift
      result[tmp[0].join(" ")] = tmp[1]
      GC.start
    }
  end

  result
end

def theme_convert ( fname, hash )

  table = [
	["p\.adminmenu ","div.adminmenu "],
	["p\.calendar ","div.calendar "],
	["span\.date ","h2 span.date "],
	["span\.title ","h2 span.title "],
	["h3\.subtitle ","h3 "],
	["p ","div.section p "],
	["p\.commenttitle ","div.comment div.caption "],
	["p\.referer ","div.referer "],
	["p\.referertitle ","div.refererlist div.caption "],
	["ul\.referer ","div.refererlist ul "],
	["p\.footer ","div.footer "],
	["blockquote ","div.body blockquote "],
	["dl ","div.body dl "],
	["dt ","div.body dt "],
	["dd ","div.body dd "],
	["div\.day span\.panchor ","div.day span.sanchor "],
  ]
  flag = false

  File.open( fname.sub( /\.css/i, "-2.css" ), "w" ) do |f|
    File.open( fname, "r" ) do |file|
      file.each {|line|
        if /\{/ =~ line
          table.each_with_index{|x, i|
            if %r[^#{x[0]}(.*?)#{x[0]}] =~ line
              f.puts x[1] + $1 + x[1] + $'
              break
            elsif %r[^#{x[0]}] =~ line
              f.puts x[1] + $'
              break
            elsif %r[span\.commentator] =~ line #元々ある span.commentator を消す
              flag = true
            elsif i == table.size - 1 && %r[^#{x[0]}] !~ line
              f.puts line
            end
          }
        else
          if flag && /\}/ =~ line #元々ある span.commentator を消す（続き）
            flag = false
          elsif flag
          else
            f.puts line
          end
        end
      }
    end 
  end

  rcss = File::readlines( "append.rcss" ).join
  File.open( fname.sub( /\.css/i, "-2.css" ), "a" ) do |f|
    f.write( ERbLight::new( rcss ).result( binding ) )
  end
end 

while cssname = ARGV.shift
  unless cssname
    usage
    exit
  end

  begin
    simplify_css( cssname )
  rescue
    File.delete( cssname.sub( /\.css/i, "-simple.css" ) ) 
    puts "Error!: #{$!}"
    next
  end

  begin
    parse_result = parse_css( cssname.sub( /\.css/i, "-simple.css" ) )
    if $CHECK
      parse_result.each{|key, val|
        print "#{key} => "
        p val
      }
    end
  rescue => parse_error
    puts "Error!: #{parse_error.message}"
    next
  end

  theme_convert( cssname, parse_result )
  puts %Q[Conversion completed: #{cssname.sub( /\.css/i, "-2.css" )} was generated.]

end
