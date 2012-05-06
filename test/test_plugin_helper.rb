module TDiary
	module PluginTestStub
		def add_header_proc(*args); end
		def add_body_enter_proc(*args); end
		def add_update_proc(*args); end
		def add_conf_proc(*args); end
		def feed?; false; end
		def to_native( str, charset = nil )
			from = case charset
				when /^utf-8$/i
					'W'
				when /^shift_jis/i
					'S'
				when /^EUC-JP/i
					'E'
				else
					''
			end
			NKF::nkf( "-m0 -#{from}e", str )
		end
	end
end

include TDiary::PluginTestStub
@options = {}
