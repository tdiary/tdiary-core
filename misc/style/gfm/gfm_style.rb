# -*- coding: utf-8; -*-
#
# gfm_style.rb: "GitHub Flavored Markdown" (GFM) style for tDiary 2.x format.
#
# if you want to use this style, add @style into tdiary.conf below:
#
#    @style = 'GFM'
#
# Copyright (C) 2003, TADA Tadashi <sho@spc.gr.jp>
# Copyright (C) 2004, MoonWolf <moonwolf@moonwolf.com>
# Copyright (C) 2012, kdmsnr <kdmsnr@gmail.com>
# Copyright (C) 2013, hsbt <shibata.hiroshi@gmail.com>
# You can distribute this under GPL.
#

$KCODE = 'u' if RUBY_VERSION < '1.9'

begin
	require 'rubygems'
rescue LoadError
ensure
	require 'redcarpet'
	require 'twitter-text'
end

class HTMLwithPygments < Redcarpet::Render::HTML
	def block_code(code, language)
		require 'pygments'
		Pygments.highlight(code, :lexer => language)
	rescue Exception
		<<-HTML
<div class="highlight"><pre>#{code}</pre></div>
		HTML
	end
end

module TDiary
	class GfmSection
		include SectionBase
		include Twitter::Autolink

		def initialize(fragment, author = nil)
			@author = author
			@subtitle, @body = fragment.split(/\n/, 2)
			@subtitle.sub!(/^\#\s*/,'')
			@body ||= ''

			@categories = get_categories
			@stripped_subtitle = strip_subtitle

			@subtitle_to_html = @subtitle ? to_html('# ' + @subtitle).gsub(/\A<h\d>|<\/h\d>\z/io, '') : nil
			@stripped_subtitle_to_html = @stripped_subtitle ? to_html('# ' + @stripped_subtitle).gsub(/\A<h\d>|<\/h\d>\z/io, '') : nil
			@body_to_html = to_html(@body)
		end

		def subtitle=(subtitle)
			@subtitle = (subtitle || '').sub(/^# /,"\##{categories_to_string} ")
			@strip_subtitle = strip_subtitle
		end

		def categories=(categories)
			@subtitle = "#{categories_to_string} " + (strip_subtitle || '')
			@strip_subtitle = strip_subtitle
		end

		def to_src
			r = ''
			r << "\# #{@subtitle}\n" if @subtitle
			r << @body
		end

		def do_html4(date, idx, opt)
			subtitle = to_html('# ' + @subtitle)
			subtitle.sub!( %r!<h3>(.+?)</h3>!m ) do
				"<h3><%= subtitle_proc( Time.at( #{date.to_i} ), #{$1.dump.gsub( /%/, '\\\\045' )} ) %></h3>"
			end
			if opt['multi_user'] and @author then
				subtitle.sub!(/<\/h3>/,%Q|[#{@author}]</h3>|)
			end
			r = subtitle
			r << @body_to_html
		end

	private

		def to_html(string)
			renderer = HTMLwithPygments.new(:hard_wrap => true)
			extensions = {:fenced_code_blocks => true, :tables => true, :no_intra_emphasis => true}
			r = Redcarpet::Markdown.new(renderer, extensions).render(string)

			# Twitter Autolink
			r = auto_link(r)

			if r =~ /(<pre>|<code>)/
				r.gsub!(/<a class=\"tweet-url username\" href=\".*?\">(.*?)<\/a>/){ $1 }
			end

			# except url autolink in plugin block
			if r =~ /\{\{.+?\}\}/
				r.gsub!(/<a href=\"(.*?)\" rel=\"nofollow\">.*?<\/a>/){ $1 }
				r.gsub!(/\{\{(.+?)\}\}/) { "<%=#{CGI.unescapeHTML($1).gsub(/&#39;/, "'").gsub(/&quot;/, '"')}%>" }
			end

			# ignore duplicate autolink
			if r =~ /<a href="<a href="/
				r.gsub!(/<a href="<a href=".*?" rel="nofollow">(.*?)<\/a>">(.*?)<\/a>/){ "<a href=\"#{$1}\" rel=\"nofollow\">#{$2}</a>" }
			end

			# emoji
			r = r.emojify

			# diary anchor
			r.gsub!(/<h(\d)/) { "<h#{$1.to_i + 2}" }
			r.gsub!(/<\/h(\d)/) { "</h#{$1.to_i + 2}" }

			# my syntax
			r.gsub!(/\((.*?)\)\[(\d{4}|\d{6}|\d{8}|\d{8}-\d+)[^\d]*?#?([pct]\d+)?\]/) {
				unless $1.empty?
					%Q|<%=my "#{$2}#{$3}", "#{$1}" %>|
				else
					%Q|<%=my "#{$2}#{$3}", "#{$2}#{$3}" %>|
				end
			}

			r
		end

		def get_categories
			return [] unless @subtitle
			cat = /(\\?\[([^\[]+?)\\?\])+/.match(@subtitle).to_a[0]
			return [] unless cat
			cat.scan(/\\?\[(.*?)\\?\]/).collect do |c|
				c[0].split(/,/)
			end.flatten
		end

		def strip_subtitle
			return nil unless @subtitle
			r = @subtitle.sub(/^((\\?\[[^\[]+?\]\\?)+\s+)?/, '')
			if r.empty?
				nil
			else
				r
			end
		end
	end

	class GfmDiary
		include DiaryBase
		include CategorizableDiary

		def initialize(date, title, body, modified = Time.now)
			init_diary
			replace( date, title, body )
			@last_modified = modified
		end

		def style
			'GFM'
		end

		def append(body, author = nil)
			section = nil
			body.each_line do |l|
				case l
				when /^\#[^\#]/
					@sections << GfmSection.new(section, author) if section
					section = l
				else
					section = '' unless section
					section << l
				end
			end
			if section
				section << "\n" unless section =~ /\n\n\z/
				@sections << GfmSection.new(section, author)
			end
			@last_modified = Time.now
			self
		end

		def add_section(subtitle, body)
			@sections = GfmSection.new("\# #{subtitle}\n\n#{body}")
			@sections.size
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
