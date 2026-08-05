module TDiary
	#
	# class TDiaryAuthorOnlyBase
	#  base class for author-only access pages
	#
	class TDiaryAuthorOnlyBase < TDiaryBase
		def csrf_protection_get_is_okay; false; end

		# pure decision helpers for csrf_check, class methods so unit specs
		# can exercise them without building a full TDiaryBase

		# referer must be non-empty with its query string stripped; it is
		# allowed when it names the update page itself or matches the
		# admin-configured regexp
		def self.csrf_referer_allowed?( referer, config_uri, allowed_referer_regexp )
			return true if config_uri == URI.parse( referer )
			allowed_referer_regexp != '' && Regexp.new( allowed_referer_regexp ).match?( referer )
		end

		# normalize an absolute http(s) URL to its origin serialization
		# (lowercase scheme://host, default port omitted); nil when the
		# input has no usable origin
		def self.csrf_origin_of( url )
			uri = URI.parse( url.to_s )
			return nil unless uri.kind_of?( URI::HTTP ) and uri.host
			port = uri.port == uri.default_port ? '' : ":#{uri.port}"
			"#{uri.scheme.downcase}://#{uri.host.downcase}#{port}"
		rescue URI::InvalidURIError
			nil
		end

		# classify the request provenance from browser fetch metadata:
		# :same_origin / :cross_site / :unknown (no usable signal, e.g.
		# non-browser clients or a user-initiated navigation)
		def self.csrf_fetch_verdict( origin, sec_fetch_site, allowed_origins )
			if origin and !origin.empty?
				# 'null' (sandboxed or opaque initiators) never matches
				return allowed_origins.include?( origin.downcase ) ? :same_origin : :cross_site
			end
			case sec_fetch_site
			when 'same-origin'
				:same_origin
			when 'same-site', 'cross-site'
				:cross_site
			else
				:unknown
			end
		end

		# main csrf decision: Origin / Sec-Fetch-Site first, the legacy
		# Referer check only as a fallback when neither header gives a
		# usable signal. A cross-site verdict can still be allowed by an
		# explicit Referer allowance (the update page itself or the
		# admin-configured regexp), but not by the empty-referer tolerance
		# of check_referer=false.
		def self.csrf_provenance_ok?( origin, sec_fetch_site, referer, allowed_origins, config_uri, allowed_referer_regexp, check_referer )
			case csrf_fetch_verdict( origin, sec_fetch_site, allowed_origins )
			when :same_origin
				true
			when :cross_site
				referer != '' && csrf_referer_allowed?( referer, config_uri, allowed_referer_regexp )
			else
				if referer == ''
					!check_referer
				else
					csrf_referer_allowed?( referer, config_uri, allowed_referer_regexp )
				end
			end
		end

		def initialize( cgi, rhtml, conf )
			super
			csrf_check( @request, conf )
		end

	private

		def csrf_check( request, conf )
			# CSRF condition check
			protection_method = conf.options['csrf_protection_method']
			masterkey = conf.options['csrf_protection_key']
			updaterb_regexp = conf.options['csrf_protection_allowed_referer_regexp_for_update']

			protection_method = 1 unless protection_method

			return if protection_method == -1 # don't use this setting!

			check_key = (protection_method & 2 != 0)
			check_referer = (protection_method & 1 != 0)

			masterkey = '' unless masterkey

			updaterb_regexp = '' unless updaterb_regexp

			if (masterkey != '' && check_key)
				@csrf_protection = %Q[<input type="hidden" name="csrf_protection_key" value="#{h masterkey}">]
			else
				@csrf_protection="<!-- no CSRF protection key used -->"
			end

			referer = request.referer || ''
			referer = referer.sub(/\?.*$/, '')
			base_uri = URI.parse(base_url)
			config_uri = URI.parse(base_url) + conf.update

			referer_is_empty = referer == ''
			referer_uri = URI.parse(referer) if !referer_is_empty
			referer_is_config = !referer_is_empty && self.class.csrf_referer_allowed?(referer, config_uri, updaterb_regexp)
			is_post = request.post?

			given_key = request.params['csrf_protection_key']
			given_key = nil if given_key == ''

			is_key_ok = masterkey != '' && given_key == masterkey

			keycheck_ok = !check_key || is_key_ok

			origin = request.env['HTTP_ORIGIN']
			sec_fetch_site = request.env['HTTP_SEC_FETCH_SITE']
			allowed_origins = [base_uri, config_uri, request.base_url].map {|url|
				self.class.csrf_origin_of( url )
			}.compact.uniq
			provenance_ok = self.class.csrf_provenance_ok?( origin, sec_fetch_site, referer, allowed_origins, config_uri, updaterb_regexp, check_referer )

			if csrf_protection_get_is_okay then
				return if is_post || given_key == nil
			else
				return if keycheck_ok && provenance_ok
			end

			raise Exception.new(<<"EOS")
Security Error: Possible Cross-site Request Forgery (CSRF)

        Diagnostics:
                - Protection Method is #{ protection_method }
                - Mode is #{ self.mode || 'unknown' }
                    - GET is #{ csrf_protection_get_is_okay ? '' : 'not '}allowed
                - Request Method is #{ is_post ? 'POST' : 'not POST' }
                - Origin is #{ origin ? h(origin) : 'nothing' }
                - Sec-Fetch-Site is #{ sec_fetch_site ? h(sec_fetch_site) : 'nothing' }
                - Referer is #{ referer_is_empty ? 'empty' : referer_is_config ? 'config' : 'another page' }
                    - Given referer:       #{h referer_uri.to_s}
                    - Expected base URI:   #{h base_uri.to_s}
                    - Expected update URI: #{h config_uri.to_s}
                - CSRF key is #{ is_key_ok ? 'OK' : given_key ? 'NG (' + (given_key || '') + ')' : 'nothing' }
EOS
		end

		def load_plugins
			super
			@plugin.instance_eval("def csrf_protection\n#{(@csrf_protection || '').dump}\nend;")
		end
	end

	#
	# class TDiaryFormPlugin
	#  show edit diary form after calling form plugin.
	#
	class TDiaryFormPlugin < TDiaryAuthorOnlyBase
		def initialize( cgi, rhtm, conf )
			super

			if @request.valid?( 'date' ) then
				if @request.param('date').kind_of?( String ) then
					date = @request.param('date')
				else
					date = @request.param('date').read
				end
				@date = Time::local( *date.scan( /(\d{4})(\d\d)(\d\d)/ )[0] )
			else
				@date = Time::now + (@conf.hour_offset * 3600).to_i
				@diary = @io.diary_factory( @date, '', '', @conf.style )
			end

			@io.transaction( @date ) do |diaries|
				@diaries = diaries
				@diary = self[@date]
				if @diary then
					@conf.style = @diary.style
				else
					@diary =  @io.diary_factory( @date, '', '', @conf.style )
				end
				DIRTY_NONE
			end
		end
	end

	#
	# class TDiaryConf
	#  show configuration form
	#
	class TDiaryConf < TDiaryAuthorOnlyBase
		def csrf_protection_get_is_okay; true; end

		def initialize( cgi, rhtml, conf )
			super
			@key = @request.param('conf') || ''
		end
	end

	#
	# class TDiarySaveConf
	#  save configuration
	#
	class TDiarySaveConf < TDiaryConf
		def csrf_protection_get_is_okay; false; end

		def initialize( cgi, rhtml, conf )
			super
		end

		def eval_rhtml( prefix = '' )
			r = super

			begin
				@conf.save
				@io.clear_cache
			rescue
				@error = [$!.dup, $@.dup]
			end

			r
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
