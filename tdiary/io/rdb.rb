# -*- coding: utf-8 -*-
#
# rdb.rb: RDB IO for tDiary 3.x
#
# NAME             rdb
#
# DESCRIPTION      RDB 向け tDiary IO クラス
#                  日記データは RDB に保存、リンク元の記録には未対応
#
# Copyright        (C) 2003 ma2tak <ma2tak@ma2tak.dyndns.org>
#                  (C) 2004 moonwolf <moonwolf@mooonwolf.com>
#                  (C) 2005 Kazuhiko <kazuhiko@fdiary.net>
#                  (C) 2012 hsbt <shibata.hiroshi@gmail.com>
#
# You can distribute this under GPL.
require 'tdiary/io/base'
require 'tempfile'
require 'sequel'

module TDiary
  module CommentIO
    def restore_comment(diaries)
      diaries.each do |date, diary_object|
        db[:comments].filter(:diary_id => date).order_by(:no).select(:name, :mail, :last_modified, :visible, :comment).each do |row|
          comment = Comment.new(row[:name], row[:mail], row[:comment], Time.at(row[:last_modified].to_i))
          comment.show = row[:visible]
          diary_object.add_comment(comment)
        end
      end
    end

    def store_comment(diaries)
      diaries.each do |diary_id, diary|
        no = 0
        diary.each_comment(diary.count_comments(true)) do |com|
          no += 1
          date = {
            :diary_id => diary_id,
            :no => no
          }
          body = {
            :name => com.name,
            :mail => com.mail,
            :last_modified => com.date.to_i,
            :visible => com.visible?,
            :comment => com.body
          }
          comment = db[:comments].filter(date)
          if comment.count > 0
            comment.update(body)
          else
            db[:comments].insert(date.merge(body))
          end
        end
      end
    end
  end

  module RefererIO
    def restore_referer(diaries)
      # not implemented yet
      return
    end

    def store_referer(diaries)
      # not implemented yet
      return
    end
  end

  class RdbIO < BaseIO
    include CommentIO
    include RefererIO
    include CacheIO

    class << self
      def load_cgi_conf(conf)
        if cgi_conf = db(conf)[:conf].select(:body).first
          cgi_conf[:body]
        else
          ""
        end
      end

      def save_cgi_conf(conf, result)
        if db(conf)[:conf].count > 0
          db(conf)[:conf].update(:body => result)
        else
          db(conf)[:conf].insert(:body => result)
        end
      end

      def db(conf)
        @@_db ||= Sequel.connect(conf.database_url || ENV['DATABASE_URL'])

        @@_db.create_table :conf do
          String :body, :text => true
        end unless @@_db.table_exists?(:conf)

        @@_db.create_table :diaries do
          String :diary_id, :size => 8
          String :year, :size => 4
          String :month, :size => 2
          String :day, :size => 2
          String :title, :text => true
          String :body, :text => true
          String :style, :text => true
          Fixnum :last_modified
          TrueClass :visible
          primary_key :diary_id
        end unless @@_db.table_exists?(:diaries)

        @@_db.create_table :comments do
          String :diary_id, :size => 8
          Fixnum :no
          String :name, :text => true
          String :mail, :text => true
          String :comment, :text => true
          Fixnum :last_modified
          TrueClass :visible
          primary_key [:diary_id, :no]
        end unless @@_db.table_exists?(:comments)

        @@_db
      end
    end

    #
    # block must be return boolean which dirty diaries.
    #
    def transaction(date)
      diaries = {}

      if cache = restore_parser_cache(date)
        diaries.update(cache)
      else
        restore(date.strftime("%Y%m%d"), diaries)
        restore_comment(diaries)
      end

      dirty = yield(diaries) if iterator?

      store(diaries) if (dirty & TDiary::TDiaryBase::DIRTY_DIARY) != 0
      store_comment(diaries) if (dirty & TDiary::TDiaryBase::DIRTY_COMMENT) != 0

      store_parser_cache(date, diaries) if dirty || !cache
    end

    def calendar
      calendar = Hash.new{|hash, key| hash[key] = []}
      db[:diaries].select(:year, :month).group_by(:year, :month).order_by(:year, :month).each do |row|
        calendar[row[:year]] << row[:month]
      end
      calendar
    end

    def cache_dir
      @tdiary.conf.cache_path || "#{Dir.tmpdir}/cache"
    end

    private

    def restore(date, diaries, month = true)
      query = db[:diaries].select(:diary_id, :title, :last_modified, :visible, :body, :style)
      query = if month && /(\d\d\d\d)(\d\d)(\d\d)/ =~ date
                query.filter(:year => $1, :month => $2)
              else
                query.filter(:diary_id => date)
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

    def store(diaries)
      diaries.each do |diary_id, diary|
        date = if /(\d\d\d\d)(\d\d)(\d\d)/ =~ diary_id
                 {
                   :year => $1,
                   :month => $2,
                   :day => $3,
                   :diary_id => diary_id
                 }
               end
        body = {
          :title => diary.title,
          :last_modified => diary.last_modified.to_i,
          :style => diary.style,
          :visible => diary.visible?,
          :body => diary.to_src
        }

        entry = db[:diaries].filter(date)
        if entry.count > 0
          entry.update(body)
        else
          db[:diaries].insert(date.merge(body))
        end
      end
    end

    def db
      self.class.db(@tdiary.conf)
    end
  end
end
