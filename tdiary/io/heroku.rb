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
require 'tempfile'
require 'sequel'

module TDiary
  module CommentIO
    def restore_comment(diaries)
      diaries.each do |date, diary_object|
        @db[:commentdata].filter(author: @author, diary_id: date).order_by(:no).select(:name, :mail, :last_modified, :visible, :comment).each do |row|
          comment = Comment.new(row[:name], row[:mail], row[:comment], Time.at(row[:last_modified].to_i))
          comment.show = row[:visible]
          diary_object.add_comment(comment)
        end
      end
    end

    def store_comment(diaries)
      diaries.each do |date, diary|
        no = 0
        diary.each_comment(diary.count_comments(true)) do |com|
          no += 1
          if comment = @db[:commentdata].filter(author: @author, diary_id: date, no: no).first
            comment.update(name: com.name, mail: com.mail, last_modified: com.date.to_i, visible: com.visible?, comment: com.body)
          else
            @db[:commentdata].insert(name: com.name, mail: com.mail, last_modified: com.date.to_i, visible: com.visible?, comment: com.body, author: @author, diary_id: date, no: no)
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
      @db     = Sequel.connect(tdiary.conf.database_url || ENV['DATABASE_URL'])
      @author = tdiary.conf.author || 'default'
      load_styles
    end

    class << self
      def load_cgi_conf(conf)
        db = Sequel.connect(conf.database_url || ENV['DATABASE_URL'])
        if cgi_conf = db[:confdata].filter(:author => @author).select(:body).first
          cgi_conf[:body]
        else
          ""
        end
      end

      def save_cgi_conf(conf, result)
        db = Sequel.connect(conf.database_url || ENV['DATABASE_URL'])
        if db[:confdata].count > 0
          db[:confdata].filter(:author => @author).update(:body => result)
        else
          db[:confdata].insert(:body => result, :author => @author)
        end
      end
    end

    #
    # block must be return boolean which dirty diaries.
    #
    def transaction(date)
      File.open("#{Dir.tmpdir}/dbi_io.lock", 'w') do |file|
        file.flock(File::LOCK_EX)
        @db.transaction do
          diaries = {}

          restore(date.strftime("%Y%m%d"), diaries)
          restore_comment(diaries)

          dirty = yield(diaries) if iterator?

          store(diaries)  if dirty & TDiary::TDiaryBase::DIRTY_DIARY != 0
          store_comment(diaries)  if dirty & TDiary::TDiaryBase::DIRTY_COMMENT != 0
        end
      end
    end

    def calendar
      calendar = Hash.new{|hash, key| hash[key] = []}
      @db[:diarydata].select(:year, :month).group_by(:year, :month).order_by(:year, :month).each do |row|
        calendar[row[:year]] << row[:month]
      end
      calendar
    end

    def diary_factory(date, title, body, style = 'tDiary')
      styled_diary_factory(date, title, body, style)
    end

  private

    def restore(date, diaries, month = true)
      query = @db[:diarydata].select(:diary_id, :title, :last_modified, :visible, :body, :style)
      query = if month && /(\d\d\d\d)(\d\d)(\d\d)/ =~ date
        query.filter(author: @author, year: $1, month: $2)
      else
        query.filter(author: @author, diary_id: date)
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
      diaries.each do |date, diary|
        # save diaries
        if /(\d\d\d\d)(\d\d)(\d\d)/ =~ date
          year  = $1
          month = $2
          day   = $3
        end
        if entry = @db[:diarydata].filter(year: year, month: month, day: day, author: @author, diary_id: date).first
          entry.update(title: diary.title, last_modified: diary.last_modified.to_i, visible: diary.visible?, body: diary.to_src, style: diary.style)
        else
          @db[:diarydata].insert(year: year, month: month, day: day, title: diary.title, last_modified: diary.last_modified.to_i, visible: diary.visible?, body: diary.to_src, author: @author, diary_id: date)
        end
      end
    end
  end
end
