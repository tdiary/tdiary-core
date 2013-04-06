require 'dalli'

module TDiary
	module CacheIO
		def restore_cache(prefix)
			if key = cache_key(prefix)
				restore_data(key)
			end
		end

		def store_cache(cache, prefix)
			if key = cache_key(prefix)
				store_data(cache, key)
			end
		end

		def clear_cache(target = :all)
			if target == :all
				delete_data(:all)
			else
				ym = target.to_s.scan(/\d{4}\d{2}/)[0]
				['latest.rb', 'i.latest.rb', "#{ym}.rb", "i.#{ym}.rb"].each do |key|
					delete_data(key)
				end
			end
		end

		private

		def restore_data(key)
			memcache.get(key)
		end

		def store_data(data, key)
			memcache.set(key, data)
		end

		def delete_data(key)
			if key == :all
				memcache.flush
			else
				memcache.delete(key)
			end
		end

		def restore_parser_cache(date, key = nil)
			restore_data(date.strftime("%Y%m.parser"))
		end

		def store_parser_cache(date, obj, key = nil)
			store_data(obj, date.strftime("%Y%m.parser"))
		end

		def clear_parser_cache(*args)
			delete_data(:all)
		end

		def cache_key(prefix)
			if @tdiary.is_a?(TDiaryMonth)
				"#{prefix}#{@tdiary.rhtml.sub( /month/, @tdiary.date.strftime( '%Y%m' ) ).sub( /\.rhtml$/, '.rb' )}"
			elsif @tdiary.is_a?(TDiaryLatest)
				if @tdiary.cgi.params['date'][0]
					nil
				else
					"#{prefix}#{@tdiary.rhtml.sub( /\.rhtml$/, '.rb' )}"
				end
			else
				nil
			end
		end

		def memcache
			options = {}
			if @tdiary.conf.user_name
				options.merge!({:namespace => @tdiary.conf.user_name})
			end
			@_client ||= Dalli::Client.new(nil, options)
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
