if ENV['DATABASE_URL']
	desc "create database"
	namespace :db do
		task :create do
			Sequel.connect(ENV['DATABASE_URL']) do |db|
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
				end

				db.create_table :comments do
					String :diary_id, :size => 8
					Fixnum :no
					String :name, :text => true
					String :mail, :text => true
					String :comment, :text => true
					Fixnum :last_modified
					TrueClass :visible
					primary_key [:diary_id, :no]
				end

				db.create_table :conf do
					String :body, :text => true
				end
			end
		end

		task :drop do
			Sequel.connect(ENV['DATABASE_URL']) do |db|
				db.drop_table :diaries, :comments, :conf
			end
		end
	end
end
