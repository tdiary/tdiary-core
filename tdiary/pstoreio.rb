#
# pstoreio.rb: tDiary IO class of tdiary 1.x format. $Revision: 1.2 $
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

	include CommentManager
	include RefererManager

	def initialize( date, title, body )
		init_comments
		init_referers
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

	def last_modified=( time )
		@last_modified = time
	end

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

