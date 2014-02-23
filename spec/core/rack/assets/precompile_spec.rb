# -*- coding: utf-8 -*-
require 'spec_helper'
require 'rack/test'
require 'fileutils'
require 'sprockets'
require 'tdiary/rack/assets/precompile'

describe TDiary::Rack::Assets::Precompile do
	include Rack::Test::Methods

	let(:app) do
		TDiary::Rack::Assets::Precompile.new(lambda{|env| [200, {}, ['Awesome']]}, @environment)
	end
	let(:assets_path) {"#{TDiary::PATH}/tmp/assets"}

	before do
		FileUtils.mkdir_p assets_path
		@environment = Sprockets::Environment.new
		@environment.append_path assets_path
	end

	after do
		FileUtils.rm_rf assets_path
	end

	context "JavaScript が無い場合" do
		before do
			FileUtils.touch "#{assets_path}/foo.coffee"
			get '/'
		end

		it "JavaScript にコンパイルされる" do
			expect(FileTest.exist?("#{assets_path}/foo.js")).to be_truthy
		end
	end

	context "JavaScript がある場合" do
		context "CoffeeScript の方が新しい場合" do
			before do
				FileUtils.touch "#{assets_path}/foo.js"
				sleep 1
				FileUtils.touch "#{assets_path}/foo.coffee"
				@jstime = File.mtime("#{assets_path}/foo.js").to_i

				get '/'
			end

			it "JavaScript が更新される" do
				expect(@jstime).to be < File.mtime("#{assets_path}/foo.js").to_i
			end
		end

		context "JavaScript の方が新しい場合" do
			before do
				FileUtils.touch "#{assets_path}/foo.coffee"
				sleep 1
				FileUtils.touch "#{assets_path}/foo.js"
				@jstime = File.mtime("#{assets_path}/foo.js").to_i

				get '/'
			end

			it "JavaScript は更新されない" do
				expect(@jstime).to eq(File.mtime("#{assets_path}/foo.js").to_i)
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
