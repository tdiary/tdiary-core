require 'redis'
require 'redis-namespace'
require 'yaml'

module TDiary
	module Cache
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
			obj = redis.get(key)
			if obj.nil?
				nil
			else
				YAML.load(obj)
			end
		end

		def store_data(data, key)
			redis.set(key, YAML.dump(data))
		end

		def delete_data(key)
			if key == :all
				redis.flushdb
			else
				redis.del(key)
			end
		end

		def restore_parser_cache(date, key = nil)
			obj = redis.get(date.strftime("%Y%m.parser"))
			if obj.nil?
				nil
			else
				YAML.load(obj)
			end
		end

		def store_parser_cache(date, obj, key = nil)
			redis.set(date.strftime("%Y%m.parser"), YAML.dump(obj))
		end

		def clear_parser_cache(date)
			redis.flushdb
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

		def redis
			@_client ||= if @tdiary.conf.user_name
								 Redis::Namespace.new(@tdiary.conf.user_name.to_sym, Redis.new)
							 else
								 Redis.new
							 end
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
