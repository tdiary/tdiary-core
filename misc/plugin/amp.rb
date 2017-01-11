# amp.rb
#
# generate AMP style HTML
#
# Copyright (c) 2016 MATSUOKA Kohei
# Distributed under the GPL2 or any later version.
#

add_header_proc do
  if @mode == 'day'
    diary = @diaries[@date.strftime('%Y%m%d')]
    %Q|<link rel="amphtml" href="#{amp_html_url(diary)}">|
  end
end

add_content_proc('amp') do |date|
  diary = @diaries[date]
  template = File.read(File.join(TDiary::root, "views/amp.rhtml"))
  ERB.new(template).result(binding)
end

def amp_body(diary)
  apply_plugin(diary.to_html)
    .gsub(/<img\s([^>]+)>/, '<amp-img \1 layout="responsive">')
    .gsub(/<script[^<]+<\/script>/, '')
end

def amp_canonical_url(diary)
  URI.join(@conf.base_url, anchor(diary.date.strftime('%Y%m%d')))
end

def amp_day_title(diary)
  title_proc(Time::at(@date.to_i), diary.title)
end

def amp_html_url(diary)
  uri = amp_canonical_url(diary)
  uri.query = [uri.query, "plugin=amp"].compact.join '&'
  uri
end

def amp_style
  base_css = amp_base_css
  theme_css = amp_theme_css
    .gsub(/^@charset.*$/, '')
    .gsub(/!important/, '')

  <<-EOL
  #{base_css}
  #{theme_css}
  EOL
end

def amp_base_css
  base_css_path = theme_paths_local.map {|path|
    File.join(File.dirname(path), "base.css")
  }.find {|path|
    File.exist?(path)
  }
  base_css_path ? File.read(base_css_path) : ''
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
