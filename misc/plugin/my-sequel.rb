#
# my-sequel.rb
#
# show links to follow-up entries
#
# Copyright 2006 zunda <zunda at freeshell.org> and
#                NISHIMURA Takashi <nt at be.to>
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work under the terms
# of GPL version 2.
#
# Language resources can be found in the middle of thie file.
# Please search a line with `language resource'
#
require 'pstore'
unless defined?(ERB)
	require 'erb'
end

class MySequel
	include ERB::Util
	extend ERB::Util

	class Conf
		include ERB::Util
		Prefix = 'my_sequel.'

		unless @conf then
			def self::to_native(str)
				return str
			end
		else
			def self::to_native(str)
				@conf.to_native(str)
			end
		end

		def self::handler_escape(string)
			string.gsub(/\r/n, '').gsub(/&/n, '&amp;').gsub(/"/n, '&quot;').gsub(/>/n, '&gt;').gsub(/</n, '&lt;').gsub(/\n/n, '\n')
		end

		def self::handler_scriptlet
			return <<'_END'
function unescape(string) {
	return string.replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"').replace(/&amp;/g, '&');
}
function uncheck(element) {
	document.getElementById(element.id+".reset").checked = false;
}
function restore(element) {
	var text_id = element.id.replace(/\.reset$/, "")
	if (element.checked) {
		document.getElementById(text_id).value = unescape(default_values[text_id]);
	}
}
_END
		end

		def initialize(conf_hash)
			@default_hash = conf_hash
			@conf_hash = Hash.new
		end

		# takes configuration from @options trusting the input
		def merge_hash(hash)
			@default_hash.each_key do |key|
				prefixed = Prefix + key.to_s
				@conf_hash[key] = hash[prefixed] if hash.has_key?(prefixed)
			end
		end

		# takes configuration from @cgi.params
		def merge_params(params)
			@default_hash.each_key do |key|
				keystr = key.to_s
				if params[keystr+'.reset'] and params[keystr+'.reset'][0] then
					@conf_hash.delete(key)
				elsif params[keystr] then
					@conf_hash[key] = params[keystr][0]
				end
			end
		end

		# returns current configuration
		def [](key)
			if @conf_hash.has_key?(key) then
				return @conf_hash[key]
			else
				return @default_hash[key][:default]
			end
		end

		# returns hash of configured values
		def to_conf_hash(target_hash)
			@default_hash.each_key do |key|
				target_hash.delete(Prefix + key.to_s)
			end
			@conf_hash.each_pair do |key, value|
				target_hash[Prefix + key.to_s] = value
			end
		end

		# returns an HTML sniplet for configuration interface
		def html(restore_default_label, mobile = false)
			return @default_hash.keys.sort_by{|k| @default_hash[k][:index]}.map{|k|
				idattr = mobile ? '' : %Q| id="#{h k.to_s}"|
				idattr_reset = mobile ? '' : %Q| id="#{h k.to_s}.reset"|
				uncheck = mobile ? '' : ' onfocus="uncheck(this)"'
				restore = mobile ? '' : ' onchange="restore(this)" onclick="restore(this)"'
				r = %Q|\t<h3 class="subtitle">#{h @default_hash[k][:title]}</h3>\n|
				description = @default_hash[k][:description]
				r += %Q|\t<p>#{h description}</p>\n| if description and not mobile
				unless @default_hash[k][:textarea]
					r += %Q|\t<p><input name="#{h k.to_s}"#{idattr} type="text" value="#{h(Conf.to_native(self[k]))}"#{uncheck}>|
				else
					cols = 70
					rows = 10
					if @default_hash[k][:textarea].respond_to?(:[]) then
						cols = @default_hash[k][:textarea][:cols] || cols
						rows = @default_hash[k][:textarea][:rows] || rows
					end
					r += %Q|\t<p><textarea name="#{h k.to_s}"#{idattr} cols="#{h cols}" rows="#{h rows}"#{uncheck}>#{h(Conf.to_native(self[k]))}</textarea>|
				end
				name = "#{h k.to_s}.reset"
				r += %Q|&nbsp;-&nbsp;<label for="#{name}"><input id="#{name}" name="#{name}"#{idattr_reset} type="checkbox" value="t"#{restore}>#{restore_default_label}</label></p>\n|
				r
			}.join
		end

		# Javascript hash literal for default values
		def default_js_hash
			r = "default_values = {\n"
			r += @default_hash.keys.sort_by{|k| @default_hash[k][:index]}.map{|k|
				%Q|\t"#{h k}": "#{Conf::handler_escape(@default_hash[k][:default])}"|
			}.join(",\n")
			r += "\n};\n"
			return r
		end

		def handler_block
			return <<"_END"
<script type="text/javascript"><!--
#{default_js_hash}#{Conf::handler_scriptlet}// --></script>
_END
		end
	end

	# CSS sniplet for sequels
	def self::css(inner_css)
		unless inner_css.strip.empty?
			return <<"_END"
\t<style type="text/css" media="all"><!--
\tdiv.sequel {
#{h(inner_css.gsub(/^\s*/, "\t\t").gsub(/\r?\n/, "\n"))}\t}
\t--></style>
_END
		else
			return ''
		end
	end

	# cache directory for this plguin
	def self::cache_dir(cache_path)
		return File.join(cache_path, 'my_sequel')
	end

	# cache file for a month: #{yyyy}/#{yyyymm}.#{src or dst}.dat
	def self::cache_file(cache_path, anchor, direction)
		return File.join(MySequel.cache_dir(cache_path), MySequel.year(anchor), "#{MySequel.month(anchor)}.#{direction}.dat")
	end

	# unique for each month
	def self::cache_key(anchor)
		return MySequel.month(anchor)
	end

	# for each cache key for dates
	def self::each_cache_key(dates)
		dates.map{|ymd| MySequel.cache_key(ymd)}.uniq.each do |cache_file|
			yield(cache_file)
		end
	end

	# yyyy
	def self::year(anchor)
		return anchor.scan(/\d{4,4}/)[0]
	end

	# yyyymm
	def self::month(anchor)
		return anchor.scan(/\d{6,6}/)[0]
	end

	# yyyymmdd
	def self::date(anchor)
		if anchor.respond_to?(:localtime)
			return anchor.localtime.strftime("%Y%m%d")
		else
			return anchor.scan(/\d{8,8}/)[0]
		end
	end

	# add an entry to Array value of hash, making new Array if needed
	def self::push_to_hash(hash, key, element)
		unless hash.has_key?(key)
			hash[key] = Array.new
			begin
				hash[key].taint
			rescue SecurityError
			end
		end
		hash[key] << element
		hash
	end

	def initialize(cache_path)
		@link_srcs = Hash.new.taint	# key:dst anchor value:Array of src anchors
		@current_dsts = Hash.new.taint	# key:src anchor value:Array of dst anchors
		@cached_dsts = Hash.new.taint	# for restore_dsts and clean_srcs
		@vanished_dsts = Hash.new.taint	# key:src date value:Array of dst anchors
		@cache_path = cache_path
	end

	def restore(dates)
		restore_srcs(dates)
		restore_dsts(dates)
	end

	# HTML sniplet for sequels
	def html(dst_anchor, date_format, label)
		anchors = srcs(dst_anchor)
		if anchors and not anchors.empty? then
			r = %Q|<div class="sequel">#{h label}|
			r += anchors.map{|src_anchor|
				yield(src_anchor, Time.local(*(src_anchor.scan(/(\d{4,4})(\d\d)(\d\d)/)[0])).strftime(date_format))
			}.join(', ')
			r += "</div>\n"
			return r
		else
			return ''
		end
	end

	# Array of source anchors for a destination anchor, nil if none
	def srcs(dst_anchor)
		a = @link_srcs[dst_anchor]
		return nil if not a or a.empty?
		return a.uniq.sort
	end

	# starts a day - get ready to scan the diary for the section
	def clean_dsts(date)
		datestr = MySequel.date(date)
		@current_dsts.keys.each do |src_anchor|
			next unless MySequel.date(src_anchor) == datestr
			@current_dsts[src_anchor] = Array.new
			begin
				@current_dsts[src_anchor].taint
			rescue SecurityError
			end
		end
	end

	# adds a link
	def add(src_anchor, dst_anchor)
		MySequel.push_to_hash(@link_srcs, dst_anchor, src_anchor)
		MySequel.push_to_hash(@current_dsts, src_anchor, dst_anchor)
	end

	# detect vanished links
	def clean_srcs
		(@cached_dsts.keys + @current_dsts.keys).uniq.each do |src_anchor|
			if @cached_dsts[src_anchor] then
				if @current_dsts[src_anchor] then
					@vanished_dsts[src_anchor] = @cached_dsts[src_anchor] - @current_dsts[src_anchor]
				else
					@vanished_dsts[src_anchor] = @cached_dsts[src_anchor]
				end
			end
			@cached_dsts[src_anchor] = @current_dsts[src_anchor].dup
		end
	end

	# restores cached data for a month
	# calls the block for each root giving key and value
	def each_cached(anchor, direction)
		path = MySequel.cache_file(@cache_path, anchor, direction)
		begin
			PStore.new(path).transaction(true) do |db|
				db.roots.each do |cached_anchor|
					yield(cached_anchor, db[cached_anchor])
				end
			end
		rescue TypeError	# corrupted PStore data
			File.unlink(path)
		rescue PStore::Error	# corrupted PStore data
			begin
				File.unlink(path)
			rescue Errno::ENOENT
			end
		rescue Errno::ENOENT	# no cache yet
		end
	end
	private :each_cached

	# restores cached sources for a month
	def restore_srcs(dates)
		@srcs_loaded ||= Hash.new
		MySequel.each_cache_key(dates) do |cache_key|
			unless @srcs_loaded[cache_key] then
				each_cached(cache_key, 'src') do |anchor, array|
					unless @link_srcs.has_key?(anchor)
						@link_srcs[anchor] = array.taint
					else
						@link_srcs[anchor] += array.taint
					end
				end
				@srcs_loaded[cache_key] = true
			end
		end
	end

	# restores cached destinations
	def restore_dsts(dates)
		@dsts_loaded ||= Hash.new
		MySequel.each_cache_key(dates) do |cache_key|
			unless @dsts_loaded[cache_key] then
				each_cached(cache_key, 'dst') do |anchor, array|
					array.taint
					@cached_dsts[anchor] = array
					@current_dsts[anchor] = array.dup
				end
				@dsts_loaded[cache_key] = true
			end
		end
	end

	# hash for storing cache
	# key: path to cache
	# value: Hash
	#   key: anchor
	#   value: compacted and uniqed Array of anchor on the other side of link
	def hash_for_cache(link_hash, direction)
		r = Hash.new
		link_hash.each_pair do |pivot_anchor, anchor_array|
			c = anchor_array.compact.uniq
			path = MySequel.cache_file(@cache_path, pivot_anchor, direction)
			r[path] ||= Hash.new
			r[path][pivot_anchor] = c
		end
		return r
	end
	private :hash_for_cache

	# stores the data
	def store(cache_hash)
		cache_hash.each_pair do |path, h|
			d = File.dirname(path)
			Dir.mkdir(d) unless File.exist?(d)
			PStore.new(path).transaction do |db|
				h.each_pair do |k, v|
					unless v.empty? then
						db[k] = v
					else
						db.delete(k)
					end
				end
			end
		end
	end
	private :store

	# commits on-memory results to files
	def commit
		d = MySequel.cache_dir(@cache_path)
		Dir.mkdir(d) unless File.exist?(d)

		restore_srcs(@link_srcs.keys)

		restore_srcs(@vanished_dsts.values.flatten)
		@vanished_dsts.each_pair do |src_anchor, dst_anchors|
			dst_anchors.uniq.each do |dst_anchor|
				@link_srcs[dst_anchor].reject!{|anchor| anchor == src_anchor}
			end
		end

		store(hash_for_cache(@link_srcs, 'src'))
		store(hash_for_cache(@current_dsts, 'dst'))
		@vanished_dsts = Hash.new.taint
	end

end

unless __FILE__ == $0 then
	# register this plguin to tDiary

	# language resource and configuration
	@my_sequel_plugin_name ||= 'Link to follow ups'
	@my_sequel_description ||= <<_END
<p>Shows links to follow-up entries,
which have `my' link to the entry in the past.</p>
<p>Do not forget to push the OK button to store the changes.</p>
_END
	@my_sequel_label_conf ||= 'Link label'
	@my_sequel_label ||= 'Follow up: '
	@my_sequel_restore_default_label ||= 'Restore default'
	@my_sequel_default_hash ||= {
		:label => {
			:title => 'Link label',
			:default => 'Follow up: ',
			:description => 'Prefix for links to the follow-ups',
			:index => 1,
		},
		:date_format => {
			:title => 'Link format',
			:default => @date_format,
			:description => 'Time format of links to the follow-ups. Sequences of % and a charactor are converted as follows: "%Y" to year, "%m" to month in number, "%b" to short name of month, "%B" to full name of month, "%d" to day of month, "%a" to short name of day of week, and "%A" to full name of day of week, for the follow-up.',
			:index => 2,
		},
		:inner_css => {
			:title => 'CSS',
			:default => <<'_END',
font-size: 75%;
text-align: right;
margin: 0px;
_END
			:description => 'CSS for the links. The followoing is applied to <code>div.sequel</code>.',
			:index => 3,
			:textarea => {:rows => 5},
		},
	}

	@my_sequel_conf = MySequel::Conf.new(@my_sequel_default_hash)
	@my_sequel_conf.merge_hash(@options)

	# configuration interface
	add_conf_proc( 'my-sequel', @my_sequel_plugin_name ) do
		if @mode == 'saveconf' then
			@my_sequel_conf.merge_params(@cgi.params)
			@my_sequel_conf.to_conf_hash(@conf)
		end
		<<"_HTML"
#{@my_sequel_conf.handler_block}
<h3>#{@my_sequel_plugin_name}</h3>
#{@my_sequel_description}
#{@my_sequel_conf.html(@my_sequel_restore_default_label, @conf.mobile_agent?).chomp}
_HTML
	end

	@my_sequel = MySequel.new(@cache_path)
	@my_sequel_active = false

	# activate this plugin if header procs are called
	# - This avoids being called from makerss.rb
	add_header_proc do
		if not @conf.bot? and not @conf.mobile_agent? then
			@my_sequel_active = true
			@my_sequel.restore(@diaries.keys)
			MySequel.css(@my_sequel_conf[:inner_css])
		end
	end

	# preparation for a day
	add_body_enter_proc do |date|
		if @my_sequel_active then
			if date then
				@my_sequel_date = MySequel.date(date)
				@my_sequel.clean_dsts(@my_sequel_date)
			else
				@my_sequel_date = nil
			end
		end
		''
	end

	# preparation for a section
	add_section_enter_proc do |date, index|
		if @my_sequel_active and @my_sequel_date then
			@my_sequel_anchor = "#{@my_sequel_date}#p#{'%02d' % index}"
		end
		''
	end

	# plugin function to be called from within sections
	alias :my_sequel_orig_my :my unless defined?(my_sequel_orig_my)
	def my(*args)
		if @my_sequel_active and @my_sequel_date and @my_sequel_anchor and @mode != 'preview' then
			dst_date, frag = args[0].scan(/(\d{8,8})(?:[^\d]*)(?:#?p(\d+))?$/)[0]
			if dst_date and dst_date < @my_sequel_date then
				dst_anchor = "#{dst_date}#{frag ? "#p%02d" % frag.to_i : ''}"
				@my_sequel.add(@my_sequel_anchor, dst_anchor)
			end
		end
		my_sequel_orig_my(*args)
	end

	# show sequels when leaving a section
	add_section_leave_proc do
		r = ''
		if @my_sequel_active and @my_sequel_date and @my_sequel_anchor and not @conf.bot? and not @conf.mobile_agent? then
			r = @my_sequel.html(@my_sequel_anchor, @my_sequel_conf[:date_format], @my_sequel_conf[:label]){|src_anchor, anchor_str|
				my_sequel_orig_my(src_anchor, anchor_str)
			}
		end
		@my_sequel_anchor = nil
		r
	end

	# show sequels when leaving a day
	add_body_leave_proc do
		r = ''
		if @my_sequel_active and @my_sequel_date then
			if not @conf.bot? and not @conf.mobile_agent? then
				r = @my_sequel.html(@my_sequel_anchor, @my_sequel_conf[:date_format], @my_sequel_conf[:label]){|src_anchor, anchor_str|
					my_sequel_orig_my(src_anchor, anchor_str)
				}
			end
		end
		@my_sequel_date = nil
		r
	end

	# commit changes
	add_footer_proc do
		if @my_sequel_active then
			@my_sequel.clean_srcs
			@my_sequel.commit
		end
		''
	end

else
	# test cases for updates of links: run this file as a Ruby script
	require 'test/unit'
	require 'tmpdir'

	class TestMySequel < Test::Unit::TestCase
		OrigLinks = {
			'20061231#p01' => '20061101#p01',
			'20061231#p02' => '20061001#p01',
			'20061130#p01' => '20061001#p01',
		}
		def setup
			@cache_path = File.join(Dir.tmpdir, "#{__FILE__}-#{$$}")
			Dir.mkdir(@cache_path)

			@orig_src_dates = OrigLinks.keys.map{|a| MySequel.date(a)}
			@orig_dst_dates = OrigLinks.values.map{|a| MySequel.date(a)}
			orig = MySequel.new(@cache_path)
			orig.restore(@orig_src_dates)
			@orig_src_dates.each do |date|
				orig.clean_dsts(Time.local(*(date.scan(/(\d{4,4})(\d\d)(\d\d)/)[0])))
			end
			OrigLinks.each_pair do |src, dst|
				orig.add(src, dst)
			end
			orig.clean_srcs
			orig.commit
		end

		def testsrcs	# confirms setup really cached the OrigLinks
			cached = MySequel.new(@cache_path)
			cached.restore(@orig_dst_dates)
			OrigLinks.values.uniq.each do |dst|
				srcs = OrigLinks.find_all{|e| dst == e[1]}.map{|e| e[0]}
				assert_equal(srcs.sort, cached.srcs(dst).sort)
			end
		end

		def testadd	# confirms addition of a day
			# write the diary for 2007-01-01
			cached = MySequel.new(@cache_path)
			cached.restore(@orig_dst_dates)
			cached.clean_dsts(Time.local(2007,1,1))
			cached.add('20070101#p01', '20060101#p01')
			assert_equal(['20070101#p01'], cached.srcs('20060101#p01'))
			cached.clean_srcs
			cached.commit
			# display the diary for 2006-01-01
			cached = MySequel.new(@cache_path)
			cached.restore(['20060101'])
			assert_equal(['20070101#p01'], cached.srcs('20060101#p01'))
			# confirmation of other links
			testsrcs
		end

		def testadd_two_months	# http://zunda.freeshell.org/d/20070122.html#c01
			# write the diary for 2007-02-15
			cached = MySequel.new(@cache_path)
			cached.restore('20070215')
			cached.clean_dsts(Time.local(2007,2,15))
			cached.add('20070215#p01', '20070115#p01')
			cached.clean_srcs
			cached.commit
			# write the diary for 2007-03-10
			cached = MySequel.new(@cache_path)
			cached.restore('20070310')
			cached.clean_dsts(Time.local(2007,3,10))
			cached.add('20070310#p01', '20070115#p01')
			cached.clean_srcs
			cached.commit
			# display the diary on 2007-01-15
			cached = MySequel.new(@cache_path)
			cached.restore('20070115')
			assert_equal(['20070215#p01', '20070310#p01'], cached.srcs('20070115#p01'))

		end

		def testedit	# confirms edition of a link
			# edit the diary for 2006-11-31
			cached = MySequel.new(@cache_path)
			cached.restore(@orig_dst_dates)
			cached.clean_dsts(Time.local(2006,11,30))
			cached.add('20061130#p01', '20060901#p01')
			cached.clean_srcs
			cached.commit
			# display the diary on 2006-09-01
			cached = MySequel.new(@cache_path)
			cached.restore(['20060901'])
			assert_equal(['20061130#p01'], cached.srcs('20060901#p01'))
			# display the diary on 2006-10-01
			cached.restore(['20061001'])
			assert_equal(['20061231#p02'], cached.srcs('20061001#p01'))
		end

		def testdelete	# confirms deletion of a link
			# edit the diary for 2006-11-31
			cached = MySequel.new(@cache_path)
			cached.restore(@orig_dst_dates)
			cached.clean_dsts(Time.local(2006,11,30))
			cached.clean_srcs
			cached.commit
			# display the diary on 2006-10-01
			cached.restore(['20061001'])
			assert_equal(['20061231#p02'], cached.srcs('20061001#p01'))
		end

		def teardown
			FileUtils.rmtree(@cache_path)
		end
	end

	class TestMySequelCss < Test::Unit::TestCase
		def test_usual
			assert_equal(<<"_TARGET", MySequel::css(<<'_INNER'))
\t<style type="text/css" media="all"><!--
\tdiv.sequel {
\t\thogehoge: &lt;mogemoge&gt;
\t}
\t--></style>
_TARGET
hogehoge: <mogemoge>
_INNER
		end

		def test_empty
			assert_equal('', MySequel::css(''))
		end

		def test_space
			assert_equal('', MySequel::css(' '))
		end

		def test_crlf
			assert_equal('', MySequel::css("\r\n"))
		end

	end

	class TestMySequelConf < Test::Unit::TestCase
		include ERB::Util

		def setup
			@defaults = {
				:label => {
					:title => 'Link label',
					:default => 'default label',
					:index => 1,
				},
				:format => {
					:title => 'Date format<sup>*</sup>',
					:description => 'Format of the dates of the link',
					:default => '<date>',
					:index => 2,
				},
				:textarea => {
					:title => 'Test to show text area',
					:default => "a\nb\ncc",
					:index => 3,
					:textarea => true,
				},
				:textarea_with_size => {
					:title => 'Test to show text area',
					:default => "a\nb\ncc",
					:index => 4,
					:textarea => {:rows => 2},
				}
			}
			@my_sequel_conf = MySequel::Conf.new(@defaults)
		end

		def testdefaults	# retrieve default configuration
			assert_equal('default label', @my_sequel_conf[:label])
		end

		def testmerge
			options = {'my_sequel.label' => 'configured label'}
			@my_sequel_conf.merge_hash(options)
			assert_equal('configured label', @my_sequel_conf[:label])
		end

		def testparams
			options = {'label' => ['configured label']}
			@my_sequel_conf.merge_params(options)
			assert_equal('configured label', @my_sequel_conf[:label])
		end

		def testparams_with_empty_array
			options = {'label' => ['configured label'], 'label.reset' => []}
			@my_sequel_conf.merge_params(options)
			assert_equal('configured label', @my_sequel_conf[:label])
		end

		def testtohash
			testmerge
			conf_hash = {'dummy' => 'dummy'}
			@my_sequel_conf.to_conf_hash(conf_hash)
			assert_equal({'my_sequel.label' => 'configured label', 'dummy' => 'dummy'}, conf_hash)
		end

		def testparams_with_empty
			testmerge
			options = {'label' => ['']}
			@my_sequel_conf.merge_params(options)
			assert_equal('', @my_sequel_conf[:label])
		end

		def testparams_with_reset
			testmerge
			options = {'label' => ['any value'], 'label.reset' => 't'}
			@my_sequel_conf.merge_params(options)
			assert_equal('default label', @my_sequel_conf[:label])
		end

		def test_delete_confhash
			options = {'my_sequel.label' => 'configured label'}
			@my_sequel_conf.merge_hash(options)
			params = {'label' => ['any value'],'label.reset' => 't'}
			@my_sequel_conf.merge_params(params)
			@my_sequel_conf.to_conf_hash(options)
			assert(!options.has_key?('my_sequel.label'))
		end

		def testparams_with_nil
			testmerge
			options = {'label' => nil}
			@my_sequel_conf.merge_params(options)
			assert_equal('configured label', @my_sequel_conf[:label])
		end

		def testparams_with_nokey
			testmerge
			options = {}
			@my_sequel_conf.merge_params(options)
			assert_equal('configured label', @my_sequel_conf[:label])
		end

		def testconfhtml
			target = <<_HTML
	<h3 class="subtitle">#{h @defaults[:label][:title]}</h3>
	<p><input name="label" id="label" type="text" value="#{h(@defaults[:label][:default])}" onfocus="uncheck(this)"> - Restore default:<input name="label.reset" id="label.reset" type="checkbox" value="t" onchange="restore(this)" onclick="restore(this)"></p>
	<h3 class="subtitle">#{h @defaults[:format][:title]}</h3>
	<p>#{h @defaults[:format][:description]}</p>
	<p><input name="format" id="format" type="text" value="#{h(@defaults[:format][:default])}" onfocus="uncheck(this)"> - Restore default:<input name="format.reset" id="format.reset" type="checkbox" value="t" onchange="restore(this)" onclick="restore(this)"></p>
	<h3 class="subtitle">#{h @defaults[:textarea][:title]}</h3>
	<p><textarea name="textarea" id="textarea" cols="70" rows="10" onfocus="uncheck(this)">a
b
cc</textarea> - Restore default:<input name="textarea.reset" id="textarea.reset" type="checkbox" value="t" onchange="restore(this)" onclick="restore(this)"></p>
	<h3 class="subtitle">#{h @defaults[:textarea_with_size][:title]}</h3>
	<p><textarea name="textarea_with_size" id="textarea_with_size" cols="70" rows="2" onfocus="uncheck(this)">a
b
cc</textarea> - Restore default:<input name="textarea_with_size.reset" id="textarea_with_size.reset" type="checkbox" value="t" onchange="restore(this)" onclick="restore(this)"></p>
_HTML
			assert_equal(target, @my_sequel_conf.html(' - Restore default:'))
		end

		def testconfhtml_mobile
			target = <<_HTML
	<h3 class="subtitle">#{h @defaults[:label][:title]}</h3>
	<p><input name="label" type="text" value="#{h(@defaults[:label][:default])}"> - Restore default:<input name="label.reset" type="checkbox" value="t"></p>
	<h3 class="subtitle">#{h @defaults[:format][:title]}</h3>
	<p><input name="format" type="text" value="#{h(@defaults[:format][:default])}"> - Restore default:<input name="format.reset" type="checkbox" value="t"></p>
	<h3 class="subtitle">#{h @defaults[:textarea][:title]}</h3>
	<p><textarea name="textarea" cols="70" rows="10">a
b
cc</textarea> - Restore default:<input name="textarea.reset" type="checkbox" value="t"></p>
	<h3 class="subtitle">#{@defaults[:textarea_with_size][:title]}</h3>
	<p><textarea name="textarea_with_size" cols="70" rows="2">a
b
cc</textarea> - Restore default:<input name="textarea_with_size.reset" type="checkbox" value="t"></p>
_HTML
			assert_equal(target, @my_sequel_conf.html(' - Restore default:', true))
		end

	end

end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
