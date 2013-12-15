# -*- coding: utf-8 -*-

module TDiary
	module Extensions
		class Core
			def self.sp_path
			end

			def self.assets_path
				%w(js theme).map {|path|
					[TDiary.root, TDiary.server_root].map {|base_dir|
						File.join(base_dir, path)
					}
				}
			end
		end
	end
end
