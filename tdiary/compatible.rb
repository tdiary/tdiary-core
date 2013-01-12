# -*- coding: utf-8 -*-

# ENV#[] raises an exception on secure mode
class CGI
	ENV = ::ENV.to_hash
end

# for Ruby 1.9.3
if ::Object.method_defined?(:untrust)
	class Object
		def taint
			super
			untrust
		end
	end
end

# for Ruby 1.9.X

# Auto convert ASCII_8BIT pstore data (created by Ruby-1.8) to UTF-8.
if ::String.method_defined?(:force_encoding)
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

# for Ruby 1.8.X
unless ::String.method_defined?(:force_encoding)
	class String
		def force_encoding(encoding)
			self
		end
	end
end

# for Ruby 1.8.6
unless ::String.method_defined?(:lines)
	class String
		alias_method :lines, :to_a
	end
end

unless ::String.method_defined?(:bytesize)
	class String
		alias bytesize size
	end
end

unless ::String.method_defined?(:ord)
	class String
		def ord
			self[0]
		end
	end
end

unless ::Integer.method_defined?(:ord)
	class Integer
		def ord
			self
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
