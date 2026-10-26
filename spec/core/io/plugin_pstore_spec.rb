require 'spec_helper'

require 'tmpdir'
require 'tdiary/io/plugin_pstore'

describe TDiary::IO::PluginPStore do
  let(:io) { Class.new.extend(TDiary::IO::PluginPStore) }

  around do |example|
    Dir.mktmpdir {|dir| @storage = Pathname(dir); example.run }
  end

  describe "#plugin_transaction" do
    before do
      PStore.new(@storage + "test.db").transaction do |db|
        db["foo"] = "bar"
        db[:__ruby_version] = "3.2.4"
      end
    end

    it "does not list :__ruby_version in keys" do
      expect(io.plugin_transaction(@storage, "test") {|db| db.keys }).to eq ["foo"]
    end
  end
end
