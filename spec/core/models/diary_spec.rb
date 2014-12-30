require 'spec_helper'

require 'tdiary'
require 'tdiary/models/diary'

describe TDiary::Models::Diary do
	let(:conf) { TDiary.configuration }
	let(:diary) { TDiary::Models::Diary.new(conf) }

	before do
	end

	describe "#month" do
		subject { diary.month("2014", "12") }
		it { expect(subject).to be_a_kind_of TDiary::TDiaryMonth }

	end

	describe "#day" do
		subject { diary.day("2014", "12", "24") }
		it { expect(subject).to be_a_kind_of TDiary::TDiaryDay }
	end
end
