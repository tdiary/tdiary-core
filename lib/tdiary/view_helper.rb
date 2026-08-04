module TDiary
  module ViewHelper
		def bot?
			@conf.bot =~ view_helper_request.user_agent
		end

    def base_url
      if @conf.options['base_url'] && @conf.options['base_url'].length > 0
        @conf.options['base_url']
      else
        view_helper_request.tdiary_base_url
      end
    end

  private

    # plugins include this helper into objects that hold only the @cgi
    # facade (misc/plugin/makerss.rb); fall back to its wrapped request
    def view_helper_request
      @request || @cgi.request
    end
  end
end
