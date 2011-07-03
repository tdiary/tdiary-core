# -*- coding: utf-8; -*-
=begin
== String class
enhanced String class
=end
class String
	def make_link
		r = %r<(((http[s]{0,1}|ftp)://[\(\)%#!/0-9a-zA-Z_$@.&+-,'"*=;?:~-]+)|([0-9a-zA-Z_.-]+@[\(\)%!0-9a-zA-Z_$.&+-,'"*-]+\.[\(\)%!0-9a-zA-Z_$.&+-,'"*-]+))>
		return self.
			gsub( / /, "\001" ).
			gsub( /</, "\002" ).
			gsub( />/, "\003" ).
			gsub( /&/, '&amp;' ).
			gsub( /\"/, "\004").
			gsub( r ){ $1 == $2 ? "<a href=\"#$2\">#$2</a>" : "<a href=\"mailto:#$4\">#$4</a>" }.
			gsub( /\004/, '&quot;' ).
			gsub( /\003/, '&gt;' ).
			gsub( /\002/, '&lt;' ).
			gsub( /^\001+/ ) { $&.gsub( /\001/, '&nbsp;' ) }.
			gsub( /\001/, ' ' ).
			gsub( /\t/, '&nbsp;' * 8 )
	end
end

=begin
== CGI class
enhanced CGI class
=end
class CGI
	include TDiary::RequestExtension

	def valid?( param, idx = 0 )
		self.params[param] and self.params[param][idx] and self.params[param][idx].length > 0
	end

	def https?
		return false if env_table['HTTPS'].nil? or /off/i =~ env_table['HTTPS']
		true
	end

	def request_uri
		_request_uri = env_table['REQUEST_URI']
		_script_name = env_table['SCRIPT_NAME']
		if !_request_uri || _request_uri == '' || _request_uri == _script_name then
			_path_info    = env_table['PATH_INFO'] || ''
			_query_string = env_table['QUERY_STRING'] || ''
			# Workaround for IIS-style PATH_INFO ('/dir/script.cgi/path', not '/path')
			# See http://support.microsoft.com/kb/184320/
			_request_uri = _path_info.include?(_script_name) ? '' : _script_name.dup
			_request_uri << _path_info
			_request_uri << '?' + _query_string if _query_string != ''
		end
		_request_uri
	end

	def redirect_url
		env_table['REDIRECT_URL']
	end
end

=begin
== Safe module
=end
module Safe
	def safe( level = 4 )
		result = nil
		if $SAFE < level then
			Proc.new {
				$SAFE = level
				result = yield
			}.call
		else
			result = yield
		end
		result
	end
	module_function :safe
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
