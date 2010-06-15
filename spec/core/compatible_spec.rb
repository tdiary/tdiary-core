# -*- coding: utf-8 -*-

if RUBY_VERSION > '1.9'
require 'tempfile'
require 'pstore'

class String
	def to_8bit
		self.respond_to?(:force_encoding) ? self.force_encoding(Encoding::ASCII_8BIT) : self
	end
end

describe String do
	it "should return 8bit encoding string" do
		"str".to_8bit.encoding.should == Encoding::ASCII_8BIT
	end
end

describe PStore, "auto convert library" do
	before do
		@dbfile = Tempfile.new("compatible_spec").path
		PStore.new(@dbfile).transaction do |db|
			db["key1".to_8bit] = "val1".to_8bit
			db["key2".to_8bit] = 2
			db["key3".to_8bit] = [1, :sym, "string".to_8bit]
		end
		require 'misc/lib/compatible'
	end

	if "".respond_to?(:force_encoding)
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
end
