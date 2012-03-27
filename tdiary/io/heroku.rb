# -*- coding: utf-8 -*-
#
# heroku_io.rb: Heroku IO for tDiary 3.x
#
# NAME             heroku_io
#
# DESCRIPTION      Heroku 向け tDiary IO クラス
#                  日記データは PostgreSQL に保存、キャッシュ、リンク元の記録には未対応
#
# Copyright        (C) 2003 ma2tak <ma2tak@ma2tak.dyndns.org>
#                  (C) 2004 moonwolf <moonwolf@mooonwolf.com>
#                  (C) 2005 Kazuhiko <kazuhiko@fdiary.net>
#                  (C) 2012 hsbt <shibata.hiroshi@gmail.com>
#
# You can distribute this under GPL.
require 'tdiary/io/base'
require 'sequel'
require 'dalli'

module TDiary
  module CommentIO
    def restore_comment(diaries)
      Sequel.connect(@tdiary.conf.database_url || ENV['DATABASE_URL']) do |db|
        diaries.each do |date, diary_object|
          db[:comments].filter(diary_id: date).order_by(:no).select(:name, :mail, :last_modified, :visible, :comment).each do |row|
            comment = Comment.new(row[:name], row[:mail], row[:comment], Time.at(row[:last_modified].to_i))
            comment.show = row[:visible]
            diary_object.add_comment(comment)
          end
        end
      end
    end

    def store_comment(diaries)
      Sequel.connect(@tdiary.conf.database_url || ENV['DATABASE_URL']) do |db|
        diaries.each do |date, diary|
          no = 0
          diary.each_comment(diary.count_comments(true)) do |com|
            no += 1
            comment = db[:comments].filter(diary_id: date, no: no)
            if comment.count > 0
              comment.update(name: com.name, mail: com.mail, last_modified: com.date.to_i, visible: com.visible?, comment: com.body)
            else
              db[:comments].insert(name: com.name, mail: com.mail, last_modified: com.date.to_i, visible: com.visible?, comment: com.body, diary_id: date, no: no)
            end
          end
        end
      end
    end
  end

  module RefererIO
    def restore_referer(diaries)
      return
    end

    def store_referer(diaries)
      return
    end
  end


  class HerokuIO < BaseIO
    include CommentIO
    include RefererIO

    def initialize(tdiary)
      @tdiary = tdiary
      load_styles
    end

    class << self
      def load_cgi_conf(conf)
        Sequel.connect(conf.database_url || ENV['DATABASE_URL']) do |db|
          if cgi_conf = db[:conf].select(:body).first
            cgi_conf[:body]
          else
            ""
          end
        end
      end

      def save_cgi_conf(conf, result)
        Sequel.connect(conf.database_url || ENV['DATABASE_URL']) do |db|
          if db[:conf].count > 0
            db[:conf].update(:body => result)
          else
            db[:conf].insert(:body => result)
          end
        end
      end
    end

    #
    # block must be return boolean which dirty diaries.
    #
    def transaction(date)
      Sequel.connect(@tdiary.conf.database_url || ENV['DATABASE_URL']) do |db|
        db.transaction do
          diaries = {}

          if cache = restore_parser_cache(date)
            diaries.update(cache)
          else
            restore(date.strftime("%Y%m%d"), diaries)
            restore_comment(diaries)
            clear_cache
          end

          dirty = yield(diaries) if iterator?

          store(diaries) if dirty & TDiary::TDiaryBase::DIRTY_DIARY != 0
          store_comment(diaries) if dirty & TDiary::TDiaryBase::DIRTY_COMMENT != 0

          store_parser_cache(date, diaries) if dirty || !cache
        end
      end
    end

    def cache_path
      Dir.tmpdir
    end

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

    def clear_cache(*args)
      memcache.flush
    end

    def calendar
      calendar = Hash.new{|hash, key| hash[key] = []}
      Sequel.connect(@tdiary.conf.database_url || ENV['DATABASE_URL']) do |db|
        db[:diaries].select(:year, :month).group_by(:year, :month).order_by(:year, :month).each do |row|
          calendar[row[:year]] << row[:month]
        end
      end
      calendar
    end

    def diary_factory(date, title, body, style = 'tDiary')
      styled_diary_factory(date, title, body, style)
    end

  private

    def restore_parser_cache(date)
      memcache.get(date.strftime("%Y%m.parser"))
    end

    def store_parser_cache(date, obj)
      memcache.set(date.strftime("%Y%m.parser"), obj)
    end

    def restore(date, diaries, month = true)
      Sequel.connect(@tdiary.conf.database_url || ENV['DATABASE_URL']) do |db|
        query = db[:diaries].select(:diary_id, :title, :last_modified, :visible, :body, :style)
        query = if month && /(\d\d\d\d)(\d\d)(\d\d)/ =~ date
                  query.filter(year: $1, month: $2)
                else
                  query.filter(diary_id: date)
                end
        query.each do |row|
          style = if row[:style].nil? || row[:style].empty?
                    'wiki'
                  else
                    row[:style].downcase
                  end
          diary = eval("#{style(style)}::new(row[:diary_id], row[:title], row[:body], Time::at(row[:last_modified].to_i))")
          diary.show(row[:visible])
          diaries[row[:diary_id]] = diary
        end
      end
    end

    def store(diaries)
      Sequel.connect(@tdiary.conf.database_url || ENV['DATABASE_URL']) do |db|
        diaries.each do |date, diary|
          if /(\d\d\d\d)(\d\d)(\d\d)/ =~ date
            year  = $1
            month = $2
            day   = $3
          end
          entry = db[:diaries].filter(year: year, month: month, day: day, diary_id: date)
          if entry.count > 0
            entry.update(title: diary.title, last_modified: diary.last_modified.to_i, visible: diary.visible?, body: diary.to_src, style: diary.style)
          else
            db[:diaries].insert(year: year, month: month, day: day, title: diary.title, last_modified: diary.last_modified.to_i, visible: diary.visible?, body: diary.to_src, diary_id: date)
          end
        end
      end
    end

    def memcache
      @_client ||= Dalli::Client.new
    end
  end
end
