#
# theme_convert.rb: tDiary 1.4 系用テーマを 1.5 系用に*てきとー*に変換する
#
# 使い方: $ ruby theme_convert.rb hoge.css
#         と実行すると、hoge-2.css と hoge-simple.css が作成されます。
#         hoge-2.css が 1.5 系用に変換された CSS ファイルです。
#         細かい点はその CSS ファイルを手で修正してください。
#         （hoge-simple.css は作業用の一時ファイル）
#
# Copyright (c) 2002 NT <nt@24i.net>
# Distributed under the GPL
#

=begin ChangeLog
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
  puts "theme_convert: convert theme css file for tDiary 1.4 series to 1.5 series."
  puts "usage: ruby theme_convert.rb <css file path>"
  exit
end

require 'erb/erbl'
require 'racc/parser'

class CFParser < ::Racc::Parser

module_eval <<'..end parse.y modeval..iddbaf372cc6', 'parse.y', 68

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

..end parse.y modeval..iddbaf372cc6

##### racc 1.4.1 generates ###

racc_reduce_table = [
 0, 0, :racc_error,
 2, 9, :_reduce_none,
 4, 10, :_reduce_2,
 3, 10, :_reduce_3,
 5, 10, :_reduce_4,
 4, 10, :_reduce_5,
 4, 14, :_reduce_6,
 1, 16, :_reduce_none,
 1, 16, :_reduce_none,
 1, 15, :_reduce_9,
 2, 15, :_reduce_10,
 0, 11, :_reduce_none,
 1, 11, :_reduce_none,
 1, 13, :_reduce_13,
 3, 13, :_reduce_14,
 1, 12, :_reduce_15,
 2, 12, :_reduce_16 ]

racc_reduce_n = 17

racc_shift_n = 31

racc_action_table = [
    12,    19,    21,    21,    21,    10,    24,    24,    24,    21,
    18,    16,    16,    24,     4,     4,    14,     4,    11,    25,
     4,    10,     8,     4,     4,    30 ]

racc_action_check = [
     7,    12,    27,    22,    14,     7,    27,    22,    14,    19,
    11,    13,     9,    19,    13,     9,     8,     0,     5,    15,
    16,     3,     2,    26,     1,    29 ]

racc_action_pointer = [
    10,    17,    20,    14,   nil,    18,   nil,    -2,    13,     8,
   nil,    10,    -2,     7,     2,    17,    13,   nil,   nil,     7,
   nil,   nil,     1,   nil,   nil,   nil,    16,     0,   nil,    20,
   nil ]

racc_action_default = [
   -11,   -11,   -17,   -12,    -9,   -17,    -1,   -12,   -13,   -11,
   -10,   -17,   -13,   -11,   -17,   -17,   -11,    -3,    31,   -17,
    -5,    -7,    -2,   -15,    -8,   -14,   -11,    -4,   -16,   -17,
    -6 ]

racc_goto_table = [
     7,     6,     1,    22,     5,    28,     9,   nil,    27,    15,
    28,    13,    17,    15,   nil,   nil,    20,   nil,    26,   nil,
   nil,   nil,   nil,   nil,   nil,     7,    29 ]

racc_goto_check = [
     7,     3,     2,     4,     1,     8,     5,   nil,     4,     3,
     8,     5,     6,     3,   nil,   nil,     6,   nil,     2,   nil,
   nil,   nil,   nil,   nil,   nil,     7,     3 ]

racc_goto_pointer = [
   nil,     4,     2,     0,   -11,     4,     3,    -1,   -17 ]

racc_goto_default = [
   nil,   nil,   nil,     2,   nil,   nil,   nil,     3,    23 ]

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

module_eval <<'.,.,', 'parse.y', 36
  def _reduce_9( val, _values, result )
                @lineno += 1
   result
  end
.,.,

module_eval <<'.,.,', 'parse.y', 40
  def _reduce_10( val, _values, result )
                @lineno += 1
   result
  end
.,.,

 # reduce 11 omitted

 # reduce 12 omitted

module_eval <<'.,.,', 'parse.y', 48
  def _reduce_13( val, _values, result )
                result = val
   result
  end
.,.,

module_eval <<'.,.,', 'parse.y', 52
  def _reduce_14( val, _values, result )
                result.push val[2]
   result
  end
.,.,

module_eval <<'.,.,', 'parse.y', 57
  def _reduce_15( val, _values, result )
                result = val
   result
  end
.,.,

module_eval <<'.,.,', 'parse.y', 61
  def _reduce_16( val, _values, result )
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

  File.open( fname.sub( /\.css/, "-simple.css" ), "w" ) do |f|
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
    }
  end

  result
end

def theme_convert ( fname, hash )

  table = [
	["p\.adminmenu ","div.adminmenu {"],
	["p\.calendar ","div.calendar {"],
	["span\.date ","h2 span.date {"],
	["span\.title ","h2 span.title {"],
	["h3\.subtitle ","h3 {"],
	["p ","div.section p {"],
	["p\.commenttitle ","div.comment div.caption {"],
	["p\.referer ","div.referer {"],
	["p\.referertitle ","div.refererlist div.caption {"],
	["ul\.referer ","div.refererlist ul {"],
	["p\.footer ","div.footer {"],
	["blockquote ","div.body blockquote {"],
	["dl ","div.body dl {"],
	["dt ","div.body dt {"],
	["dd ","div.body dd {"],
	["div\.day span\.panchor ","div.day span.sanchor {"],
  ]
  flag = false

  File.open ( fname.sub( /\.css/, "-2.css" ), "w" ) do |f|
    File.open( fname, "r" ) do |file|
      file.each {|line|
        if /\{/ =~ line
          table.each_with_index{|x, i|
            if %r[^#{x[0]}] =~ line
              f.puts x[1]
              break
            elsif %r[span\.commentator] =~ line #元々ある span.commentator を消す
              flag = true
            elsif i == table.size - 1 && %r[^#{x[0]}] !~ line
              f.puts line
            end
          }
        else
          if flag && /}/ =~ line #元々ある span.commentator を消す（続き）
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
  File.open ( fname.sub( /\.css/, "-2.css" ), "a" ) do |f|
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
    File.delete( cssname.sub( /\.css/, "-simple.css" ) ) 
    puts "Error!: #{$!}"
    next
  end

  begin
    parse_result = parse_css( cssname.sub( /\.css/, "-simple.css" ) )
    if $CHECK
      parse_result.each{|key, val|
        print "#{key} => "
        p val
      }
    end
  rescue => parse_error
    puts "Error!: #{parse_error.message}"
    if /\}/ =~ parse_error.message
      puts "  Are there empty blocks in your css? Check your css file."
    end
    next
  end

  theme_convert( cssname, parse_result )
  puts %Q[Conversion completed: #{cssname.sub( /\.css/, "-2.css" )} was generated.]

end
