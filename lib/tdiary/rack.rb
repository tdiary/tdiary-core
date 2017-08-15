module TDiary
	module Rack
		autoload :HtmlAnchor,       'tdiary/rack/html_anchor'
		autoload :ValidRequestPath, 'tdiary/rack/valid_request_path'
		autoload :Session,          'tdiary/rack/session'
		autoload :Static,           'tdiary/rack/static'
		autoload :Auth,             'tdiary/rack/auth'
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
