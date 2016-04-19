#
# search-default.rb - site search plugin sample using DefaultIO.
#
# Copyright (C) 2003-2005 Minero Aoki
# Copyright (C) 2012, TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL2 or any later version.
#
#

def search_title
	'全文検索'
end

class WrongQuery < StandardError; end

module DefaultIOSearch

	module_function
	def setup_patterns(query)
		patterns = split_string(query).map {|pat|
			check_pattern pat
			Regexp.new( Regexp.quote(pat), Regexp::IGNORECASE )
		}
		raise WrongQuery, 'no pattern' if patterns.empty?
		raise WrongQuery, 'too many sub patterns' if patterns.length > 8
		patterns
	end

	def check_pattern(pat)
		raise WrongQuery, 'no pattern' unless pat
		raise WrongQuery, 'empty pattern' if pat.empty?
		raise WrongQuery, "pattern too short: #{pat}" if pat.length < 2
		raise WrongQuery, 'pattern too long' if pat.length > 128
	end

	def split_string(str)
		str.split(/[\s　]+/ou).reject {|w| w.empty? }
	end

	INF = 1 / 0.0

	def match_components(patterns, data_path)
		foreach_diary_from_latest(data_path) do |diary|
			next unless diary.visible?
			num = 1
			diary.each_section do |sec|
				if patterns.all? {|re| re =~ sec.to_src }
					yield diary, fragment('p', num), sec
				end
				num += 1
			end
			diary.each_visible_comment(INF) do |cmt, num|
				if patterns.all? {|re| re =~ cmt.body }
					yield diary, fragment('c', num), cmt
				end
			end
		end
	end

	def fragment(type, num)
		sprintf('%s%02d', type, num)
	end

	#
	# tDiary Implementation Dependent
	#
	def foreach_diary_from_latest(data_path, &block)
		foreach_data_file(data_path.sub(%r</+\z>, '')) do |path|
			read_diaries(path).sort_by {|diary| diary.date }.reverse_each(&block)
		end
	end

	def foreach_data_file(data_path, &block)
		Dir.glob("#{data_path}/[0-9]*/*.td2").sort.reverse_each do |path|
			yield path.untaint
		end
	end

	def read_diaries(path)
		d = nil
		diaries = {}
		load_tdiary_textdb(path) do |header, body|
			begin
				d = diary_class(header['Format']).new(header['Date'], '', body)
			rescue ArgumentError
				next
			end
			d.show(header['Visible'] != 'false')
			diaries[d.ymd] = d
		end
		(Years[d.y] ||= []).push(d.m) if d
		load_comments diaries, path
		diaries.values
	end

	DIARY_CLASS_CACHE = {}

	def diary_class(style)
		c = DIARY_CLASS_CACHE[style]
		return c if c
		if TDiary.const_defined?('Style')
			require "tdiary/style/#{style.downcase}.rb"
			c = eval("TDiary::Style::#{style.capitalize}Diary")
		else
			require "tdiary/style/#{style.downcase}_style.rb"
			c = eval("TDiary::#{style.capitalize}Diary")
		end
		c.__send__(:include, DiaryClassDelta)
		DIARY_CLASS_CACHE[style] = c
		c
	end

	module DiaryClassDelta
		def ymd
			date().strftime('%Y%m%d')
		end

		def y_m_d
			date().strftime('%Y-%m-%d')
		end

		def y
			'%04d' % date().year
		end

		def m
			'%02d' % date().month
		end
	end

	def load_comments(diaries, path)
		cmtfile = path.sub(/2\z/, 'c')
		return unless File.file?(cmtfile)
		load_tdiary_textdb(cmtfile) do |header, body|
			c = TDiary::Comment.new(header['Name'], header['Mail'], body,
															Time.at(header['Last-Modified'].to_i))
			c.show = (header['Visible'] != 'false')
			d = diaries[header['Date']]
			d.add_comment c if d
		end
	end

	def load_tdiary_textdb(path)
		File.open(path) {|f|
			ver = f.gets.strip
			raise "unkwnown format: #{ver}" unless ver == 'TDIARY2.00.00' or ver == 'TDIARY2.01.00'
			f.each('') do |header|
				h = {}
				header.untaint.strip.each_line do |line|
					begin
						n, v = *line.split(':', 2)
					rescue ArgumentError
						next
					end
					h[n.strip] = v.strip
				end
				body = f.gets("\n.\n").chomp(".\n").untaint
				yield h, body
			end
		}
	end

	def short_html(component)
		# Section classes do not have common superclass, we can't use class here.
		case component.class.name
		when /Section/
			section = component
			if section.subtitle
				sprintf('%s<br>%s',
					tdiary2text(section.subtitle_to_html),
					tdiary2text(section.body_to_html))
			else
				tdiary2text(section.body_to_html)
			end
		when /Comment/
			cmt = component
			shorten(escape((cmt.name + ': ' + cmt.body)))
		else
			raise "must not happen: #{component.class}"
		end
	end

	def tdiary2text(html)
		re = Regexp.new('<[^>]*>', Regexp::EXTENDED)
		shorten(apply_tdiary_plugins(html).gsub(re, ''))
	end

	Years = {}

	TDiary::Plugin.__send__(:public, :apply_plugin)
	def apply_tdiary_plugins(html)
		#@plugin.apply_plugin(html, false)
		html
	end

	@plugin = nil

	#
	# Utils
	#
	HTML_ESCAPE_TABLE = {
		'&' => '&amp;',
		'<' => '&lt;',
		'>' => '&gt;',
		'"' => '&quot;'
	}

	def escape(str)
		tbl = HTML_ESCAPE_TABLE
		str.gsub(/[&"<>]/) {|ch| tbl[ch] }
	end

	def shorten(str, len = 200)
		matched = str.gsub( /\n/, ' ' ).scan( /^.{0,#{len - 3}}/u )[0]
		if $'.nil? || $'.empty?
			matched
		else
			matched + '...'
		end
	end
end

def search_input_form( q )
	<<-HTML
		<form method="GET" action="#{@conf.index}"><div>
			検索キーワード:
			<input name="q" value="#{h q}">
			<input type="submit" value="OK">
		</div></form>
	HTML
end

def search_result
	unless @conf.io_class == (TDiary.const_defined?('DefaultIO') ? TDiary::DefaultIO : TDiary::IO::Default)
		return %Q|<p class="message">could not use this plugin under #{@conf.io_class}.</p>|
	end

	query = CGI::unescape( @cgi.params['q'][0] )

	begin
		patterns = DefaultIOSearch::setup_patterns(query)
		r = search_input_form( query )

		r << '<dl class="search-result autopagerize_page_element">'
		count = 0
		too_many = false
		DefaultIOSearch::match_components(patterns, @conf.data_path) do |diary, fragment, component|
			count += 1
			if count > 50 # TO MANY HITS
				too_many = true
				break
			end
			href = @conf.index + anchor( "#{diary.ymd}#{fragment}" )
			r << %Q|<dt><a href="#{href}">#{h diary.y_m_d}</a></dt>|
			r << %Q|<dd>#{DefaultIOSearch::short_html(component)}</dd>|
		end
		r << '</dl>'

		r << '<div class="search-navi">'
		r << "<p>#{too_many ? 'too many' : count} hits.</p>"
		r << '</div>'

		r
	rescue WrongQuery
		search_input_form( query ) + %Q|<p class="message">#{$!.message}</p>|
	end
end
