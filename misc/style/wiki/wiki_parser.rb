# wiki_parser.rb: Wiki parser for tDiary style $Revision: 1.8 $
#
# Copyright (C) 2003, TADA Tadashi <sho@spc.gr.jp>
# You can distribute this under GPL.
#

class WikiParser
	class ParserQueue < Array
		def <<( s )
			$stderr.puts s if $DEBUG
			super( s )
		end
	end

	# opt is a Hash.
	#
	#     key  |    value    |      mean       |default 
	# ---------+-------------+-----------------+---------
	# :wikiname|true or false|parse WikiName   | true
	# :url     |true or false|make URL to link | true
	# :plugin  |true or false|parse plugin     | true
	# :absolute|true or false|only absolute URL| false
	#
	def initialize( opt = {} )
		@opt = {    # set default
			:wikiname => true,
			:url => true,
			:plugin => true,
			:absolute => false,
		}
		@opt.update( opt )
	end

	def parse( f )
		@q = ParserQueue::new
		nest = 0
		f.each do |l|
			l.sub!( /[\r\n]+\Z/, '' )
			case l
			when /^$/ # null string
				@q << nil unless @q.last == nil

			when /^----+$/ # horizontal bar
				@q << :RS << :RE

			when /^(!{1,5})\s*(.*)/ # headings
				eval( "@q << :HS#{$1.size}" )
				inline( $2 )
				eval( "@q << :HE#{$1.size}" )

			when /^([\*#]{1,3})\s*(.*)/ # list
				r, depth = $2, $1.size
				style = $1[0] == ?* ? 'U' : 'O'
				nest = 0 unless /^[UO]E$/ =~ @q.last.to_s
				tmp = []
				if nest < depth then
					(nest * 2).times do tmp << @q.pop end
					eval( "@q << :#{style}S << :LS" )
					inline( r )
					eval( "@q << :LE << :#{style}E" )
				elsif nest > depth
					(depth * 2 - 1).times do tmp << @q.pop end
					@q << :LS
					inline( r )
					@q << :LE
				else
					(nest * 2 - 1).times do tmp << @q.pop end
					@q << :LS
					inline( r )
					@q << :LE
				end
				@q << tmp.pop while tmp.size != 0
				nest = depth

			when /^:([^:]+):(.*)/ # definition list
				if @q.last == :DE then
					@q.pop
				else
					@q << :DS
				end
				@q << :DTS
				inline( $1 )
				@q << :DTE << :DDS
				inline( $2 )
				@q << :DDE << :DE

			when /^""$/ # block quote (null line)
				if @q.last == :QE then
					@q.pop
				else
					@q << :QS
				end
				@q << :PS << :PE << :QE

			when /^""\s*(.*)/ # block quote
				if @q.last == :QE then
					@q.pop
					@q.pop
				else
					@q << :QS << :PS
				end
				inline( $1 + "\n" )
				@q << :PE << :QE

			when /^\s(.*)/ # formatted text
				if @q.last == :FE then
					@q.pop
				else
					@q << :FS
				end
				@q << ( $1 + "\n" ) << :FE

			when /^\|\|(.*)/ # table
				if @q.last == :TE then
					@q.pop
					@q << :TRS
				else
					@q << :TS << :TRS
				end
				$1.split( /\|\|/ ).each do |s|
					@q << :TDS
					inline( s )
					@q << :TDE
				end
				@q << :TRE << :TE

			else # paragraph
				if @q.last == :PE then
					@q.pop
				else
					@q << :PS
				end
				inline( l )
				@q << :PE
			end
		end
		@q.compact!
		@q
	end

	private
	def inline( l )
		if @opt[:plugin] then
			r = /(.*?)(\[\[|\]\]|\{\{.*?\}\}|'''|''|==)/
		else
			r = /(.*?)(\[\[|\]\]|'''|''|==)/
		end
		a = l.scan( r ).flatten
		tail = a.size == 0 ? l : $'
		stat = []
		a.each do |i|
			case i
			when '[['
				@q << :KS
				stat.push :KE
			when ']]'
				@q << stat.pop
			when "'''"
				if stat.last == :SE then
					@q << stat.pop
				else
					@q << :SS
					stat.push :SE
				end
			when "''"
				if stat.last == :EE then
					@q << stat.pop
				else
					@q << :ES
					stat.push :EE
				end
			when "=="
				if stat.last == :ZE then
					@q << stat.pop
				else
					@q << :ZS
					stat.push :ZE
				end
			else
				if @opt[:plugin] and /^\{\{(.*)\}\}$/ =~ i then
					@q << :GS << $1 << :GE
				elsif stat.last == :KE
					@q << i
				else
					url( i ) if i.size > 0
				end
			end
		end
		url( tail ) if tail
	end

	def url( l )
		unless @opt[:url]
			@q << l
			return
		end

		r = %r<(((https?|ftp):[\(\)%#!/0-9a-zA-Z_$@.&+-,'"*=;?:~-]+)|([0-9a-zA-Z_.-]+@[\(\)%!0-9a-zA-Z_$.&+-,'"*-]+\.[\(\)%!0-9a-zA-Z_$.&+-,'"*-]+))>
		a = l.gsub( r ) {
			if $1 == $2 then
				url = $2
				if %r<^(https?|ftp)(://)?$> =~ url then
					url
				elsif %r<^(https?|ftp)://> =~ url
					"[[#{url}]]"
				else
					if @opt[:absolute] then
						url
					else
						"[[#{url.sub( /^(https?|ftp):/, '' )}]]"
					end
				end
			else
				"[[mailto:#$4]]"
			end
		}.scan( /(.*?)(\[\[|\]\])/ ).flatten
		tail = a.size == 0 ? l : $'
		a.each do |i|
			case i
			when '[['
				@q << :XS
			when ']]'
				@q << :XE
			else
				if @q.last == :XS then
					@q << i
				else
					wikiname( i )
				end
			end
		end
		wikiname( tail ) if tail
	end

	def wikiname( l )
		unless @opt[:wikiname]
			@q << l
			return
		end

		l.gsub!( /[A-Z][a-z0-9]+([A-Z][a-z0-9]+)+/, '[[\0]]' )
		a = l.scan( /(.*?)(\[\[|\]\])/ ).flatten
		tail = a.size == 0 ? l : $'
		a.each do |i|
			case i
			when '[['
				@q << :KS
			when ']]'
				@q << :KE
			else
				@q << i
			end
		end
		@q << tail if tail
	end
end

if $0 == __FILE__
	$DEBUG = true
	p WikiParser::new( :wikiname => true, :plugin => true ).parse( DATA )
end

__END__
:a:aaaa
:b:bbbb
