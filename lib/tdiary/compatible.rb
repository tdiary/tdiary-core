# ENV#[] raises an exception on secure mode
class CGI
	ENV = ::ENV.to_hash
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
