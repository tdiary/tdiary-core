require 'spec_helper'

require 'tdiary/cache/file'
require 'tdiary/io/default'

describe TDiary::IO::Default do
  it 'is_a TDiary::IO::Base' do
    expect { TDiary::IO::Default.is_a?(TDiary::IO::Base) }.to be_true
  end

  describe "#save_cgi_conf and #load_cgi_conf" do
    let(:conf) do
      conf = DummyConf.new
      conf.data_path = TDiary.root + "/tmp/"
      conf
    end

    it { expect(TDiary::IO::Default.load_cgi_conf(conf)).to be_nil }

    context "given body" do
      before do
        TDiary::IO::Default.save_cgi_conf(conf, 'foo')
      end

      it { expect(TDiary::IO::Default.load_cgi_conf(conf)).to eq 'foo' }

      context "update" do
        before do
          TDiary::IO::Default.save_cgi_conf(conf, 'bar')
        end
        it { expect(TDiary::IO::Default.load_cgi_conf(conf)).to eq 'bar' }
      end
    end
  end

  describe "#transaction" do
    let(:io) { TDiary::IO::Default.new(DummyTDiary.new) }
    let(:today) { Time.now.strftime( '%Y%m%d' ) }

    before do
      io.transaction( Time.now ) do |diaries|
        @diaries = diaries
        diary = io.diary_factory(today, "foo", "", "wiki")
        @diaries[today] = diary.append("bar", "hsbt")
        TDiary::TDiaryBase::DIRTY_DIARY
      end
    end

    subject { File.open(TDiary.root + "/tmp/#{Time.now.year}/#{Time.now.year}#{Time.now.month}.td2").read }
    it { expect(subject).to be_include "foo" }
    it { expect(subject).to be_include "bar" }

    it "restore diary" do
      io.transaction( Time.now ) do |diaries|
        @diaries = diaries
        expect(@diaries[today].title).to eq "foo"
        expect(@diaries[today].to_src).to be_include "bar"
        TDiary::TDiaryBase::DIRTY_DIARY
      end
    end

    context "update diary" do
      before do
        io.transaction( Time.now ) do |diaries|
          @diaries = diaries
          @diaries[today].replace(today, "buzz", "alice")
          TDiary::TDiaryBase::DIRTY_DIARY
        end
      end

      subject { File.open(TDiary.root + "/tmp/#{Time.now.year}/#{Time.now.year}#{Time.now.month}.td2").read }

      it "update contents of diary" do
        expect(subject).to_not be_nil
        expect(subject).to_not be_include "foo"
        expect(subject).to_not be_include "bar"
        expect(subject).to be_include "buzz"
        expect(subject).to be_include "alice"
      end
    end

  end

  before(:all) do
    ["/tmp/tdiary.conf", "/tmp/#{Time.now.year}"].each do |file|
      FileUtils.rm_rf TDiary.root + file
    end
  end

  after(:all) do
    ["/tmp/tdiary.conf", "/tmp/#{Time.now.year}"].each do |file|
      FileUtils.rm_rf TDiary.root + file
    end
  end
end
