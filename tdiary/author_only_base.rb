module TDiary
	#
	# class TDiaryAuthorOnlyBase
	#  base class for author-only access pages
	#
	class TDiaryAuthorOnlyBase < TDiaryBase
		def csrf_protection_get_is_okay; false; end

		def initialize( cgi, rhtml, conf )
			super
			csrf_check( cgi, conf )
		end

	private

		def csrf_check( cgi, conf )
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

			referer = cgi.referer || ''
			referer = referer.sub(/\?.*$/, '')
			base_uri = URI.parse(base_url)
			config_uri = URI.parse(base_url) + conf.update

			referer_is_empty = referer == ''
			referer_uri = URI.parse(referer) if !referer_is_empty
			referer_is_config = !referer_is_empty && config_uri == referer_uri
			referer_is_config ||= Regexp.new(updaterb_regexp) =~ referer if !referer_is_empty && updaterb_regexp != ''
			is_post = cgi.request_method == 'POST'

			given_key = nil
			if cgi.valid?('csrf_protection_key')
				given_key = cgi.params['csrf_protection_key'][0]
				case given_key
				when String
				else
					given_key = given_key.read
				end
			end

			is_key_ok = masterkey != '' && given_key == masterkey

			keycheck_ok = !check_key || is_key_ok
			referercheck_ok = referer_is_config || (!check_referer && referer_is_empty)

			if csrf_protection_get_is_okay then
				return if is_post || given_key == nil
			else
				return if keycheck_ok && referercheck_ok
			end

			raise Exception.new(<<"EOS")
Security Error: Possible Cross-site Request Forgery (CSRF)

        Diagnostics:
                - Protection Method is #{ protection_method }
                - Mode is #{ self.mode || 'unknown' }
                    - GET is #{ csrf_protection_get_is_okay ? '' : 'not '}allowed
                - Request Method is #{ is_post ? 'POST' : 'not POST' }
                - Referer is #{ referer_is_empty ? 'empty' : referer_is_config ? 'config' : 'another page' }
                    - Given referer:       #{h referer_uri.to_s}
                    - Expected base URI:   #{h base_uri.to_s}
                    - Expected update URI: #{h config_uri.to_s}
                - CSRF key is #{ is_key_ok ? 'OK' : given_key ? 'NG (' + (given_key || '') + ')' : 'nothing' }
EOS
		end

		def load_plugins
			super
			@plugin.instance_eval("def csrf_protection\n#{(@csrf_protection.untaint || '').dump}\nend;")
		end
	end

	#
	# class TDiaryFormPlugin
	#  show edit diary form after calling form plugin.
	#
	class TDiaryFormPlugin < TDiaryAuthorOnlyBase
		def initialize( cgi, rhtm, conf )
			super

			if @cgi.valid?( 'date' ) then
				if @cgi.params['date'][0].kind_of?( String ) then
					date = @cgi.params['date'][0]
				else
					date = @cgi.params['date'][0].read
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
			@key = @cgi.params['conf'][0] || ''
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
