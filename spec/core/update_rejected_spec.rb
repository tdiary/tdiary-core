require 'spec_helper'
require 'rack/test'
require 'tdiary/application'

describe 'update form posts that are not saved' do
	include Rack::Test::Methods

	def app
		@app ||= Rack::Builder.new do
			map '/' do
				run TDiary::Dispatcher.index
			end

			map '/update.rb' do
				run TDiary::Dispatcher.update
			end
		end
	end

	let(:work_conf) { File.expand_path('../../../tdiary.conf', __FILE__) }
	let(:work_data_dir) { File.expand_path('../../../tmp/data', __FILE__) }
	let(:referer) { { 'HTTP_REFERER' => 'http://example.org/update.rb' } }

	before do
		FileUtils.cp_r File.expand_path('../../fixtures/tdiary.conf.rack', __FILE__), work_conf
		FileUtils.mkdir_p work_data_dir
		FileUtils.cp_r File.expand_path('../../fixtures/just_installed.conf', __FILE__), File.join(work_data_dir, 'tdiary.conf')
	end

	after do
		FileUtils.rm_rf work_data_dir
		FileUtils.rm_f work_conf
	end

	def post_diary(date, extra)
		y, m, d = date.split('-')
		post '/update.rb', { 'year' => y, 'month' => m, 'day' => d, 'title' => 'title', 'body' => 'kept text' }.merge(extra), referer
	end

	def diary_of(date)
		get "/?date=#{date}"
		last_response.body
	end

	def stamp_in(body)
		body[/name="last_modified" value="(\d+)"/, 1]
	end

	describe 'with a date that does not exist' do
		it 'does not move 2/30 to March but shows the text again' do
			post_diary('2026-2-30', 'old' => '20261007', 'append' => '追記')

			expect(last_response.status).to eq 200
			expect(last_response.body).to include '日付「2026-2-30」は存在しない'
			expect(last_response.body).to include 'kept text'
			expect(last_response.body).to include 'name="old" value="20261007"'
			expect(last_response.body).to include 'name="append"'
			expect(diary_of('20260302')).not_to include 'kept text'
		end

		it 'does not save a two digit year in the first century' do
			post_diary('26-10-7', 'old' => '20261007', 'append' => '追記')

			expect(last_response.status).to eq 200
			expect(last_response.body).to include 'kept text'
			expect(File.exist?(File.join(work_data_dir, '0026'))).to be false
		end

		it 'keeps the edited text and the edited day when replacing with a wrong month' do
			post_diary('2026-10-7', 'old' => '20261007', 'append' => '追記', 'body' => 'saved text')
			post_diary('2026-13-7', 'old' => '20261007', 'replace' => '登録', 'body' => 'edited text')

			expect(last_response.status).to eq 200
			expect(last_response.body).to include 'edited text'
			expect(last_response.body).to include 'name="replace"'
			expect(diary_of('20261007')).to include 'saved text'
		end

		it 'keeps the text of a preview with a wrong date' do
			post_diary('2026-13-7', 'old' => '20261007', 'appendpreview' => 'プレビュー')

			expect(last_response.status).to eq 200
			expect(last_response.body).to include '日付「2026-13-7」は存在しない'
			expect(last_response.body).to include 'kept text'
			expect(last_response.body).to include 'name="append"'
		end

		it 'still appends a post without any date to today' do
			post '/update.rb', { 'title' => 'title', 'body' => 'dateless text', 'append' => '追記' }, referer

			expect(last_response.status).to eq 303
			expect(diary_of(Time.now.strftime('%Y%m%d'))).to include 'dateless text'
		end
	end

	describe 'over an update made after the form was opened' do
		before do
			post_diary('2026-10-7', 'old' => '20261007', 'append' => '追記', 'body' => 'first text')
			get '/update.rb?edit=true;year=2026;month=10;day=7'
			@opened = stamp_in(last_response.body)
		end

		def replace_with(text, stamp)
			post_diary('2026-10-7', 'old' => '20261007', 'replace' => '登録', 'body' => text, 'last_modified' => stamp)
		end

		it 'saves when nothing was saved in between' do
			replace_with('my text', @opened)

			expect(last_response.status).to eq 303
			expect(diary_of('20261007')).to include 'my text'
		end

		it 'shows the text again instead of overwriting the other update' do
			replace_with('other text', (@opened.to_i - 10).to_s)

			expect(last_response.status).to eq 200
			expect(last_response.body).to include 'この日の日記が別の場所で更新されています'
			expect(last_response.body).to include 'other text'
			expect(diary_of('20261007')).to include 'first text'
		end

		it 'overwrites when the shown text is sent again' do
			replace_with('other text', (@opened.to_i - 10).to_s)
			replace_with('other text', stamp_in(last_response.body))

			expect(last_response.status).to eq 303
			expect(diary_of('20261007')).to include 'other text'
		end

		it 'carries the stamp through the preview' do
			post_diary('2026-10-7', 'old' => '20261007', 'replacepreview' => 'プレビュー', 'last_modified' => @opened)

			expect(stamp_in(last_response.body)).to eq @opened
		end

		it 'saves posts from tools that do not send the stamp' do
			post_diary('2026-10-7', 'old' => '20261007', 'replace' => '登録', 'body' => 'tool text')

			expect(last_response.status).to eq 303
			expect(diary_of('20261007')).to include 'tool text'
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
