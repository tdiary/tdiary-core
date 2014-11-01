#
# my-sequel.rb
#
# show links to follow-up entries
#
# Copyright 2006 zunda <zunda at freeshell.org> and
#                NISHIMURA Takashi <nt at be.to>
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work under the terms of GPL version 2 or later.
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
		dates = dates.is_a?(String) ? [dates] : dates
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

# register this plguin to tDiary
unless defined?(Test::Unit)
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
			:textarea => {rows: 5},
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
#{@my_sequel_conf.html(@my_sequel_restore_default_label, @cgi.mobile_agent?).chomp}
_HTML
	end

	@my_sequel = MySequel.new(@cache_path)
	@my_sequel_active = false

	# activate this plugin if header procs are called
	# - This avoids being called from makerss.rb
	add_header_proc do
		if not bot? and not @cgi.mobile_agent? then
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
		if @my_sequel_active and @my_sequel_date and @my_sequel_anchor and not bot? and not @cgi.mobile_agent? then
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
			if not bot? and not @cgi.mobile_agent? then
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
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
