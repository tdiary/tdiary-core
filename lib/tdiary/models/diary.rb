module TDiary
	module Models
		class Diary
			# YYYYMMDD
			def self.find_by_day(conf, year, month, day)
				new(conf, year, month, day)
			end

			# YYYYMM
			def self.find_by_month(conf, year, month)
				new(conf, year, month)
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