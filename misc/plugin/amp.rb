# amp.rb
#
# generate AMP style HTML
#
# Copyright (c) 2016 MATSUOKA Kohei
# Distributed under the GPL2 or any later version.
#

# This plugin requires Oga gem.
# Write `gem 'oga'` to your Gemfile.local.

add_header_proc do
  if @mode == 'day'
    diary = @diaries[@date.strftime('%Y%m%d')]
    %Q|<link rel="amphtml" href="#{amp_html_url(diary)}">|
  end
end

add_content_proc('amp') do |date|
  diary = @diaries[date]
  ERB.new(File.read("views/amp.rhtml")).result(binding)
end

def amp_body(diary)
  if defined?(Oga)
    doc = Oga.parse_html(apply_plugin(diary.to_html))
    doc.xpath('//img').each do |element|
      element.name = 'amp-img'
      element.set('layout', 'responsive')
    end
    doc.xpath('//script').each do |element|
      element.remove
    end
    doc.to_xml
  else
    apply_plugin(diary.to_html)
      .gsub(/<img\s([^>]+)>/, '<amp-img \1 layout="responsive">')
      .gsub(/<script[^<]+<\/script>/, '')
  end
end

def amp_canonical_url(diary)
  URI.join(@conf.base_url, anchor(diary.date.strftime('%Y%m%d')))
end

def amp_day_title(diary)
  title_proc(Time::at(@date.to_i), diary.title)
end

def amp_description(diary)
  section = diary.instance_variable_get(:@sections).first
  @conf.shorten(apply_plugin(section.body_to_html, true), 200)
end

def amp_headline(diary)
  section = diary.instance_variable_get(:@sections).first
  section.subtitle_to_html
end

def amp_html_url(diary)
  URI.join(amp_canonical_url(diary), '?plugin=amp')
end

def amp_last_modified(diary)
  diary.last_modified.strftime('%FT%T%:z')
end

def amp_logo
  if @conf.banner.nil? || @conf.banner.empty?
    File.join(@conf.base_url, "#{theme_url}/ogimage.png")
  else
    @conf.banner
  end
end

def amp_style
  base_css = File.read('theme/base.css')
  theme_css = amp_theme_css
    .gsub(/^@charset.*$/, '')
    .gsub(/!important/, '')

  <<-EOL
  #{base_css}
  #{theme_css}
  EOL
end

def amp_theme_css
  _, location, theme = @conf.theme.match(%r|(\w+)/(\w+)|).to_a
  case location
  when 'online'
    require 'uri'
    require 'open-uri'
    uri = URI.parse(theme_url_online(theme))
    uri.scheme ||= 'https'
    URI.parse(uri.to_s).read
  when 'local'
    theme_path = theme_paths_local.map {|path|
      File.join(File.dirname(path), "#{theme}/#{theme}.css")
    }.find {|path|
      File.exist?(path)
    }
    theme_path ? File.read(theme_path) : ''
  end
end

def amp_title
  @conf.html_title
end
