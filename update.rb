#!/usr/bin/env ruby
# update.rb $Revision: 1.1 $
$KCODE= 'e'
BEGIN { $defout.binmode }

begin
	if FileTest::symlink?( __FILE__ ) then
		org_path = File::dirname( File::readlink( __FILE__ ) )
	else
		org_path = File::dirname( __FILE__ )
	end
	require "#{org_path}/tdiary"
	
	@cgi = CGI::new
	tdiary = nil

	begin
		if @cgi.valid?( 'append' )
			tdiary = TDiaryAppend::new( @cgi, 'show.rhtml' )
		elsif @cgi.valid?( 'edit' )
			tdiary = TDiaryEdit::new( @cgi, 'update.rhtml' )
		elsif @cgi.valid?( 'replace' )
			tdiary = TDiaryReplace::new( @cgi, 'show.rhtml' )
		elsif @cgi.valid?( 'comment' )
			tdiary = TDiaryShowComment::new( @cgi, 'update.rhtml' )
		elsif @cgi.valid?( 'conf' )
			tdiary = TDiaryConf::new( @cgi, 'conf.rhtml' )
		elsif @cgi.valid?( 'referer' )
			tdiary = TDiaryConf::new( @cgi, 'referer.rhtml' )
		elsif @cgi.valid?( 'saveconf' )
			tdiary = TDiarySaveConf::new( @cgi, 'conf.rhtml' )
		else
			tdiary = TDiaryForm::new( @cgi, 'update.rhtml' )
		end
	rescue TDiary::TDiaryError
		tdiary = TDiaryForm::new( @cgi, 'update.rhtml' )
	end

	head = body = ''
	if @cgi.mobile_agent? then
		body = tdiary.eval_rhtml( 'i.' ).to_sjis
		head = @cgi.header(
			'type' => 'text/html',
			'charset' => 'Shift_JIS',
			'Content-Length' => body.size.to_s,
			'Vary' => 'User-Agent'
		)
	else
		body = tdiary.eval_rhtml
		head = @cgi.header(
			'type' => 'text/html',
			'charset' => 'EUC-JP',
			'Content-Length' => body.size.to_s,
			'Vary' => 'User-Agent'
		)
	end
	print head
	print body if /HEAD/i !~ @cgi.request_method
rescue Exception
	puts "Content-Type: text/plain\n\n"
	puts "#$! (#{$!.type})"
	puts ""
	puts $@.join( "\n" )
end

