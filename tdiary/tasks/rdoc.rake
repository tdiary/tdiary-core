desc "generate rdoc files"
task :rdoc do
	root_dir = File.dirname(__FILE__)

	dirlist = Dir.glob(root_dir + "/rdoc/**/").sort {
		|a,b| b.split('/').size <=> a.split('/').size
	}
	dirlist.each {|d|
		Dir.foreach(d) {|f|
			File::delete(d + f) if !(/\.+$/ =~ f)
		}
		Dir.rmdir(d)
	}

	`cd #{root_dir} && rdoc --all --charset=UTF8 --op=rdoc --inline-source README ChangeLog index.rb update.rb tdiary.rb tdiary/* misc/* plugin/*`
end
