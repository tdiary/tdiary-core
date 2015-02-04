namespace :mongodb do
	desc "make index into mongoDB"
	task :index do
		require 'erb'
		require 'tdiary'
		conf = TDiary::Config.new
		TDiary::DiaryContainer.new(conf, '2015', '01')
		TDiary::IO::MongoDB::Diary.create_indexes
		TDiary::IO::MongoDB::Comment.create_indexes
		TDiary::IO::MongoDB::Plugin.create_indexes
	end
end
