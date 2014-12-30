module TDiary
	module Models
		class Diary
			def initialize(conf)
				@conf = conf
			end

			# YYYYMM
			def month(year, month)
				cgi = FakeCGI.new
				cgi.params['date'] = ["#{year}#{month}"]
				TDiaryMonthWithoutFilter::new(cgi, '', @conf)
			end

			# YYYYMMDD
			def day(year, month, day)
				cgi = FakeCGI.new
				cgi.params['date'] = ["#{year}#{month}#{day}"]
				TDiaryDayWithoutFilter::new(cgi, '', @conf)
			end

			class FakeCGI < CGI
				def refeter; nil end
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