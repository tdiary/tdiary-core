# Copyright (C) 2005  akira yamada
# You can redistribute it and/or modify it under GPL2.

add_conf_proc( 'spamfilter', @spamfilter_label_conf, 'security' ) do
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
				/\A\d*\z/ =~ @cgi.params['spamfilter.max_rate'][0]
			@conf['spamfilter.max_rate'] = @cgi.params['spamfilter.max_rate'][0]
		else
			@conf['spamfilter.max_rate'] = 0
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

		if @cgi.params['spamfilter.resolv_check_mode'] &&
				@cgi.params['spamfilter.resolv_check_mode'][0] &&
				@cgi.params['spamfilter.resolv_check_mode'][0] == "false"
		  @conf['spamfilter.resolv_check_mode'] = false
		else
		  @conf['spamfilter.resolv_check_mode'] = true
		end

		if @cgi.params['spamfilter.filter_mode'] &&
				@cgi.params['spamfilter.filter_mode'][0] &&
				@cgi.params['spamfilter.filter_mode'][0] == "false"
		  @conf['spamfilter.filter_mode'] = false
		else
		  @conf['spamfilter.filter_mode'] = true
		end

		unless @conf.secure then
			if @cgi.params['filter.debug_mode'] && @cgi.params['filter.debug_mode'][0]
				@conf['filter.debug_mode'] = @cgi.params['filter.debug_mode'][0].to_i
			else
				@conf['filter.debug_mode'] = 0
			end

			if @cgi.params['filter.debug_file'] && @cgi.params['filter.debug_file'][0]
				@conf['filter.debug_file'] = @cgi.params['filter.debug_file'][0]
			else
				@conf['filter.debug_file'] = nil
			end

			if @cgi.params['spamfilter.date_limit'] &&
					@cgi.params['spamfilter.date_limit'][0] &&
					/\A\d+\z/ =~ @cgi.params['spamfilter.date_limit'][0]
				@conf['spamfilter.date_limit'] = @cgi.params['spamfilter.date_limit'][0]
			else
				@conf['spamfilter.date_limit'] = nil
			end
		end

		if @conf['spamfilter.filter_mode'].nil? || @conf['spamfilter.filter_mode']
			filter_mode = true
		else
			filter_mode = false
		end

		if @conf['spamfilter.resolv_check_mode'].nil? || @conf['spamfilter.resolv_check_mode']
			resolv_check_mode = true
		else
			resolv_check_mode = false
		end

		if @cgi.params['spamlookup.domain.list'] && @cgi.params['spamlookup.domain.list'][0]
			@conf['spamlookup.domain.list'] = @cgi.params['spamlookup.domain.list'][0]
		else
			@conf['spamlookup.domain.list'] = nil
		end

		if @cgi.params['spamlookup.safe_domain.list'] && @cgi.params['spamlookup.safe_domain.list'][0]
			@conf['spamlookup.safe_domain.list'] = @cgi.params['spamlookup.safe_domain.list'][0]
		else
			@conf['spamlookup.safe_domain.list'] = nil
		end

	end

	# initialize DNSBL list
	@conf['spamlookup.domain.list'] ||= "bsb.spamlookup.net\nsc.surbl.org\nrbl.bulkfeeds.jp"

	# initialize safe domain list.
	@conf['spamlookup.safe_domain.list'] ||= "search.yahoo.co.jp\nwww.google.com\nwww.google.co.jp\nsearch.msn.co.jp"

	spamfilter_conf_html
end

# vim: ts=3
