#
# pstoreio.rb: tDiary IO class of tdiary 1.x format. $Revision: 1.1 $
#
require 'pstore'

class TDiary
	class PStoreIO
		def initialize( data_path )
			@data_path = data_path
		end
	
		#
		# block must be return boolean which dirty diaries.
		#
		def transaction( date, diaries = {} )
			filename = date.strftime( "#{@data_path}%Y%m" )
			begin
				PStore::new( filename ).transaction do |db|
					dirty = false
					begin
						diaries.update( db['diary'] )
					rescue PStore::Error
					end
					dirty = yield( diaries ) if iterator?
					if dirty then
						db['diary'] = diaries
					else
						db.abort
					end
				end
			rescue PStore::Error, NameError, Errno::EACCES
				raise PermissionError::new( 'make your @data_path to writable via httpd.' )
			end
			File::delete( filename ) if diaries.empty?
			return diaries
		end

		def calendar
			calendar = {}
			Dir["#{@data_path}??????"].sort.each do |file|
				year, month = file.scan( %r[/(\d{4})(\d\d)$] )[0]
				next unless year
				calendar[year] = [] unless calendar[year]
				calendar[year] << month
			end
			calendar
		end
	end
end

=begin
== Paragraph class
Management a paragraph.
=end
class Paragraph
	attr_reader :subtitle, :body

	def initialize( fragment, author = nil )
		@author = author
		lines = fragment.split( /\n+/ )
		if lines.size > 1 then
			if /^<</ =~ lines[0]
				@subtitle = lines.shift.chomp.sub( /^</, '' )
			elsif /^[ ¡¡<]/ !~ lines[0]
				@subtitle = lines.shift.chomp
			end
		end
		@body = lines.join( "\n" )
	end

	def text
		s = ''
		if @subtitle then
			s += "[#{@author}]" if @author
			s += '<' if /^</ =~ @subtitle
			s += @subtitle + "\n"
		end
		"#{s}#{@body}\n\n"
	end

	def to_s
		"subtitle=#{@subtitle}, body=#{@body}"
	end

	def author
		@author = @auther unless @author
		@author
	end
end

=begin
== Diary class
Management a day of diary
=end
class Diary
	attr_reader :date, :title

	def initialize( date, title, body )
		@referers = {}
		@new_referer = true # for compatibility
		@comments = []
		@show = true
		replace( date, title, body )
	end

	def replace( date, title, body )
		@date, @title = date, title
		@paragraphs = []
		append( body )
	end

	def append( body, author = nil )
		body.gsub( "\r", '' ).split( /\n\n+/ ).each do |fragment|
			paragraph = Paragraph::new( fragment, author )
			@paragraphs << paragraph if paragraph
		end
		@last_modified = Time::now
		self
	end

	def title=( t )
		@title = t
		@last_modified = Time::now
	end

	def each_paragraph
		@paragraphs.each do |paragraph|
			yield paragraph
		end
	end

	def last_modified
		@last_modified ? @last_modified : Time::at( 0 )
	end

	def add_referer( ref )
		newer_referer
		ref = ref.sub( /#.*$/, '' ).sub( /\?\d{8}$/, '' )
		if /^([^:]+:\/\/)([^\/]+)/ =~ ref
			ref = $1 + $2.downcase + $'
		end
		uref = CGI::unescape( ref )
		if pair = @referers[uref] then
			pair = [pair, ref] if pair.type != Array # for compatibility
			@referers[uref] = [pair[0]+1, pair[1]]
		else
			@referers[uref] = [1, ref]
		end
	end

	def count_referers
		@referers.size
	end

	def each_referer( limit = 10 )
		newer_referer
		@referers.values.sort.reverse.each_with_index do |ary,idx|
			break if idx >= limit
			yield ary
		end
	end

	def newer_referer
		unless @new_referer then # for compatibility
			@referers.keys.each do |ref|
				count = @referers[ref]
				if count.type != Array then
					@referers.delete( ref )
					@referers[CGI::unescape( ref )] = [count, ref]
				end
			end
			@new_referer = true
		end
	end

	def reset_referer; @referers = {}; end

	def add_comment( com )
		if @comments[-1] != com then
			@comments << com
			@last_modified = Time::now
			com
		else
			nil
		end
	end

	def count_comments( all = false )
		i = 0
		@comments.each do |comment|
			i += 1 if all or comment.visible?
		end
		i
	end

	def each_comment( limit = 3 )
		@comments.each_with_index do |com,idx|
			break if idx >= limit
			yield com
		end
	end

	def each_comment_tail( limit = 3 )
		idx = 0
		comments = @comments.collect {|c|
			idx += 1
			if c.visible? then
				[c, idx]
			else
				nil
			end
		}.compact
		s = comments.size - limit
		s = 0 if s < 0
		for idx in s...comments.size
			yield comments[idx]
		end
	end
	
	def reset_comment; @comments = []; end

	def eval_rhtml( opt, path = '.' )
		ERbLight::new( File::open( "#{path}/skel/#{opt['prefix']}diary.rhtml" ){|f| f.read }.untaint ).result( binding )
	end

	def disp_referer( table, ref )
		ref = CGI::unescape( ref )
		str = nil
		table.each do |url, name|
			if /#{url}/i =~ ref then
				str = ref.gsub( /#{url}/in, name )
				break
			end
		end
		str ? str.to_euc : ref.to_euc
	end

	def visible?; @show != false; end
	def show( s ); @show = s; end

	def to_s
		"date=#{@date.strftime('%Y%m%d')}, title=#{@title}, body=[#{@paragraphs.join('][')}]"
	end
end

