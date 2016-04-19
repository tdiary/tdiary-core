#
# category-legacy.rb : tDiary plugin for show category pages
#                      legacy version for ruby 2.0 or later
#
# Copyright (c) 2003 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL2 or any later version.
#

#
# initialize
#
def category_init
	@conf['category.header1'] ||= %Q[<div class="adminmenu">\n<p>\n<%= category_navi %>\n</p>\n</div>\n]
	@conf['category.header2'] ||= %Q[<p>Categories |\n<%= category_list %>\n</p>\n]
	@conf['category.edit_support'] = @conf['category.edit_support'].to_i rescue 1
end
category_init

def category_icon_location_init
	@category_icon_dir = (@conf['category.icon_dir'] || './icons/').sub(%r|/*$|, '/')
	@category_icon_url = (@conf['category.icon_url'] || './icons/').sub(%r|/*$|, '/')
end

def category_icon_init
	category_icon_location_init
	@conf['category.icon'] ||= ''

	@category_icon = {}
	@conf['category.icon'].split(/\n/).each do |l|
		c, i = l.split
		next if c.nil? or i.nil?
		@category_icon[c] = i if File.exist?("#{@category_icon_dir}#{i}".untaint)
	end
end
category_icon_init

#
# plugin methods
#
def category_form
	# don't you need this method any more?
end

def category_anchor(category)
	period = @conf['category.period'] || 'quarter'
	period_string =
		case period
		when "month"
			"year=#{@date.year};month=#{'%02d' % @date.month};"
		when "quarter"
			"year=#{@date.year};month=#{(@date.month - 1) / 3 + 1}Q;"
		when "half"
			"year=#{@date.year};month=#{(@date.month - 1) / 6 + 1}H;"
		when "year"
			"year=#{@date.year};"
		else
			""
		end
	if @category_icon[category]
		%Q|<a href="#{h @index}?#{period_string}category=#{u category}" title="#{h category}"><img class="category" src="#{h @category_icon_url}#{h @category_icon[category]}" alt="#{h category}"></a>|
	else
		%Q|[<a href="#{h @index}?#{period_string}category=#{u category}" title="#{h category}">#{h category}</a>]|
	end
end

def category_navi_anchor(info, label)
	((!label.nil?) && label.empty?) ? '' : %Q[<span class="adminmenu">#{info.make_anchor(label)}</span>\n]
end

def category_navi
	info = Category::Info.new(@cgi, @years, @conf)
	mode = info.mode

	result = ''
	case mode
	when :year, :half, :quarter, :month
		all_diary = Category::Info.new(@cgi, @years, @conf, year: -1, month: -1)
		all = Category::Info.new(@cgi, @years, @conf, category: ['ALL'], year: -1, month: -1)
		result << category_navi_anchor(info.prev, @conf['category.prev_' + mode.to_s])
		result << category_navi_anchor(info.next, @conf['category.next_' + mode.to_s])
		result << category_navi_anchor(all_diary, @conf['category.all_diary'])
		result << category_navi_anchor(all, @conf['category.all'])
	when :all
		year = Category::Info.new(@cgi, @years, @conf, year: Time.now.year.to_s)
		half = Category::Info.new(@cgi, @years, @conf, year: Time.now.year.to_s, month: "#{((Time.now.month - 1) / 6 + 1)}H")
		quarter = Category::Info.new(@cgi, @years, @conf, year: Time.now.year.to_s, month: "#{((Time.now.month - 1) / 3 + 1)}Q")
		month = Category::Info.new(@cgi, @years, @conf, year: Time.now.year.to_s, month: '%02d' % Time.now.month)
		result << category_navi_anchor(year, @conf['category.this_year'])
		result << category_navi_anchor(half, @conf['category.this_half'])
		result << category_navi_anchor(quarter, @conf['category.this_quarter'])
		result << category_navi_anchor(month, @conf['category.this_month'])
	end
	if !info.category.include?('ALL') then
		all_category = Category::Info.new(@cgi, @years, @conf, category: ['ALL'])
		result << category_navi_anchor(all_category, @conf['category.all_category'])
	end
	result
end

def category_list_sections
	info = Category::Info.new(@cgi, @years, @conf)
	r = ''

	raise ::TDiary::NotFound if @categorized.empty? and bot?

	@categorized.to_a.sort_by{|e| e[0].downcase}.each do |c, v|
		info.category = [c]
		if @category_icon[c]
			img = %Q|<img class="category" src="#{h @category_icon_url}#{h @category_icon[c]}" alt="#{h c}">|
		else
			img = ''
		end
		r << <<HTML
<div class="category day">
	<h2><span class="title">#{img}#{info.make_anchor}</span></h2>
	<div class="body">
		<ul class="category">
HTML
		v.to_a.sort_by{|e| e[0]}.each do |ymd, ary|
			text = Time.local(ymd[0,4], ymd[4,2], ymd[6,2]).strftime(@conf.date_format)
			ary.sort.each do |idx, title, excerpt|
				r << %Q|\t\t\t<li><a href="#{h @index}#{anchor "#{ymd}#p#{'%02d' % idx}"}" title="#{h excerpt}">#{text}#p#{'%02d' % idx}</a> #{apply_plugin(title)}</li>\n|
			end
		end
		r << <<HTML
		</ul>
	</div>
</div>
HTML
	end
	r
end

def category_list_sections_mobile
	info = Category::Info.new(@cgi, @years, @conf)
	r = ''

	raise ::TDiary::NotFound if @categorized.empty? and bot?

	@categorized.to_a.sort_by{|e| e[0].downcase}.each do |c, v|
		info.category = [c]
		r << "<H2>#{info.make_anchor}</H2>"
		r << "<UL>"
		v.to_a.sort_by{|e| e[0]}.each do |ymd, ary|
			text = Time.local(ymd[0,4], ymd[4,2], ymd[6,2]).strftime(@conf.date_format)
			ary.sort.each do |idx, title, excerpt|
				r << %Q|<LI><A HREF="#{h @index}#{anchor "#{ymd}#p#{'%02d' % idx}"}">#{text}#p#{'%02d' % idx}</A> #{apply_plugin(title)}</LI>\n|
			end
		end
		r << "</UL>"
	end
	r
end

def category_list
	info = Category::Info.new(@cgi, @years, @conf)
	@categories.map do |c|
		info.category = [c]
		info.make_anchor
	end.join(" | \n")
end

def category_dropdown_list(label = nil, multiple = nil)
	label ||= 'Categorize!'
	multiple ||= false

	info = Category::Info.new(@cgi, @years, @conf)
	category = info.category
	if category.empty?
		category = ['ALL']
	end

	options = ''
	(['ALL'] + @categories).each do |c|
		options << %Q|\t\t<option value="#{h c}"#{" selected" if category.include?(c)}>#{h c}</option>\n|
	end

	params = ''
	params << %Q[<input type="hidden" name="year" value="#{h info.year}">] if info.year
	params << %Q[<input type="hidden" name="month" value="#{h info.month}">] if info.month

	<<HTML
<form method="get" action="#{h @index}"><div>
	<select name="category"#{" multiple" if multiple}>
#{options}
	</select>
	#{params}
	<input type="submit" value="#{label}">
</div></form>
HTML
end


#
# misc
#

def category_icon_save
	@conf['category.icon'] = @category_icon.map {|c, i| "#{c} #{i}"}.join("\n")
end


module Category

#
# Info
#
class Info
	include ERB::Util

	def initialize(cgi, years, conf, args = {})
		@cgi = cgi
		@years = years
		@conf = conf
		@category = args[:category] || @cgi.params['category'].map do |c|
			@conf.to_native(c, @conf.encoding_old)
		end
		@year = args[:year] || @cgi.params['year'][0]
		@month = args[:month] || @cgi.params['month'][0]
		@mode = :all
		set_mode
	end

protected
	attr_writer :year
	attr_writer :month
public
	attr :category, true
	attr_reader :year
	attr_reader :month
	attr_reader :mode

	def prev
		pp = self.dup

		case mode
		when :half
			h = @month.to_i
			if h == 1
				pp.month = "2H"
				pp.year = (@year.to_i - 1).to_s if @year
			else
				pp.month = "1H"
			end
		when :quarter
			q = @month.to_i
			if q == 1
				pp.month = "4Q"
				pp.year = (@year.to_i - 1).to_s if @year
			else
				pp.month = "#{q - 1}Q"
			end
		when :month
			m = @month.to_i
			if m == 1
				pp.month = "12"
				pp.year = (@year.to_i - 1).to_s if @year
			else
				pp.month = '%02d' % (m - 1)
			end
		when :year
			pp.year = (@year.to_i - 1).to_s
		end
		pp
	end

	def next
		pp = self.dup

		case mode
		when :half
			h = @month.to_i
			if h == 2
				pp.month = "1H"
				pp.year = (@year.to_i + 1).to_s if @year
			else
				pp.month = "2H"
			end
		when :quarter
			q = @month.to_i
			if q == 4
				pp.month = "1Q"
				pp.year = (@year.to_i + 1).to_s if @year
			else
				pp.month = "#{q + 1}Q"
			end
		when :month
			m = @month.to_i
			if m == 12
				pp.month = "01"
				pp.year = (@year.to_i + 1).to_s if @year
			else
				pp.month = '%02d' % (m + 1)
			end
		when :year
			pp.year = (@year.to_i + 1).to_s
		end
		pp
	end

	def make_anchor(label = nil)
		a = @category.map {|c| "category=#{u c}"}.join(';')
		a << ";year=#{@year}" if @year
		a << ";month=#{@month}" if @month
		if label
			case mode
			when :year
				label = label.gsub(/\$1/, @year)
			when :month, :quarter, :half
				label = label.gsub(/\$2/, @month)
				label = label.gsub(/\$1/, @year || '*')
			end
		else
			label = @category.to_a.join(':')
		end
		%Q|<a href="#{h @conf.index}?#{h a}">#{h label}</a>|
	end

	#
	# return ym_spec
	#
	# {"yyyy" => ["mm", ...], ...}
	#
	# date spec:
	#  (1) none               -> all diary
	#  (2) month=xH           -> all diary in xH of all year
	#  (3) year=YYYY;month=xH -> all diary in YYYY/xH
	#  (4) month=xQ           -> all diary in xQ of all year
	#  (5) year=YYYY;month=xQ -> all diary in YYYY/xQ
	#  (6) month=MM           -> all diary in MM of all year
	#  (7) year=YYYY;month=MM -> all diary in YYYY/MM
	#  (8) year=YYYY          -> all diary in YYYY
	#
	def years
		if @mode == :all
			return @years
		end

		months = case @mode
		when :half
			[('01'..'06'), ('07'..'12')][@month.to_i - 1].to_a
		when :quarter
			[['01', '02', '03'], ['04', '05', '06'], ['07', '08', '09'], ['10', '11', '12']][@month.to_i - 1]
		when :month
			[@month]
		else
			('01'..'12').to_a
		end

		r = {}
		(@year ? [@year] : @years.keys).each do |y|
			r[y] = months
		end
		r
	end

	#
	# date spec:
	#  (1) none                -> all
	#  (2) month=xH            -> half
	#  (3) year=YYYY;month=xH  -> half
	#  (4) month=xQ            -> quarter
	#  (5) year=YYYY;month=xQ  -> quarter
	#  (6) month=MM            -> month
	#  (7) year=YYYY;month=MM  -> month
	#  (8) year=YYYY           -> year
	#
	def set_mode
		if @year.nil? and @month.nil?
			@mode = :all
		end

		if /\d{4}/ === @year.to_s
			@mode = :year
		else
			@year = nil
		end

		if /[12]H/ === @month.to_s
			@mode = :half
		elsif /[1-4]Q/ === @month.to_s
			@mode = :quarter
		elsif (1..12).include?(@month.to_i)
			@mode = :month
		else
			@month = nil
		end

	end
end

#
# Cache
#
class Cache
	include ERB::Util

	def initialize(conf, bind)
		@conf = conf
		@binding = bind                           # ...... very ugly
		@plugin = @binding.eval('self')
		@categories = nil
	end

	def get(db, cat)
		JSON.load(db.get(cat) || '{}')
	end

	def set(db, cat, data)
		db.set(cat, data.to_json)
	end

	def add_categories(list)
		return if list.nil? or list.empty?
		replace_categories(restore_categories + list)
	end

	def replace_categories(list)
		@categories = list
	end

	def restore_categories
		return @categories if @categories
		@plugin.__send__(:transaction, 'category') do |db|
			@categories = db.keys
		end
		return @categories
	end

	#
	# cache each section of diary
	# used in update_proc
	#
	def replace_sections(diary)
		return if diary.nil? or !diary.categorizable?

		categorized = categorize_diary(diary)
		categories = restore_categories
		deleted = []
		ymd = diary.date.strftime('%Y%m%d')

		@plugin.__send__(:transaction, 'category') do |db|
			categories.each do |c|
				cat = get(db, c) || {}
				if diary.visible? and categorized[c]
					cat.update(categorized[c])
					set(db, c, cat)
				else
					# diary is invisible or sections of this category is deleted
					cat.delete(ymd)
					if cat.empty?
						db.delete(c)
						deleted << c
					else
						set(db, c, cat)
					end
				end
			end

			if !deleted.empty?
				replace_categories(categories - deleted)
			end
		end
	end

	#
	# (re)create category cache
	#
	def recreate(years)
		list = []
		@plugin.__send__(:transaction, 'category') do |db|
			db.keys.each {|key|db.delete(key)}

			years.each do |y, ms|
				ms.each do |m|
					m = DiaryContainer::find_by_month(@conf, "#{y}#{m}")
					m.diaries.each do |ymd, diary|
						next if !diary.visible? or !diary.categorizable?
						categorized = categorize_diary(diary)
						categorized.keys.each do |c|
							cat = get(db, c) || {}
							set(db, c, cat.update(categorized[c]))
						end
						diary.each_section do |s|
							list |= s.categories unless s.categories.empty?
						end
					end
				end
			end
		end

		replace_categories(list)
	end

	#
	# categorize sections of category of years
	#
	# {"category" => {"yyyymmdd" => [[idx, title, excerpt], ...], ...}, ...}
	#
	def categorize(category, years)
		categories = category - ['ALL']
		if categories.empty?
			categories = restore_categories
		else
			categories &= restore_categories
		end

		categorized = {}
		begin
			categorized.clear
			categories.each do |c|
				@plugin.__send__(:transaction, 'category') do |db|
					categorized[c] = get(db, c)
				end
				categorized[c].keys.each do |ymd|
					y, m = ymd[0,4], ymd[4,2]
					if years[y].nil? or !years[y].include?(m)
						categorized[c].delete(ymd)
					end
				end
				categorized.delete(c) if categorized[c].empty?
			end
		rescue NoMethodError	# when categorized[c] is nil
			recreate(years)
			retry
		end

		categorized
	end

private
	def cache_file(category = nil)
		if category
			"#{@dir}/#{u( category ).gsub(/%20/,'+')}".untaint
		else
			"#{@dir}/category_list"
		end
	end

	#
	# categorize sections of diary
	#
	# {"category" => {"yyyymmdd" => [[idx, title, excerpt], ...]}}
	#
	def categorize_diary(diary)
		categorized = {}
		ymd = diary.date.strftime('%Y%m%d')

		idx = 1
		diary.each_section do |s|
			s.categories.each do |c|
				categorized[c] = {} if categorized[c].nil?
				categorized[c][ymd] = [] if categorized[c][ymd].nil?
				body = <<EVAL
text = apply_plugin(<<'BODY', true)
#{s.body_to_html}
BODY
EVAL
				shorten = begin
					@conf.shorten(eval(body.untaint, @binding))
				rescue NameError
					""
				end
				categorized[c][ymd] << [idx, s.stripped_subtitle_to_html, shorten]
			end
			idx +=1
		end

		categorized
	end
end

end # module Category

# read cache here so that you can use category with secure mode.
@category_cache = Category::Cache.new(@conf, binding)

#
# display categories on update form
#
def category_edit_support_flatlist
	ret = ''
	ret << '<div class="field title">'
	ret << "#{@category_conf_label}:\n"
	@categories.each do |c|
		ret << %Q!| <span class="category-item">#{h c}</span>\n!
	end
	ret << "|\n</div>\n<br>\n"
	ret
end

def category_edit_support_dropdown
	ret = ''
	ret << '<div class="field title">'
	ret << %Q|#{@category_conf_label}: <select id="category-candidate" name="category-candidate">\n|
	@categories.each do |c|
		ret << %Q!<option>#{h c}</option>\n!
	end
	ret << "|\n</select>\n</div>\n<br>\n"
	ret
end

if @conf['category.edit_support'] != 0 then
	enable_js( 'category.js' )
	add_edit_proc do |date|
		ret = ''
		unless @categories.size == 0 then
			ret << if @conf['category.edit_support'] == 2 then
				category_edit_support_dropdown
			else
				category_edit_support_flatlist
			end
		end
	end
end


#
# when update diary, update cache
#
add_update_proc do
	if /^(append|replace)$/ =~ @mode
		cache = @category_cache
		list = []
		diary = @diaries[@date.strftime('%Y%m%d')]
		diary.each_section do |s|
			list |= s.categories
		end
		cache.add_categories(list)
		cache.replace_sections(diary)
	end
end


#
# configuration
#
def category_icon_find_icons
   return if @category_all_icon
	@category_all_icon = []
	%w(png jpg gif bmp).each do |e|
		@category_all_icon += Dir.glob("#{@category_icon_dir}*.#{e}".untaint).map {|i| File.basename(i)}
	end
	@category_all_icon.sort!
end

def category_icon_select(category)
	options = %Q|<\t<option value="none">#{@category_icon_none_label}</option>\n|
	@category_all_icon.each do |i|
		options << %Q|\t<option value="#{h i}"#{" selected" if @category_icon[category] == i}>#{h i}</option>\n|
	end
	<<HTML
<select name="category.icon.#{h category}">
#{options}
</select>
HTML
end

def category_icon_sample
	@category_all_icon.map do |i|
		%Q|<img src="#{h @category_icon_url}#{h i}" alt="#{h i}" title="#{h i}">\n|
	end.join("/\n")
end

if @mode == 'conf' || @mode == 'saveconf'
	add_conf_proc( 'category', @category_conf_label, 'basic' ) do
		if @mode == 'saveconf'
			if @cgi.valid?( 'category_initialize' )
				@category_cache.recreate(@years)
			end

			[
				'category.header1',
				'category.header2',
			].each do |name|
				@conf[name] = @conf.to_native( @cgi.params[name][0] )
			end
			[
				'category.prev_year',
				'category.next_year',
				'category.prev_half',
				'category.next_half',
				'category.prev_quarter',
				'category.next_quarter',
				'category.prev_month',
				'category.next_month',
				'category.this_year',
				'category.this_half',
				'category.this_quarter',
				'category.this_month',
				'category.all_diary',
				'category.all_category',
				'category.all',
			].each do |name|
				@conf[name] = @conf.to_native( @cgi.params[name][0] )
			end
			if ["month", "quarter", "half", "year", "all"].index(@cgi.params["category.period"][0])
				@conf["category.period"] = @cgi.params["category.period"][0]
			end
			@conf['category.edit_support'] = (@cgi.params['category.edit_support'][0] || '1').to_i
		end
		category_conf_html
	end

	category_icon_find_icons if @cgi.params['conf'][0] == 'category_icon'
	add_conf_proc( 'category_icon', @category_icon_conf_label, 'basic' ) do
		if @mode == 'saveconf'
			unless @conf.secure
				[
					'category.icon_dir',
					'category.icon_url',
				].each do |name|
					@conf[name] = @cgi.params[name][0].sub(%r|/*$|, '/')
				end
				category_icon_location_init
			end
			@cgi.params.keys.each do |key|
				next unless /\Acategory\.icon\..*\z/ === key
				category = key.sub(/\Acategory\.icon\./, '')
				if @cgi.params[key][0] == 'none'
					@category_icon.delete(category)
				else
					@category_icon[category] = @cgi.params[key][0]
				end
			end
			category_icon_save
		end
		category_icon_conf_html
	end
end

@categories = @category_cache.restore_categories.sort_by{|e| e.downcase}
if @mode == 'categoryview'
	info = Category::Info.new(@cgi, @years, @conf)
	@categorized = @category_cache.categorize(info.category, info.years)
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
