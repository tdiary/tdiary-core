=begin

Patched version of FCGI::each_cgi from fcgi-0.8.8.
* if encoding error happens with UTF-8, try Shift_JIS.

Original copyright notices:
  fastcgi.rb Copyright (C) 2001 Eli Green
  fcgi.rb    Copyright (C) 2002-2003 MoonWolf <moonwolf@moonwolf.com>
  fcgi.rb    Copyright (C) 2004 Minero Aoki

Patch written by:
  Copyright (C) 2011 Kazuhiko <kazuhiko@fdiary.net>

=end

class FCGI
  def self::each_cgi(*args)
    require 'cgi'

    eval(<<-EOS,TOPLEVEL_BINDING)
    class CGI
      public :env_table
      def self::remove_params
        if (const_defined?(:CGI_PARAMS))
          remove_const(:CGI_PARAMS)
          remove_const(:CGI_COOKIES)
        end
      end
    end # ::CGI class

    class FCGI
      class CGI < ::CGI
        def initialize(request, *args)
          ::CGI.remove_params
          @request = request
          # PATCH BEGIN : if encoding error happens with UTF-8, try
          #               Shift_JIS.
          encoding_error = {}
          super(*(args+[:accept_charset => "UTF-8"]))  do |name, value|
            encoding_error[name] = value
          end
          params = @params
          unless encoding_error.empty?
            super(*(args+[:accept_charset => "Shift_JIS"]))
            @params = params
          end
          # PATCH END : if encoding error happens with UTF-8, try
          #             Shift_JIS.
          @args = *args
        end
        def args
          @args
        end
        def env_table
          @request.env
        end
        def stdinput
          @request.in
        end
        def stdoutput
          @request.out
        end
      end # FCGI::CGI class
    end # FCGI class
    EOS

    if FCGI::is_cgi?
      yield ::CGI.new(*args)
    else
      FCGI::each {|request|
        $stdout, $stderr = request.out, request.err

        yield CGI.new(request, *args)

        request.finish
      }
    end
  end
end

# The following indentation rule is not same as tDiary's by intention.
# It is same as the original (fcgi-0.8.8/lib/fcgi.rb) so that we can
# easily see the difference by diff command.

# Local Variables:
# mode: ruby
# indent-tabs-mode: nil
# ruby-indent-level: 2
# End:
