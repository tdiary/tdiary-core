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
	rescue
		<<-HTML
<div class="highlight"><pre>#{code}</pre></div>
		HTML
	end
end

module TDiary
	class GfmSection
		include Twitter::Autolink

		attr_reader :subtitle, :author
		attr_reader :categories, :stripped_subtitle
		attr_reader :subtitle_to_html, :stripped_subtitle_to_html, :body_to_html

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
			@categories = categories
			cat_str = ""
			categories.each {|cat| cat_str << "[#{cat}]"}
			cat_str << " " unless cat_str.empty?
			@subtitle = (subtitle || '').sub(/^# /,"\##{cat_str} ")
			@strip_subtitle = strip_subtitle
		end

		def body
			@body.dup
		end

		def body=(str)
			@body = str
		end

		def categories=(categories)
			@categories = categories
			cat_str = ""
			categories.each {|cat| cat_str << "[#{cat}]"}
			cat_str << " " unless cat_str.empty?
			@subtitle = "#{cat_str} " + (strip_subtitle || '')
			@strip_subtitle = strip_subtitle
		end

		def to_src
			r = ''
			r << "\# #{@subtitle}\n" if @subtitle
			r << @body
		end

		def html4(date, idx, opt)
			r = %Q[<div class="section">\n]
			r << %Q[<%=section_enter_proc( Time.at( #{date.to_i} ) )%>\n]
			r << do_html4( date, idx, opt )
			r << %Q[<%=section_leave_proc( Time.at( #{date.to_i} ) )%>\n]
			r << "</div>\n"
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

		def chtml(date, idx, opt)
			r = %Q[<%=section_enter_proc( Time.at( #{date.to_i} ) )%>\n]
			r << do_html4( date, idx, opt )
			r << %Q[<%=section_leave_proc( Time.at( #{date.to_i} ) )%>\n]
		end

		def to_s
			to_src
		end

		private

		def to_html(string)
			renderer = HTMLwithPygments.new(:hard_wrap => true)
			extensions = {:fenced_code_blocks => true, :tables => true}
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
				r.gsub!(/<a href="(.*?)" rel="nofollow">.*?<\/a>/){ $1 }
			end

			# emoji
			r.gsub!(/:([a-z0-9_+-]+):/) do |emoji|
				emoji.gsub!(":", "")
				"<img src='http://www.emoji-cheat-sheet.com/graphics/emojis/#{emoji}.png' width='20' height='20' title='#{emoji}' alt='#{emoji}' class='emoji' />"
			end

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

		def replace(date, title, body)
			set_date( date )
			set_title( title )
			@sections = []
			append( body )
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
				section << "\n" unless section=~/\n\n\z/
				@sections << GfmSection.new(section, author)
			end
			@last_modified = Time.now
			self
		end

		def each_section
			@sections.each do |section|
				yield section
			end
		end

		def add_section(subtitle, body)
			sec = GfmSection.new("\n")
			sec.subtitle = subtitle
			sec.body     = body
			@sections << sec
			@sections.size
		end

		def delete_section(index)
			@sections.delete_at(index - 1)
		end

		def to_src
			r = ''
			each_section do |section|
				r << section.to_src
			end
			r
		end

		def to_html(opt = {}, mode = :HTML)
			case mode
			when :CHTML
				to_chtml(opt)
			else
				to_html4(opt)
			end
		end

		def to_html4(opt)
			r = ''
			idx = 1
			each_section do |section|
				r << section.html4( date, idx, opt )
				idx += 1
			end
			r
		end

		def to_chtml(opt)
			r = ''
			idx = 1
			each_section do |section|
				r << section.chtml(date, idx, opt)
				idx += 1
			end
			r
		end

		def to_s
			"date=#{date.strftime('%Y%m%d')}, title=#{title}, body=[#{@sections.join('][')}]"
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
