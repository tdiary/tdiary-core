# -*- coding: utf-8 -*-
require 'spec_helper'

require 'tdiary/compatible'
require 'fileutils'

describe PStore, "auto convert library" do
	before do
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

	after do
		FileUtils.rm @dbfile
	end

	it "should convert an encoding to UTF-8 automatically" do
		PStore.new(@dbfile).transaction do |db|
			expect(db["key1"].encoding).to eq(Encoding::UTF_8)
			expect(db["key2"]).to  eq(2)
			expect(db["key3"][2].encoding).to  eq(Encoding::UTF_8)
		end
	end

	it "1回目のtransactionではMashal.loadが3回呼ばれる" do
		expect(Marshal).to receive(:load).exactly(3).and_return({})
		PStore.new(@dbfile).transaction {}
	end

	it "2回目のtransactionではMashal.loadが1回だけ呼ばれる" do
		expect(Marshal).to receive(:load).exactly(4).and_return({})
		PStore.new(@dbfile).transaction {}
		PStore.new(@dbfile).transaction {}
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
