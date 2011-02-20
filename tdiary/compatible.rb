# -*- coding: utf-8 -*-
# = for Ruby1.9.1 compatible =
#

# --------------------------------------------------------
# 汎用的な設定
# --------------------------------------------------------

# for Ruby1.9.1

# Auto convert ASCII_8BIT pstore data (created by Ruby-1.8) to UTF-8.
if "".respond_to?('force_encoding')
	require 'pstore'
	class PStoreRuby18Exception < Exception; end

	class PStore
		alias compatible_transaction_original transaction unless defined?(compatible_transaction_original)
		def transaction(*args, &block)
			begin
				compatible_transaction_original(*args, &block)
			rescue PStoreRuby18Exception => e
				# first loaded the pstore file (it's created by Ruby-1.8)
				# force convert ASCII_8BIT pstore data to UTF_8
				file = open_and_lock_file(@filename, false)
				table = Marshal::load(file, proc {|obj|
					if obj.respond_to?('force_encoding') && obj.encoding == Encoding::ASCII_8BIT
						obj.force_encoding('UTF-8')
					end
					obj
				})
				table[:__ruby_version] = RUBY_VERSION
				if on_windows?
					save_data_with_fast_strategy(Marshal::dump(table), file)
				else
					save_data_with_atomic_file_rename_strategy(Marshal::dump(table), file)
				end
				retry
			end
		end

		private
		def load(content)
			table = Marshal::load(content)
			raise PStoreRuby18Exception.new if !table[:__ruby_version] || table[:__ruby_version] < '1.9'
			# hide __ruby_version to caller
			table.delete(:__ruby_version)
			table
		end

		def dump(table)
			table[:__ruby_version] = RUBY_VERSION
			Marshal::dump(table)
		end
	end
end

# ENV#[] raises an exception on secure mode
class CGI
	ENV = ::ENV.to_hash
end

# for Ruby1.8.X

unless "".respond_to?('force_encoding')
	class Encoding
		class CompatibilityError < Exception; end

		def Encoding.const_missing(id)
			self
		end
	end

	class String
		def force_encoding(encoding)
			self
		end

		def encode(encoding)
			self
		end
	end
end

unless "".respond_to?('lines')
	class String
		alias_method :lines, :to_a
	end
end

unless "".respond_to?('bytesize')
	class String
		alias bytesize size
	end
end

unless "".respond_to?('ord')
	class String
		def ord
			self[0]
		end
	end
	
	class Integer
		def ord
			self
		end
	end
end

# --------------------------------------------------------
# tDiary 用の設定
# --------------------------------------------------------

# 日本語を含むツッコミを入れると diary.last_modified が String になる (原因不明)
# (PStore 保存前は Time だが, 保存後に String となる)
# 暫定的に String だったら Time へ変換する
module TDiary
	class WikiDiary
		def last_modified
			if @last_modified.instance_of? String
				@last_modified = Time.at(0)
			end
			@last_modified
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
