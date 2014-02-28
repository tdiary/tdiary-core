require File.expand_path('../test_helper', __FILE__)
require 'my-sequel'
require 'fileutils'
require 'tmpdir'

# test cases for updates of links: run this file as a Ruby script
class TestMySequel < Test::Unit::TestCase
	OrigLinks = {
		'20061231#p01' => '20061101#p01',
		'20061231#p02' => '20061001#p01',
		'20061130#p01' => '20061001#p01',
	}

	def setup
		@cache_path = File.join(Dir.tmpdir, "#{__FILE__}-#{$$}")
		FileUtils.mkdir_p(@cache_path)

		@orig_src_dates = OrigLinks.keys.map{|a| MySequel.date(a)}
		@orig_dst_dates = OrigLinks.values.map{|a| MySequel.date(a)}
		orig = MySequel.new(@cache_path)
		orig.restore(@orig_src_dates)
		@orig_src_dates.each do |date|
			orig.clean_dsts(Time.local(*(date.scan(/(\d{4,4})(\d\d)(\d\d)/)[0])))
		end
		OrigLinks.each_pair do |src, dst|
			orig.add(src, dst)
		end
		orig.clean_srcs
		orig.commit
	end

	def testsrcs	# confirms setup really cached the OrigLinks
		cached = MySequel.new(@cache_path)
		cached.restore(@orig_dst_dates)
		OrigLinks.values.uniq.each do |dst|
			srcs = OrigLinks.find_all{|e| dst == e[1]}.map{|e| e[0]}
			assert_equal(srcs.sort, cached.srcs(dst).sort)
		end
	end

	def testadd	# confirms addition of a day
		# write the diary for 2007-01-01
		cached = MySequel.new(@cache_path)
		cached.restore(@orig_dst_dates)
		cached.clean_dsts(Time.local(2007,1,1))
		cached.add('20070101#p01', '20060101#p01')
		assert_equal(['20070101#p01'], cached.srcs('20060101#p01'))
		cached.clean_srcs
		cached.commit
		# display the diary for 2006-01-01
		cached = MySequel.new(@cache_path)
		cached.restore(['20060101'])
		assert_equal(['20070101#p01'], cached.srcs('20060101#p01'))
		# confirmation of other links
		testsrcs
	end

	def testadd_two_months	# http://zunda.freeshell.org/d/20070122.html#c01
		# write the diary for 2007-02-15
		cached = MySequel.new(@cache_path)
		cached.restore('20070215')
		cached.clean_dsts(Time.local(2007,2,15))
		cached.add('20070215#p01', '20070115#p01')
		cached.clean_srcs
		cached.commit
		# write the diary for 2007-03-10
		cached = MySequel.new(@cache_path)
		cached.restore('20070310')
		cached.clean_dsts(Time.local(2007,3,10))
		cached.add('20070310#p01', '20070115#p01')
		cached.clean_srcs
		cached.commit
		# display the diary on 2007-01-15
		cached = MySequel.new(@cache_path)
		cached.restore('20070115')
		assert_equal(['20070215#p01', '20070310#p01'], cached.srcs('20070115#p01'))

	end

	def testedit	# confirms edition of a link
		# edit the diary for 2006-11-31
		cached = MySequel.new(@cache_path)
		cached.restore(@orig_dst_dates)
		cached.clean_dsts(Time.local(2006,11,30))
		cached.add('20061130#p01', '20060901#p01')
		cached.clean_srcs
		cached.commit
		# display the diary on 2006-09-01
		cached = MySequel.new(@cache_path)
		cached.restore(['20060901'])
		assert_equal(['20061130#p01'], cached.srcs('20060901#p01'))
		# display the diary on 2006-10-01
		cached.restore(['20061001'])
		assert_equal(['20061231#p02'], cached.srcs('20061001#p01'))
	end

	def testdelete	# confirms deletion of a link
		# edit the diary for 2006-11-31
		cached = MySequel.new(@cache_path)
		cached.restore(@orig_dst_dates)
		cached.clean_dsts(Time.local(2006,11,30))
		cached.clean_srcs
		cached.commit
		# display the diary on 2006-10-01
		cached.restore(['20061001'])
		assert_equal(['20061231#p02'], cached.srcs('20061001#p01'))
	end

	def teardown
		FileUtils.rmtree(@cache_path)
	end
end

class TestMySequelCss < Test::Unit::TestCase
	def test_usual
		assert_equal(<<"_TARGET", MySequel::css(<<'_INNER'))
\t<style type="text/css" media="all"><!--
\tdiv.sequel {
\t\thogehoge: &lt;mogemoge&gt;
\t}
\t--></style>
_TARGET
hogehoge: <mogemoge>
_INNER
	end

	def test_empty
		assert_equal('', MySequel::css(''))
	end

	def test_space
		assert_equal('', MySequel::css(' '))
	end

	def test_crlf
		assert_equal('', MySequel::css("\r\n"))
	end

end

class TestMySequelConf < Test::Unit::TestCase
	include ERB::Util

	def setup
		@defaults = {
			:label => {
				:title => 'Link label',
				:default => 'default label',
				:index => 1,
			},
			:format => {
				:title => 'Date format<sup>*</sup>',
				:description => 'Format of the dates of the link',
				:default => '<date>',
				:index => 2,
			},
			:textarea => {
				:title => 'Test to show text area',
				:default => "a\nb\ncc",
				:index => 3,
				:textarea => true,
			},
			:textarea_with_size => {
				:title => 'Test to show text area',
				:default => "a\nb\ncc",
				:index => 4,
				:textarea => {rows: 2},
			}
		}
		@my_sequel_conf = MySequel::Conf.new(@defaults)
	end

	def testdefaults	# retrieve default configuration
		assert_equal('default label', @my_sequel_conf[:label])
	end

	def testmerge
		options = {'my_sequel.label' => 'configured label'}
		@my_sequel_conf.merge_hash(options)
		assert_equal('configured label', @my_sequel_conf[:label])
	end

	def testparams
		options = {'label' => ['configured label']}
		@my_sequel_conf.merge_params(options)
		assert_equal('configured label', @my_sequel_conf[:label])
	end

	def testparams_with_empty_array
		options = {'label' => ['configured label'], 'label.reset' => []}
		@my_sequel_conf.merge_params(options)
		assert_equal('configured label', @my_sequel_conf[:label])
	end

	def testtohash
		testmerge
		conf_hash = {'dummy' => 'dummy'}
		@my_sequel_conf.to_conf_hash(conf_hash)
		assert_equal({'my_sequel.label' => 'configured label', 'dummy' => 'dummy'}, conf_hash)
	end

	def testparams_with_empty
		testmerge
		options = {'label' => ['']}
		@my_sequel_conf.merge_params(options)
		assert_equal('', @my_sequel_conf[:label])
	end

	def testparams_with_reset
		testmerge
		options = {'label' => ['any value'], 'label.reset' => 't'}
		@my_sequel_conf.merge_params(options)
		assert_equal('default label', @my_sequel_conf[:label])
	end

	def test_delete_confhash
		options = {'my_sequel.label' => 'configured label'}
		@my_sequel_conf.merge_hash(options)
		params = {'label' => ['any value'],'label.reset' => 't'}
		@my_sequel_conf.merge_params(params)
		@my_sequel_conf.to_conf_hash(options)
		assert(!options.has_key?('my_sequel.label'))
	end

	def testparams_with_nil
		testmerge
		options = {'label' => nil}
		@my_sequel_conf.merge_params(options)
		assert_equal('configured label', @my_sequel_conf[:label])
	end

	def testparams_with_nokey
		testmerge
		options = {}
		@my_sequel_conf.merge_params(options)
		assert_equal('configured label', @my_sequel_conf[:label])
	end
end
