namespace :db do
  desc "drop database"
	task :drop do
		Sequel.connect(ENV['DATABASE_URL']) do |db|
			db.drop_table :diaries, :comments, :conf
		end
	end
end if defined?(Sequel)
