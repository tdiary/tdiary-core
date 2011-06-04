# -*- coding: utf-8 -*-
require 'spec_helper'

if RUBY_VERSION > '1.9'
	require 'tdiary/compatible'
	require 'fileutils'

	describe PStore, "auto convert library" do
		before(:all) do
			# rake specで動かすと、comppatible.rb が既に読み込まれてしまっているため、
			# このPStoreがASCII-8BITではなくUTF-8になってしまう。
			# そのため、下記と同様の ascii8bit-pstore.db をテストフィクスチャとしている。
			# PStore.new(@dbfile).transaction do |db|
			# 	db["key1".to_8bit] = "val1".to_8bit
			# 	db["key2".to_8bit] = 2
			# 	db["key3".to_8bit] = [1, :sym, "string".to_8bit]
			# end
			dbfilename = '../fixtures/ascii8bit-pstore.db'
			dbfile_orig = File.join(File.dirname(__FILE__), dbfilename)
			@dbfile = File.join(File.dirname(__FILE__), "#{dbfilename}.work")
			FileUtils.cp dbfile_orig, @dbfile
		end

		after(:all) do
			FileUtils.rm @dbfile
		end

		it "should convert an encoding to UTF-8 automatically" do
			PStore.new(@dbfile).transaction do |db|
				db["key1"].encoding.should == Encoding::UTF_8
				db["key2"].should  == 2
				db["key3"][2].encoding.should  == Encoding::UTF_8
			end
		end

		it "1回目のtransactionではMashal.loadが3回呼ばれる" do
			Marshal.should_receive(:load).exactly(3).and_return({})
			PStore.new(@dbfile).transaction {}
		end

		it "2回目のtransactionではMashal.loadが1回だけ呼ばれる" do
			Marshal.should_receive(:load).exactly(4).and_return({})
			PStore.new(@dbfile).transaction {}
			PStore.new(@dbfile).transaction {}
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
