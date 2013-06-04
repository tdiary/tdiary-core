# -*- coding: utf-8 -*-

module TDiary
	module Rack
		autoload :HtmlAnchor,       'tdiary/rack/html_anchor'
		autoload :ValidRequestPath, 'tdiary/rack/valid_request_path'
		autoload :Static,           'tdiary/rack/static'

		module Assets
			autoload :Precompile,    'tdiary/rack/assets/precompile'
		end

		module Auth
			autoload :Basic,         'tdiary/rack/auth/basic'
			autoload :OmniAuth,      'tdiary/rack/auth/omniauth'
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
