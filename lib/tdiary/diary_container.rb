module TDiary
	class DiaryContainer
		# YYYYMMDD
		def self.find_by_day(conf, date)
			# date: YYYYMMDD
			m = date.match(/^(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})$/)
			raise ArgumentError.new("date must be YYYYMMDD format") unless m
			new(conf, m[:year], m[:month], m[:day])
		end

		def self.find_by_month(conf, date)
			# date: YYYYMM
			m = date.match(/^(?<year>\d{4})(?<month>\d{2})$/)
			raise ArgumentError.new("date must be YYYYMM format") unless m
			new(conf, m[:year], m[:month])
		end

		def initialize(conf, year, month, day = nil)
			cgi = FakeCGI.new
			if year && month && day
				cgi.params['date'] = ["#{year}#{month}#{day}"]
				@controller = TDiaryDayWithoutFilter::new(cgi, '', conf)
			elsif year && month
				cgi.params['date'] = ["#{year}#{month}"]
				@controller = TDiaryMonthWithoutFilter::new(cgi, '', conf)
			else
				raise StandardError.new
			end
		end

		def conf
			@controller.conf
		end

		def diaries
			# Hash of 'YYYYMMDD' => TDiary::Style::WikiDiary
			@controller.diaries
		end

		class FakeCGI < CGI
			def refeter; nil end
			def user_agent; nil; end
			def mobile_agent?; nil; end
			def request_method; 'GET'; end
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