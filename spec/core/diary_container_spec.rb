require 'spec_helper'

require 'tdiary'
require 'tdiary/cache/file'
require 'tdiary/io/default'
require 'tdiary/diary_container'

describe TDiary::DiaryContainer do
	let(:conf) { TDiary::Configuration.new }
	let(:today) { Time.local(2005, 1, 20, 12, 0, 0) }

  let(:tdiary_conf_org) { File.join(TDiary::root, "spec/fixtures/tdiary.conf.webrick") }
  let(:tdiary_conf) { File.join(TDiary::root, "tdiary.conf") }

  before do
  	# create sample confing
		FileUtils.cp_r tdiary_conf_org, tdiary_conf, verbose: false

		# create sample diary
		tdiary = DummyTDiary.new
		tdiary.conf = conf
		io = TDiary::IO::Default.new(tdiary)
		io.transaction(today) do |diaries|
			date = today.strftime('%Y%m%d')
			diary = io.diary_factory(date, "foo", "", "wiki")
			diaries[date] = diary.append("bar")
			TDiary::TDiaryBase::DIRTY_DIARY
		end
  end

  after do
    FileUtils.rm_f tdiary_conf
		["/tmp/data/#{today.year}"].each do |dir|
			FileUtils.rm_rf File.join(TDiary.root, dir)
		end
  end

	context "with find_by_month" do
		let(:diary) { TDiary::DiaryContainer.find_by_month(conf, "200501") }
		it { expect(diary).to be_a_kind_of TDiary::DiaryContainer }

		describe "#conf" do
			subject { diary.conf }
			it { expect(subject).to be_a_kind_of TDiary::Configuration	}
		end

		describe "#diaries" do
			subject { diary.diaries }
			it { expect(subject).to be_a_kind_of Hash }
			it { expect(subject.keys).to include('20050120') }
			it { expect(subject.values).to include(be_a_kind_of TDiary::Style::WikiDiary) }
		end
	end

	context "with find_by_day" do
		let(:diary) { TDiary::DiaryContainer.find_by_day(conf, "20050120") }
		it { expect(diary).to be_a_kind_of TDiary::DiaryContainer }

		describe "#conf" do
			subject { diary.conf }
			it { expect(subject).to be_a_kind_of TDiary::Configuration	}
		end

		describe "#diaries" do
			subject { diary.diaries }
			it { expect(subject).to be_a_kind_of Hash }
			it { expect(subject.keys).to include('20050120') }
			it { expect(subject.values).to include(be_a_kind_of TDiary::Style::WikiDiary) }
		end
	end
end
