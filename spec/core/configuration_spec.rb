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

    it { @obj.class.should eq TDiary::Configuration }
    it "singleton" do
      @obj.should eq TDiary.configuration
    end
  end

  it "TDiary.configuration.attribute" do
    TDiary.configuration.style.should == "Wiki"
  end
end
