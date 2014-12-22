require 'spec_helper'
require 'fileutils'

describe TDiary do
  describe 'LOAD_PATH' do
    before do
      @root_path = File.expand_path(File.dirname(__FILE__) + '/../..')
      @loaded_paths = $LOAD_PATH.map{|path| File.expand_path(path)}
    end

    it "include misc path into load path" do
      expect(@loaded_paths).to be_include @root_path + '/misc/lib'
    end

    context 'append gem' do
      before do
        FileUtils.mkdir_p @root_path + '/misc/lib/foo-0.0.1/lib'
        load @root_path + '/lib/tdiary.rb'
        @loaded_paths = $LOAD_PATH.map{|path| File.expand_path(path)}
      end

      it "include append gem path into load path" do
        expect(@loaded_paths).to be_include @root_path + '/misc/lib/foo-0.0.1/lib'
      end

      after do
        FileUtils.rm_rf @root_path + '/misc/lib/foo-0.0.1'
      end
    end
  end
end
