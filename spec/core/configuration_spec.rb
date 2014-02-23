require 'spec_helper'

require 'tdiary'
require 'tdiary/configuration'

describe TDiary::Configuration do
  let(:tdiary_conf) { File.expand_path("../../fixtures/tdiary.conf.webrick", __FILE__) }
  let(:work_conf) { File.expand_path('../../../tdiary.conf', __FILE__) }

  before do
    FileUtils.cp_r tdiary_conf, work_conf, verbose: false
  end

  after do
    FileUtils.rm_rf work_conf
  end

  describe "TDiary.configuration" do
    before do
      @obj = TDiary.configuration
    end

    it { expect(@obj.class).to eq TDiary::Configuration }
    it "singleton" do
      expect(@obj).to eq TDiary.configuration
    end
  end

  it "TDiary.configuration.attribute" do
    expect(TDiary.configuration.style).to eq("Wiki")
  end
end
