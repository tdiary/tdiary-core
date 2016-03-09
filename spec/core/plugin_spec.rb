# -*- coding: utf-8 -*-
require 'spec_helper'

require File.dirname(__FILE__) + "/../plugin/plugin_helper"
require 'tdiary/plugin'

describe TDiary::Plugin do
	before do
		config = PluginFake::Config.new
		config.plugin_path = 'spec/fixtures/plugin'
		@plugin = TDiary::Plugin.new({ conf: config, debug: true })
	end

	describe '#load_plugin' do
		before { @plugin.load_plugin('spec/fixtures/plugin/sample.rb') }
		subject { @plugin }

		it '読み込まれたプラグインのメソッドを呼び出せること' do
			expect(subject.sample).to eq 'sample plugin'
		end

		it 'プラグイン一覧が @plugin_files で取得できること' do
			# TODO: 実際にはPlugin.newした時点でload_pluginが呼ばれている
			# @plugin_filesの追加もinitializeメソッド内で実行されている
			expect(subject.instance_variable_get(:@plugin_files)).to include('spec/fixtures/plugin/sample.rb')
		end

		context 'リソースファイルが存在する場合' do
			before do
				@plugin.instance_variable_get(:@conf).lang = 'ja'
				@plugin.load_plugin('spec/fixtures/plugin/sample.rb')
			end

			it 'Confファイルで指定した言語に対応するリソースが読み込まれること' do
				expect(@plugin.sample_ja).to eq 'サンプルプラグイン'
			end
		end
	end

	describe '#eval_src' do
		before do
			@src = ERB::new('hello <%= sample %><%= undefined_method %>').src
			@plugin.instance_variable_set(:@debug, false)
		end
		subject { @plugin.eval_src(@src) }

		it 'Pluginオブジェクト内でソースが実行されること' do
			is_expected.to eq 'hello sample plugin'
		end

		context 'debugモードがONの場合' do
			before { @plugin.instance_variable_set(:@debug, true) }

			it 'Plugin内のエラーが通知されること' do
				expect { subject }.to raise_error
			end
		end
	end

	describe '#header_proc' do
		before do
			@plugin.__send__(:add_header_proc, lambda { 'header1 ' })
			@plugin.__send__(:add_header_proc, lambda { 'header2' })
		end
		subject { @plugin.__send__(:header_proc) }

		it 'add_header_procで登録したブロックが実行されること' do
			is_expected.to eq 'header1 header2'
		end
	end

	describe '#footer_proc' do
		before do
			@plugin.__send__(:add_footer_proc, lambda { 'footer1 ' })
			@plugin.__send__(:add_footer_proc, lambda { 'footer2' })
		end
		subject { @plugin.__send__(:footer_proc) }

		it 'add_footer_procで登録したブロックが実行されること' do
			is_expected.to eq 'footer1 footer2'
		end
	end

	describe '#update_proc' do
		let (:proc1) { lambda {} }
		let (:proc2) { lambda {} }
		before do
			@plugin.__send__(:add_update_proc, proc1)
			@plugin.__send__(:add_update_proc, proc2)
		end
		subject { @plugin.__send__(:update_proc) }

		it 'add_update_procで登録したブロックが実行されること' do
			expect(proc1).to receive(:call)
			expect(proc2).to receive(:call)
			# should_receiveの場合はsubjectが使えないため明示的に実行
			@plugin.__send__(:update_proc)
		end

		it '空の文字列を返すこと' do
			is_expected.to eq ''
		end
	end

	describe '#title_proc' do
		let (:proc1) { lambda {|date, title| "title1" } }
		let (:proc2) { lambda {|date, title| "title2" } }
		let (:date) { Time.local(2012, 1, 2) }
		before do
			@plugin.__send__(:add_title_proc, proc1)
			@plugin.__send__(:add_title_proc, proc2)
		end
		subject { @plugin.__send__(:title_proc, date, 'title') }

		it 'add_title_procで登録したブロックを実行し、最後の結果を返すこと' do
			is_expected.to eq 'title2'
		end

		it '前のprocの結果が次のprocに渡されること' do
			expect(proc1).to receive(:call).with(date, 'title').and_return('title1')
			expect(proc2).to receive(:call).with(date, 'title1')
			@plugin.__send__(:title_proc, date, 'title')
		end

		it 'apply_pluginメソッドを呼び出すこと' do
			expect(@plugin).to receive(:apply_plugin)
			# should_receiveの場合はsubjectが使えないため明示的に実行
			@plugin.__send__(:title_proc, date, 'title')
		end
	end

	describe '#body_enter_proc' do
		let (:date) { Time.local(2012, 1, 2) }
		before do
			@plugin.__send__(:add_body_enter_proc, lambda {|date| 'body1 ' })
			@plugin.__send__(:add_body_enter_proc, lambda {|date| 'body2' })
		end
		subject { @plugin.__send__(:body_enter_proc, date) }

		it 'add_body_enter_procで登録したブロックが実行されること' do
			is_expected.to eq 'body1 body2'
		end
	end

	describe '#body_leave_proc' do
		before do
			@plugin.__send__(:add_body_leave_proc, lambda {|date| 'body1 ' })
			@plugin.__send__(:add_body_leave_proc, lambda {|date| 'body2' })
		end
		subject { @plugin.__send__(:body_leave_proc, @date) }

		it 'add_body_leave_procで登録したブロックが実行されること' do
			is_expected.to eq 'body1 body2'
		end
	end

	describe '#section_enter_proc' do
		let (:proc1) { lambda {|date, index| 'section1 ' } }
		let (:proc2) { lambda {|date, index| 'section2' } }
		let (:date1) { Time.local(2012, 1, 2) }
		let (:date2) { Time.local(2012, 1, 3) }
		before do
			@plugin.__send__(:add_section_enter_proc, proc1)
			@plugin.__send__(:add_section_enter_proc, proc2)
		end
		subject { @plugin.__send__(:section_enter_proc, date1) }

		it 'add_section_enter_procで登録したブロックを実行し、結果を連結して返すこと' do
			is_expected.to eq 'section1 section2'
		end

		it '呼ばれた回数に応じてセクション番号の数が増加すること (日付単位)' do
			expect(proc1).to receive(:call).with(date1, 1)
			@plugin.__send__(:section_enter_proc, date1)
			expect(proc1).to receive(:call).with(date1, 2)
			@plugin.__send__(:section_enter_proc, date1)
			expect(proc1).to receive(:call).with(date2, 1)
			@plugin.__send__(:section_enter_proc, date2)
		end
	end

	describe '#subtitle_proc' do
		let (:proc1) { lambda {|date, index, subtitle| "subtitle1" } }
		let (:proc2) { lambda {|date, index, subtitle| "subtitle2" } }
		let (:date1) { Time.local(2012, 1, 2) }
		let (:date2) { Time.local(2012, 1, 3) }
		before do
			@plugin.__send__(:add_subtitle_proc, proc1)
			@plugin.__send__(:add_subtitle_proc, proc2)
		end
		subject { @plugin.__send__(:subtitle_proc, date1, 'subtitle') }

		it 'add_subtitle_procで登録したブロックを実行し、最後の結果を返すこと' do
			is_expected.to eq 'subtitle2'
		end

		it '前のprocの結果が次のprocに渡されること' do
			expect(proc1).to receive(:call).with(date1, 1, 'subtitle').and_return('subtitle1')
			expect(proc2).to receive(:call).with(date1, 1, 'subtitle1')
			@plugin.__send__(:section_enter_proc, date1)
			@plugin.__send__(:subtitle_proc, date1, 'subtitle')
		end

		it 'apply_pluginメソッドを呼び出すこと' do
			expect(@plugin).to receive(:apply_plugin)
			# should_receiveの場合はsubjectが使えないため明示的に実行
			@plugin.__send__(:subtitle_proc, date1, 'title')
		end
	end

	describe '#section_leave_proc' do
		let (:proc1) { lambda {|date, index| 'section1 ' } }
		let (:proc2) { lambda {|date, index| 'section2' } }
		let (:date1) { Time.local(2012, 1, 2) }
		let (:date2) { Time.local(2012, 1, 3) }
		before do
			@plugin.__send__(:add_section_leave_proc, proc1)
			@plugin.__send__(:add_section_leave_proc, proc2)
		end
		subject { @plugin.__send__(:section_leave_proc, date1) }

		it 'add_section_leave_procで登録したブロックを実行し、結果を連結して返すこと' do
			is_expected.to eq 'section1 section2'
		end

		it '呼ばれた回数に応じてセクション番号の数が増加すること (日付単位)' do
			# セクション番号はsection_enter_procの呼び出し回数で決定する
			expect(proc1).to receive(:call).with(date1, 1)
			@plugin.__send__(:section_enter_proc, date1)
			@plugin.__send__(:section_leave_proc, date1)
			expect(proc1).to receive(:call).with(date1, 2)
			@plugin.__send__(:section_enter_proc, date1)
			@plugin.__send__(:section_leave_proc, date1)
			expect(proc1).to receive(:call).with(date2, 1)
			@plugin.__send__(:section_enter_proc, date2)
			@plugin.__send__(:section_leave_proc, date2)
		end
	end

	describe '#comment_leave_proc' do
		let (:date) { Time.local(2012, 1, 2) }
		before do
			@plugin.__send__(:add_comment_leave_proc, lambda {|date| 'comment1 ' })
			@plugin.__send__(:add_comment_leave_proc, lambda {|date| 'comment2' })
		end
		subject { @plugin.__send__(:comment_leave_proc, date) }

		it 'add_comment_leave_procで登録したブロックが実行されること' do
			is_expected.to eq 'comment1 comment2'
		end
	end

	describe '#edit_proc' do
		let (:date) { Time.local(2012, 1, 2) }
		before do
			@plugin.__send__(:add_edit_proc, lambda {|date| 'edit1 ' })
			@plugin.__send__(:add_edit_proc, lambda {|date| 'edit2' })
		end
		subject { @plugin.__send__(:edit_proc, date) }

		it 'add_edit_procで登録したブロックが実行されること' do
			is_expected.to eq 'edit1 edit2'
		end
	end

	describe '#form_proc' do
		let (:date) { Time.local(2012, 1, 2) }
		before do
			@plugin.__send__(:add_form_proc, lambda {|date| 'form1 ' })
			@plugin.__send__(:add_form_proc, lambda {|date| 'form2' })
		end
		subject { @plugin.__send__(:form_proc, date) }

		it 'add_form_procで登録したブロックが実行されること' do
			is_expected.to eq 'form1 form2'
		end
	end

	describe '#add_conf_proc' do
		let(:proc) { lambda { 'conf' } }
		subject { @plugin.__send__(:add_conf_proc, 'key1', 'label1', nil, proc) }

		context '@modeがconfの場合' do
			before { @plugin.instance_variable_set(:@mode, 'conf') }
			it 'コールバックを登録すること' do
				is_expected.to include('label1')
			end
		end

		context '@modeがsaveconfの場合' do
			before { @plugin.instance_variable_set(:@mode, 'saveconf') }
			it 'コールバックを登録すること' do
				is_expected.to include('label1')
			end
		end

		context '@modeがconf, saveconf以外の場合' do
			before { @plugin.instance_variable_set(:@mode, 'edit') }
			it 'コールバックの登録を無視すること' do
				is_expected.to be_nil
			end
		end
	end

	describe '#conf_proc' do
		let (:date) { Time.local(2012, 1, 2) }
		before do
			@plugin.instance_variable_set(:@mode, 'conf')
			@plugin.__send__(:add_conf_proc, 'key1', 'label1', nil, lambda { 'conf1' })
			@plugin.__send__(:add_conf_proc, 'key2', 'label2', nil, lambda { 'conf2' })
		end
		subject { @plugin.__send__(:conf_proc, 'key1') }

		it 'add_conf_procで登録したブロックのうち、keyが一致するものを実行して結果を返すこと' do
			is_expected.to eq 'conf1'
		end
	end

	describe '#remove_tag' do
		before { @string = 'test <a href="http://example.com/">example.<b>com</b></a>' }
		subject { @plugin.__send__(:remove_tag, @string) }

		it '文字列からタグが除去されること' do
			is_expected.to eq 'test example.com'
		end
	end

	describe '#apply_plugin' do
		before do
			@plugin.instance_variable_get(:@conf).options['apply_plugin'] = true
		end

		subject { @plugin.__send__(:apply_plugin, '<%= sample %>') }
		it 'プラグインが再実行されること' do
			is_expected.to eq 'sample plugin'
		end

		context '解釈できない文字列を渡された場合' do
			subject { @plugin.__send__(:apply_plugin, '<%= undefined_method %>') }
			it { is_expected.to include 'Invalid Text' }
		end

		context '文字列がnilの場合' do
			subject { @plugin.__send__(:apply_plugin, nil) }
			it { is_expected.to eq '' }
		end

		context 'remove_tagがtrueの場合' do
			it 'remove_tagメソッドを呼び出すこと' do
				expect(@plugin).to receive(:remove_tag)
				@plugin.__send__(:apply_plugin, '', true)
			end
		end
	end

	describe '#content_proc' do
		let (:proc1) { lambda {|date| "contents1" } }
		let (:proc2) { lambda {|date| "contents2" } }
		let (:date) { Time.local(2012, 1, 2) }
		before do
			@plugin.__send__(:add_content_proc, 'key1', proc1)
			@plugin.__send__(:add_content_proc, 'key2', proc2)
		end
		subject { @plugin.__send__(:content_proc, 'key1', date) }

		it 'add_content_procで登録したブロックのうち、keyに相当するものを実行すること' do
			is_expected.to eq 'contents1'
		end

		context 'keyに相当するブロックが存在しない場合' do
			subject { @plugin.__send__(:content_proc, 'unregistered_key', date) }
			it { expect { subject }.to raise_error }
		end
	end

	describe '#startup_proc' do
		let (:proc) { lambda { "some plugin" } }
		let (:app) { lambda { "tdiary application" } }
		before do
			@plugin.__send__(:add_startup_proc, &proc)
		end

		it 'add_startup_procで登録したブロックが実行されること' do
			expect(proc).to receive(:call).with(app)
			@plugin.__send__(:startup_proc, app)
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
