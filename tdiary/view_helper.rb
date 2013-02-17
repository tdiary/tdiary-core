module TDiary
  module ViewHelper
		def bot?
			@conf.bot =~ @cgi.user_agent
		end

    def base_url
      if @conf.options['base_url'] && @conf.options['base_url'].length > 0
        @conf.options['base_url']
      else
        @cgi.base_url
      end
    end
  end
end
