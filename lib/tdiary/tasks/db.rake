namespace :db do
	desc "import database from file system"
	task :import do
		$:.unshift '.'
		require 'tdiary'

		cgi = CGI.new
		conf = TDiary::Config.new(cgi)
		base = TDiary::TDiaryBase.new(cgi, 'day.rhtml', conf)
		io = conf.io_class.new(base)
		io.load_styles

		Sequel.connect(conf.database_url) do |db|
			db.create_table :conf do
				String :body, :text => true
			end unless db.table_exists?(:conf)
			db[:conf].insert(:body => File.read(conf.data_path + 'tdiary.conf'))
		end

		yms = base.calendar
		yms.keys.sort.reverse_each do |year|
			yms[year.to_s].sort.reverse_each do |month|
				date = Time.local(year, month)
				io.transaction(date) do |diaries|
					Sequel.connect(conf.database_url) do |db|
						db.create_table :diaries do
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
						end unless db.table_exists?(:diaries)

						db.create_table :comments do
							String :diary_id, :size => 8
							Fixnum :no
							String :name, :text => true
							String :mail, :text => true
							String :comment, :text => true
							Fixnum :last_modified
							TrueClass :visible
							primary_key [:diary_id, :no]
						end unless db.table_exists?(:comments)

						diaries.each do |d, diary|
							no = 0
							if /(\d\d\d\d)(\d\d)(\d\d)/ =~ d
								year  = $1
								month = $2
								day   = $3
							end
							entry = db[:diaries].filter(:year => year,
								:month => month,
								:day => day,
								:diary_id => d)
							if entry.count > 0
								entry.update(:title => diary.title,
									:last_modified => diary.last_modified.to_i,
									:style => diary.style,
									:visible => diary.visible?,
									:body => diary.to_src)
							else
								db[:diaries].insert(:year => year,
									:month => month,
									:day => day,
									:diary_id => d,
									:title => diary.title,
									:last_modified => diary.last_modified.to_i,
									:style => diary.style,
									:visible => diary.visible?,
									:body => diary.to_src)
							end

							diary.each_comment(diary.count_comments(true)) do |com|
								no += 1
								comment = db[:comments].filter(:diary_id => d, :no => no)
								if comment.count > 0
									comment.update(:name => com.name, :mail => com.mail, :last_modified => com.date.to_i, :visible => com.visible?, :comment => com.body)
								else
									db[:comments].insert(:name => com.name, :mail => com.mail, :last_modified => com.date.to_i, :visible => com.visible?, :comment => com.body, :diary_id => date, :no => no)
								end
							end
						end
					end
				end
			end
		end
	end

	desc "drop database"
	task :drop do
		conf = TDiary::Config.new(CGI.new)
		Sequel.connect(conf.database_url || ENV['DATABASE_URL']) do |db|
			db.drop_table :diaries, :comments, :conf
		end
	end
end if defined?(Sequel)

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
