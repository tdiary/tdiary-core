# -*- coding: utf-8 -*-
# = for Ruby1.9.1 compatible =
#

# --------------------------------------------------------
# 汎用的な設定
# --------------------------------------------------------

# for Ruby1.9.1

# temporally path for BUG of $SAFE == 1 on ruby 1.9.1p0
# This problem was fixed on ruby 1.9.1p129.
Thread.start {
	begin
		$SAFE = 1
		require 'stringio'
		TDIARY_SAFE_NORMAL = 1
	rescue SecurityError
		TDIARY_SAFE_NORMAL = 0
	end
}.join

unless "".respond_to?('to_a')
	class String
		def to_a
			[ self ]
		end
	end
end

unless "".respond_to?('each')
	class String
		alias each each_line
	end
end

# Auto convert ASCII_8BIT pstore data (created by Ruby-1.8) to UTF-8.
#if "".respond_to?('force_encoding')
#	require 'pstore'
#	class PStore
#		private
#		def load(content)
#			load_proc = proc {|obj|
#				if obj.respond_to?('force_encoding') && obj.encoding == Encoding::ASCII_8BIT
#					obj.force_encoding('UTF-8')
#				end
#				obj
#			}
#			Marshal::load(content, load_proc)
#		end
#	end
#end

# Ruby1.9では String が Enumerable ではなくなった
class String
	def method_missing(name, *args, &block)
		each_line.__send__(name, *args, &block)
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
