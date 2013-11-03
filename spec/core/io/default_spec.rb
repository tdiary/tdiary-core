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
end
