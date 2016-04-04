#!/usr/bin/env ruby
#
# migrate.rb $Revision: 1.2 $
#
# Copyright (C) 2001-2003, TADA Tadashi <sho@spc.gr.jp>
# Copyright (C) 2007, Kazuhiko <kazuhiko@fdiary.net>
# You can redistribute it and/or modify it under GPL2 or any later version.
#
BEGIN { $stdout.binmode }

require "fileutils"
require "pstore"

begin
	if FileTest::symlink?( __FILE__ ) then
		org_path = File::dirname( File::readlink( __FILE__ ) )
	else
		org_path = File::dirname( __FILE__ )
	end
	$:.unshift( org_path.untaint )
	require 'tdiary'

	class TDiary::MigrateConfig < TDiary::Config
		include ERB::Util

		def load_cgi_conf
			raise TDiaryError, 'No @data_path variable.' unless @data_path

			@data_path += '/' if /\/$/ !~ @data_path
			raise TDiaryError, 'Do not set @data_path as same as tDiary system directory.' if @data_path == "#{TDiary::PATH}/"

			# convert tdiary.conf in @data_path
			conf_path = "#{@data_path}tdiary.conf"
			conf = convert( File::open( conf_path ){|f| f.read } )
			conf.gsub!(/(\\[0-9]{3})+/) do |str|
				convert(eval(%Q["#{$&}"])).dump[1...-1]
			end
			File::open( conf_path, 'w' ) do |o|
				o.print conf
			end

			# convert diary data and comment data
			Dir["#{@data_path}[0-9][0-9][0-9][0-9]/??????.td[2c]"].each do |file|
				convert_file(file)
			end

			# convert pstore cache files
			dir = cache_path || "#{@data_path}cache"
			%w(makerss.cache recent_comments recent_trackbacks tlink/tlink.dat).each do |e|
				convert_pstore("#{dir}/#{e}") if File.exist?("#{dir}/#{e}")
			end
			Dir["#{dir}/disp_referrer2.d/*"].each do |file|
				convert_pstore(file)
			end
			Dir["#{@data_path}category/*"].each do |file|
				convert_pstore(file)
			end

			# rename category cache files
			Dir["#{@data_path}category/*"].each do |file|
				dirname, basename = File.split(file)
				new_basename = u(convert(CGI::unescape(basename)))
				FileUtils.mv(file, File.join(dirname, new_basename)) unless basename == new_basename
			end

			# remove ruby/erb cache files
			Dir["#{dir}/*.rb"].each{|f| FileUtils.rm_f(f)}
			Dir["#{dir}/*.parser"].each{|f| FileUtils.rm_f(f)}
		end

		def convert_pstore(file)
			db = PStore.new(file)
			begin
				roots = db.transaction{ db.roots }
			rescue ArgumentError
				if /\Aundefined class\/module (.+?)(::)?\z/ =~ $!.message
					klass = $1
					if /EmptdiaryString\z/ =~ klass
						eval("class ::#{klass} < String; end")
					else
						eval("class ::#{klass}; end")
					end
					retry
				end
			end
			db.transaction do
				roots.each do |root|
					convert_element(db[root])
				end
			end
		end

		def convert_element(data)
			case data
			when Hash, Array
				data.each_with_index do |e, i|
					if String === e
						data[i] = convert(e)
					else
						convert_element(e)
					end
				end
			else
				data.instance_variables.each do |e|
					var = data.instance_variable_get(e)
					if String === var
						data.instance_variable_set(e, convert(var))
					else
						convert_element(var)
					end
				end
			end
		end

		def convert_file(file)
			body = convert( File::open( file ){|f| f.read} )
			File::open( file, 'w' ) do |o|
				o.print body
			end
		end

		def convert(str)
			str.class.new(to_native(str, 'EUC-JP'))
		end
	end

	@cgi = CGI::new
	TDiary::MigrateConfig::new(@cgi)

	print @cgi.header( 'status' => '200 OK', 'type' => 'text/html' )
	puts "<h1>Migration completed.</h1>"
	puts "<p>Do not forget to remove migrate.rb.</p>"

rescue Exception
	if @cgi then
		print @cgi.header( 'status' => '500 Internal Server Error', 'type' => 'text/html' )
	else
		print "Status: 500 Internal Server Error\n"
		print "Content-Type: text/html\n\n"
	end
	puts "<h1>500 Internal Server Error</h1>"
	puts "<pre>"
	puts CGI::escapeHTML( "#{$!} (#{$!.class})" )
	puts ""
	puts CGI::escapeHTML( $@.join( "\n" ) )
	puts "</pre>"
	puts "<div>#{' ' * 500}</div>"
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
