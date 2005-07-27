# Copyright (C) 2005  akira yamada
# You can redistribute it and/or modify it under GPL2.

add_conf_proc('spamfilter', @spamfilter_label_conf) do
	if @mode == 'saveconf'
		if @cgi.params['spamfilter.max_uris'] &&
				@cgi.params['spamfilter.max_uris'][0] &&
				/\A\d+\z/ =~ @cgi.params['spamfilter.max_uris'][0]
			@conf['spamfilter.max_uris'] = @cgi.params['spamfilter.max_uris'][0]
		else
			@conf['spamfilter.max_uris'] = 0
		end

		if @cgi.params['spamfilter.max_rate'] &&
				@cgi.params['spamfilter.max_rate'][0] &&
				/\A\d*(?:\.\d*)\z/ =~ @cgi.params['spamfilter.max_rate'][0]
			@conf['spamfilter.max_rate'] = @cgi.params['spamfilter.max_rate'][0]
		else
			@conf['spamfilter.max_rate'] = 0.0
		end

		if @cgi.params['spamfilter.bad_uri_patts'] &&
				@cgi.params['spamfilter.bad_uri_patts'][0]
			@conf['spamfilter.bad_uri_patts'] = 
					@cgi.params['spamfilter.bad_uri_patts'][0]
		else
			@conf['spamfilter.bad_uri_patts'] = ''
		end

		if @cgi.params['spamfilter.bad_mail_patts'] &&
				@cgi.params['spamfilter.bad_mail_patts'][0]
			@conf['spamfilter.bad_mail_patts'] = 
					@cgi.params['spamfilter.bad_mail_patts'][0]
		else
			@conf['spamfilter.bad_mail_patts'] = ''
		end

		if @cgi.params['spamfilter.bad_comment_patts'] &&
				@cgi.params['spamfilter.bad_comment_patts'][0]
			@conf['spamfilter.bad_comment_patts'] = 
					@cgi.params['spamfilter.bad_comment_patts'][0]
		else
			@conf['spamfilter.bad_comment_patts'] = ''
		end

		if @cgi.params['spamfilter.bad_ip_addrs'] &&
				@cgi.params['spamfilter.bad_ip_addrs'][0]
			@conf['spamfilter.bad_ip_addrs'] = 
					@cgi.params['spamfilter.bad_ip_addrs'][0]
		else
			@conf['spamfilter.bad_ip_addrs'] = ''
		end

		if @cgi.params['spamfilter.bad_uri_patts_for_mails'] &&
				@cgi.params['spamfilter.bad_uri_patts_for_mails'][0] &&
				@cgi.params['spamfilter.bad_uri_patts_for_mails'][0] == "true"
			@conf['spamfilter.bad_uri_patts_for_mails'] = true
		else
			@conf['spamfilter.bad_uri_patts_for_mails'] = false
		end

		if @cgi.params['spamfilter.resolv_check'] &&
				@cgi.params['spamfilter.resolv_check'][0] &&
				@cgi.params['spamfilter.resolv_check'][0] == "true"
			@conf['spamfilter.resolv_check'] = true
		else
			@conf['spamfilter.resolv_check'] = false
		end

		unless @conf.secure then
			if @cgi.params['spamfilter.debug_mode'] &&
					@cgi.params['spamfilter.debug_mode'][0] &&
					@cgi.params['spamfilter.debug_mode'][0] == "true"
				@conf['spamfilter.debug_mode'] = true
			else
				@conf['spamfilter.debug_mode'] = false
			end
	
			if @cgi.params['spamfilter.debug_file'] && 
					@cgi.params['spamfilter.debug_file'][0]
				@conf['spamfilter.debug_file'] = 
						@cgi.params['spamfilter.debug_file'][0]
			else
				@conf['spamfilter.debug_file'] = nil
			end
		end
	end

	spamfilter_conf_html
end

# vim: ts=3
