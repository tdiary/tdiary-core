require 'rack'
require 'stringio'

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
			if year && month && day
				request = build_request("#{year}#{month}#{day}")
				@controller = TDiaryDayWithoutFilter::new(request, '', conf)
			elsif year && month
				request = build_request("#{year}#{month}")
				@controller = TDiaryMonthWithoutFilter::new(request, '', conf)
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

	private

		# there is no real HTTP request behind a container lookup; fake one
		# with a minimal Rack env carrying the date parameter
		def build_request(date)
			TDiary::Request.new(
				'REQUEST_METHOD'  => 'GET',
				'SCRIPT_NAME'     => '',
				'PATH_INFO'       => '/',
				'QUERY_STRING'    => "date=#{date}",
				'SERVER_NAME'     => 'localhost',
				'SERVER_PORT'     => '80',
				'rack.url_scheme' => 'http',
				'rack.input'      => StringIO.new('')
			)
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
