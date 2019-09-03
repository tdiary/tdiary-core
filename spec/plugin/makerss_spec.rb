require File.expand_path("../plugin_helper", __FILE__)
require "rexml/document"

describe "makerss plugin" do
	before do
		@conf = PluginFake::Config.new.tap {|conf|
			conf.plugin_path = "spec/fixtures/plugin"
			conf.options["base_url"] = "http://example.com/diary/"
		}
		@plugin = TDiary::Plugin.new(
			conf: @conf,
		).tap {|plugin|
			plugin.load_plugin("misc/plugin/makerss.rb")
		}
	end

	describe "#makerss_header" do
		subject(:rdf) do
			REXML::Document.new(@plugin.makerss_header(uri) + "</channel>" + @plugin.makerss_footer)
				.elements["//rdf:RDF"]
		end
		let(:uri) { "http://example.com/test" }
		let(:channel) { rdf.elements["channel"] }
		let(:about) { channel.attributes["about"] }
		let(:description) { channel.elements["description"] }
		let(:rights) { channel.elements["dc:rights"] }

		before do
			@conf.html_lang = "ja-JP"
			@conf.html_title = "<タイトル>"
			@conf.author_name = "<著者>"
		end

		it { expect(rdf.attributes["lang"]).to eq(@conf.html_lang) }
		it { expect(channel.elements["title"].text).to eq(@conf.html_title) }
		it { expect(channel.elements["link"].text).to eq(uri) }
		it { expect(channel.elements["dc:creator"].text).to eq(@conf.author_name) }

		context "with makerss.url" do
			before { @conf["makerss.url"] = "http://example.com/rss" }
			it { expect(about).to eq(@conf["makerss.url"]) }
		end

		context "without makerss.url" do
			before { @conf["makerss.url"] = nil }
			it { expect(about).to eq(@conf["base_url"] + "index.rdf") }
		end

		context "with description" do
			before { @conf["description"] = "<makerss.rbのテスト>" }
			it { expect(description.text).to eq(@conf.description) }
		end

		context "without description" do
			before { @conf["description"] = nil }
			it { expect(description.text).to eq(nil) }
		end

		context "with author_mail" do
			before { @conf.author_mail = "author@example.com" }
			it do
				expect(rights.text).to eq(
					"Copyright #{Time.now.year} #{@conf.author_name} <#{@conf.author_mail}>" \
					", copyright of comments by respective authors")
			end
		end

		context "without author_mail" do
			before { @conf.author_mail = nil }
			it do
				expect(rights.text).to eq(
					"Copyright #{Time.now.year} #{@conf.author_name}" \
					", copyright of comments by respective authors")
			end
		end
	end
end
