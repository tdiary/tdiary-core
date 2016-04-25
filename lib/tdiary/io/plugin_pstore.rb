#
# module io/plugin_pstore
# 	default plugin storage implemented by PStore
#
require 'pstore'

module TDiary
	module IO
		module PluginPStore
			# returning storage object
			def plugin_open(conf)
				storage = Pathname(conf.data_path) + 'plugin'
				storage.mkpath
				return storage
			end

			def plugin_close(storage_object)
			end

			def plugin_transaction(storage_object, plugin_name)
				PStore.new(storage_object + "#{plugin_name}.db").transaction do |db|
					# define methods of plugin storage interface
					# PStore has 'delete' method as same function
					def db.get(key)
						self[key]
					end
					def db.set(key, value)
						self[key] = value
					end
					# def db.delete( key )
					#
					# end
					def db.keys
						self.roots
					end

					yield db
				end
			end
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
