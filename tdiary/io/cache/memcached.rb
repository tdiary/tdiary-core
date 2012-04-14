require 'dalli'

module TDiary
  module CacheIO
    def restore_cache(prefix)
      if key = cache_key(prefix)
        memcache.get(key)
      end
    end

    def store_cache(cache, prefix)
      if key = cache_key(prefix)
        memcache.set(key, cache)
      end
    end

    def clear_cache(target = :all)
      if target == :all
        memcache.flush
      else
        ym = target.to_s.scan(/\d{4}\d{2}/)[0]
        ['latest.rb', 'i.latest.rb', "#{ym}.rb", "i.#{ym}.rb"].each do |key|
          memcache.delete(key)
        end
      end
    end

  private

    def restore_parser_cache(date, key = nil)
      memcache.get(date.strftime("%Y%m.parser"))
    end

    def store_parser_cache(date, obj, key = nil)
      memcache.set(date.strftime("%Y%m.parser"), obj)
    end

    def clear_parser_cache(date)
      memcache.flush
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
      @_client ||= Dalli::Client.new
    end
  end
end
