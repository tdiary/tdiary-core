require 'spec_helper'

require 'tdiary'
require 'tdiary/configuration'

describe TDiary::Configuration do
  let(:tdiary_conf) { File.expand_path("../../fixtures/tdiary.conf.webrick", __FILE__) }
  let(:work_conf) { File.expand_path('../../../tdiary.conf', __FILE__) }

  before do
    FileUtils.cp_r tdiary_conf, work_conf, :verbose => false
  end

  after do
    FileUtils.rm_rf work_conf
  end

  it "TDiary.configuration" do
    TDiary.configuration.class.should == TDiary::Configuration
  end

  it "TDiary.configuration.attribute" do
    TDiary.configuration.style.should == "Wiki"
  end
end
