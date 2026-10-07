require File.expand_path("../plugin_helper", __FILE__)
require "rexml/document"
require "tmpdir"

describe "makerss plugin" do
	before do
		@conf = PluginFake::Config.new.tap {|conf|
			conf.plugin_path = "spec/fixtures/plugin"
			conf.options["base_url"] = "http://example.com/diary/"
		}
		@plugin = TDiary::Plugin.new(
			conf: @conf,
			mode: "append",
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

	describe "#makerss_body" do
		subject(:content) do
			REXML::Document.new(@plugin.makerss_header(uri) + "</channel>" + @plugin.makerss_body(uri, rdfsec) + @plugin.makerss_footer)
				.elements["//item/content:encoded"].text
		end
		let(:uri) { "http://example.com/test" }
		let(:rdfsec) do
			TDiary::RDFSection.new("20261007p01", nil, nil, data: {
				"time" => "2026-10-07T00:00:00+09:00",
				"is_comment" => false,
				"section" => {"subtitle" => "Subtitle", "body" => "<p>Body</p>", "category" => [], "visibility" => true}
			})
		end

		before { allow(@conf).to receive(:shorten) {|str, len| str } }

		context "without makerss.hidesubtitle" do
			it { expect(content).to start_with("<h3>Subtitle</h3><p>Body</p>") }
		end

		context "with makerss.hidesubtitle" do
			before { @conf["makerss.hidesubtitle"] = true }
			it { expect(content).to start_with("<p>Body</p>") }
		end
	end

	describe "makerss.hidesubtitle setting" do
		around do |example|
			Dir.mktmpdir {|dir| @dir = dir; example.run }
		end

		%w(ja en).each do |lang|
			it "is saved from the #{lang} form" do
				@conf.lang = lang
				@conf["makerss.file"] = File.join(@dir, "index.rdf")
				cgi = Struct.new(:params).new(Hash.new([]).merge("makerss.hidesubtitle" => ["t"]))
				plugin = TDiary::Plugin.new(conf: @conf, mode: "saveconf", cgi: cgi).tap {|plugin|
					plugin.load_plugin("misc/plugin/makerss.rb")
				}

				html = plugin.__send__(:conf_proc, "makerss")
				expect(@conf["makerss.hidesubtitle"]).to be true
				expect(html).to match(%r|<select name="makerss.hidesubtitle">\s*<option value="f">[^<]*</option>\s*<option value="t" selected>|)
			end
		end
	end
end
