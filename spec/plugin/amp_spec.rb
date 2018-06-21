require File.expand_path('../plugin_helper', __FILE__)
require 'tdiary/plugin'

describe "amp plugin w/" do
	before do
		# stub of TDiary::IO::Diary
		@diary = Object.new.tap {|diary|
			allow(diary).to receive(:title) { 'Example Diary' }
			allow(diary).to receive(:date) { Time.parse('2017/3/2') }
		}
		@conf = PluginFake::Config.new.tap {|conf|
			conf.plugin_path = 'spec/fixtures/plugin'
			conf.lang = 'ja'
			allow(conf).to receive(:base_url) { 'http://example.com/index.rb' }
		}
		@plugin = TDiary::Plugin.new(
			debug: true,
			conf: @conf,
			date: Time.parse('2017/3/2'),
			diaries: { '20170302' => @diary }
		).tap {|plugin|
			plugin.load_plugin('misc/plugin/amp.rb')
		}
	end

	describe "#amp_canonical_url" do
		subject { @plugin.amp_canonical_url(@diary).to_s }
		it { expect(subject).to eq('http://example.com/index.rb?date=20170302') }
	end

	describe "#header_proc" do
		subject { @plugin.__send__(:header_proc) }

		describe "when @mode == 'day'" do
			before { @plugin.instance_variable_set(:@mode, 'day') }
			it { expect(subject).to eq('<link rel="amphtml" href="http://example.com/index.rb?date=20170302&plugin=amp">') }
		end

		describe "when @mode != 'day'" do
			before { @plugin.instance_variable_set(:@mode, 'latest') }
			it { expect(subject).to eq('') }
		end
	end

	describe "#amp_theme_css" do
		subject { @plugin.amp_theme_css }

		describe "when local theme" do
			before {
				@conf.theme = 'local/default'
				allow(@plugin).to receive(:theme_paths_local) { ['theme/*'] }
			}
			it { expect(subject).to include('Title: tDiary3 default') }
		end

		describe "when online theme" do
			before {
				@conf.theme = 'online/default'
				allow(@plugin).to receive(:theme_url_online) { '//tdiary.github.io/tdiary-theme/default/default.css' }
			}
			it { expect(subject).to include('Title: tDiary3 default') }
		end
	end

	describe "#amp_day_title" do
		subject { @plugin.amp_day_title(@diary) }
		it { expect(subject).to eq('Example Diary') }
	end

	describe "#amp_body" do
		subject { @plugin.amp_body(@diary) }

		describe "when contain img element" do
			before { allow(@diary).to receive(:to_html) {
				<<-HTML
				<h3>subsection</h3>
				<p>This is a test diary.</p>
				<img src="image.jpg" weight="640" height="480">
				HTML
			} }
			it { expect(subject).to include('<h3>subsection</h3>') }
			it { expect(subject).to include('<amp-img layout="responsive" src="image.jpg" weight="640" height="480">') }
		end

		describe "when contain script element" do
			before { allow(@diary).to receive(:to_html) {
				<<-HTML
				<h3>subsection</h3>
				<p>This is a test diary.</p>
				<script>
					console.log("test");
				</script>
				<noscript>noscript</noscript>
				HTML
			} }
			it { expect(subject).to include('<h3>subsection</h3>') }
			it { expect(subject).not_to include('<script>') }
			it { expect(subject).to include('<noscript>noscript</noscript>') }
		end
	end

	describe "#content_proc" do
		subject { @plugin.__send__(:content_proc, 'amp', '20170302') }
		before {
			@conf.theme = 'local/default'
			allow(@plugin).to receive(:theme_paths_local) { ['theme/*'] }
			allow(@plugin).to receive(:navi_user) { '' }
			allow(@diary).to receive(:to_html) { '<h3>sample</h3>' }
		}
		it { expect(subject).to include('<html ⚡ lang="ja">') }
		it { expect(subject).to include('<h3>sample</h3>') }
	end

	describe "AMP module" do
		subject { @plugin }
		it { expect(subject.singleton_class.constants).to include(:AMP) }
		it { expect(subject.methods).to include(:add_amp_header_proc) }
		it { expect(subject.methods).to include(:amp_body_enter_proc) }
	end
end
