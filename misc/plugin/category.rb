#
# category.rb : tDiary plugin for show category pages
#
# Copyright (C) 2016 TADA Tadashi
# Distributed under the GPL2 or any later version.
#


# read cache here so that you can use category with secure mode.
@conf['category.header1'] = ''
@conf['category.header2'] = '<%= category_dropdown_list %>'
@category_icon = {}
@categories = transaction('category'){|db|db.keys}.sort_by{|c|c.downcase}

module Category
	class Info
		def initialize(cgi, _, conf)
			@cgi, @conf = cgi, conf
		end

		def category
			@name ||= @conf.to_native(@cgi.params['category'][0] || '', @conf.encoding_old)
		end
	end
end

def category_title
	info = Category::Info.new(@cgi, nil, @conf)
	"[#{info.category}]"
end

def category_anchor(category)
	%Q|[<a href="#{h @index}?category=#{u category}" title="#{h category}">#{h category}</a>]|
end

def category_list
	info = Category::Info.new(@cgi, _, @conf)
	@categories.map do |c|
		%Q|<a href="#{h @index}?category=#{h c}">#{h c}</a>|
	end.join(" | \n")
end

def category_dropdown_list(label = nil, _ = nil)
	label ||= 'show category list'

	info = Category::Info.new(@cgi, _, @conf)
	category = info.category
	category = [] if category.empty?

	options = ''
	@categories.each do |c|
		options << %Q|<option value="#{h c}"#{" selected" if category.include?(c)}>#{h c}</option>\n|
	end

	<<-HTML
		<form method="get" action="#{h @index}"><div>
			<select name="category">
		#{options}
			</select>
			<input type="submit" value="#{label}">
		</div></form>
	HTML
end

def category_transaction(categories)
	transaction('category') do |db|
		(categories || db.keys).each do |category|
			Hash[*JSON.load(db.get(category) || '{}').sort_by{|d,_|d}.flatten(1)].each do |ymd, diaries|
				yield db, category, ymd, diaries
			end
		end
	end
end

def category_list_sections
	info = Category::Info.new(@cgi, nil, @conf)

	r = ''
	r << <<-HTML
		<div class="category day">
			<h2>
				<span class="title">
					<a href="#{h @conf.index}?category=#{u info.category}">#{h info.category}</a>
				</span>
			</h2>
			<div class="body">
				<ul class="category">
	HTML
	category_transaction([info.category]) do |db, category, ymd, diaries|
		date = Time.local(*ymd.scan(/(.{4})(..)(..)/)[0]).strftime(@conf.date_format)
		diaries.sort_by{|i|i[0]}.each do |idx, title, excerpt|
			r << <<-HTML
				<li>
					<a href="#{h @index}#{anchor "#{ymd}#p#{'%02d' % idx}"}" title="#{h excerpt}">
						#{date}#p#{'%02d' % idx}
					</a>
					#{apply_plugin(title)}
				</li>
			HTML
		end
	end
	r << <<-HTML
				</ul>
			</div>
		</div>
	HTML
	return r
end

def category_serialize(diary)
	data = {}
	ymd = diary.date.strftime('%Y%m%d')

	idx = 1
	diary.each_section do |s|
		s.categories.each do |c|
			data[c] ||= {}
			data[c][ymd] ||= []
			body = <<-EVAL.gsub(/^\t+/, '')
				text = apply_plugin(<<'BODY', true)
				#{s.body_to_html}
				BODY
			EVAL
			shorten = begin
				@conf.shorten(eval(body.untaint))
			rescue NameError
				""
			end
			data[c][ymd] << [idx, s.stripped_subtitle_to_html, shorten]
		end
		idx +=1
	end
	data
end

def category_rebuild(years)
	transaction('category') do |db|
		cache = Hash.new{{}}
		@years.each do |y, ms|
			ms.each do |m|
				m = DiaryContainer::find_by_month(@conf, "#{y}#{m}")
				m.diaries.each do |ymd, diary|
					next if !diary.visible? or !diary.categorizable?
					serialize = category_serialize(diary)
					serialize.keys.each do |category|
						cache[category] = cache[category].merge!(serialize[category])
					end
				end
			end
		end
		db.keys.each {|key| db.delete(key)}
		cache.each do |category, diaries|
			db.set(category, diaries.to_json)
		end
	end
end

add_update_proc do
	if /^(append|replace)$/ =~ @mode
		ymd = @date.strftime('%Y%m%d')
		diary = @diaries[ymd]
		serialize = category_serialize(diary)

		transaction('category') do |db|
			(db.keys + serialize.keys).uniq.each do |category|
				data = JSON.load(db.get(category) || '{}')
				if diary.visible? and serialize[category]
					data.update(serialize[category])
					db.set(category, data.to_json)
				else
					data.delete(ymd)
					if data.empty?
						db.delete(category)
					else
						db.set(category, data.to_json)
					end
				end
			end
		end
	end
end

#
# edit support: insert category to editing diary using JavaScript
#
def category_edit_support_flatlist(categories)
	ret = ''
	ret << '<div class="field title">'
	ret << "#{@category_conf_label}:\n"
	categories.each do |c|
		ret << %Q!| <span class="category-item">#{h c}</span>\n!
	end
	ret << "|\n</div>\n<br>\n"
	ret
end

def category_edit_support_dropdown(categories)
	ret = ''
	ret << '<div class="field title">'
	ret << %Q|#{@category_conf_label}: <select id="category-candidate" name="category-candidate">\n|
	categories.each do |c|
		ret << %Q!<option>#{h c}</option>\n!
	end
	ret << "|\n</select>\n</div>\n<br>\n"
	ret
end

if @mode =~ /^(form|edit)$/ and @conf['category.edit_support'] != 0
	enable_js( 'category.js' )
	add_edit_proc do |date|
		ret = ''
		transaction('category') do |db|
			categories = db.keys
			unless categories.size == 0 then
				if @conf['category.edit_support'] == 2 then
					ret << category_edit_support_dropdown(categories)
				else
					ret << category_edit_support_flatlist(categories)
				end
			end
		end
		ret
	end
end

if @mode == 'conf' || @mode == 'saveconf'
	add_conf_proc('category', @category_conf_label, 'basic') do
		if @mode == 'saveconf'
			category_rebuild(@years) if @cgi.valid?('category_initialize')
			@conf['category.edit_support'] = (@cgi.params['category.edit_support'][0] || '1').to_i
		end
		category_conf_html
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
