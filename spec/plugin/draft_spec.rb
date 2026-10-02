require File.expand_path('../plugin_helper', __FILE__)
require 'json'

class DraftStorageFake < Hash
	def get( key ); self[key]; end
	def set( key, value ); self[key] = value; end
end

describe "draft plugin" do
	let(:storage) { DraftStorageFake.new }
	let(:conf) {
		store = storage
		PluginFake::Config.new.tap {|conf|
			conf.plugin_path = "spec/fixtures/plugin"
			conf.lang = "ja"
			conf.io_class = Class.new {
				define_singleton_method(:plugin_open) {|c| store }
				define_singleton_method(:plugin_close) {|s| }
				define_singleton_method(:plugin_transaction) {|s, name, &block| block.call( s ) }
			}
		}
	}

	def draft_plugin( mode, params = {} )
		cgi = Struct.new(:params).new( Hash.new( [] ).merge( params.transform_values {|v| [v] } ) )
		TDiary::Plugin.new( conf: conf, mode: mode, cgi: cgi ).tap {|plugin|
			plugin.load_plugin( "misc/plugin/draft.rb" )
		}
	end

	def js_settings( plugin )
		plugin.instance_variable_get( :@javascript_setting ).to_h
	end

	def stored( key )
		JSON.parse( storage.get( key ) || '[]' )
	end

	def draft( id, date, value = "draft #{id}" )
		{ 'id' => id, 'date' => date, 'value' => value }
	end

	describe "in the update form" do
		it "embeds the drafts kept on the server" do
			storage.set( 'drafts', [draft( 'a1', 1 )].to_json )
			storage.set( 'deleted', ['b2'].to_json )

			settings = js_settings( draft_plugin( 'form' ) )

			expect( JSON.parse( settings['$tDiary.plugin.draft.server'] ) ).to eq(
				'drafts' => [draft( 'a1', 1 )], 'deleted' => ['b2'], 'max' => 10 )
			expect( settings['$tDiary.plugin.draft.interval'] ).to eq 300
		end

		it "keeps a draft from closing the script element" do
			storage.set( 'drafts', [draft( 'a1', 1, '</script><script>alert(1)' )].to_json )

			server = js_settings( draft_plugin( 'edit' ) )['$tDiary.plugin.draft.server']

			expect( server ).not_to include '<'
			expect( JSON.parse( server )['drafts'][0]['value'] ).to eq '</script><script>alert(1)'
		end

		it "takes the upload interval from the option" do
			conf['draft.sync_interval'] = 600

			expect( js_settings( draft_plugin( 'form' ) )['$tDiary.plugin.draft.interval'] ).to eq 600
		end
	end

	describe "when the browser uploads drafts" do
		def upload( items )
			draft_plugin( 'formplugin', 'plugin_draft_sync' => items.to_json )
		end

		it "stores a new draft" do
			upload( [draft( 'a1', 1 )] )

			expect( stored( 'drafts' ) ).to eq [draft( 'a1', 1 )]
		end

		it "replaces a draft only with a newer version" do
			upload( [draft( 'a1', 2, 'new' )] )
			upload( [draft( 'a1', 1, 'old' )] )

			expect( stored( 'drafts' ) ).to eq [draft( 'a1', 2, 'new' )]
		end

		it "does not bring back a draft submitted as a diary" do
			storage.set( 'deleted', ['a1'].to_json )

			upload( [draft( 'a1', 1 )] )

			expect( stored( 'drafts' ) ).to eq []
		end

		it "rejects malformed drafts" do
			upload( [draft( 'A!', 1 ), draft( 'a1', '1' ), draft( 'b2', 1, '' ), 'c3'] )

			expect( stored( 'drafts' ) ).to eq []
		end

		it "keeps the newest drafts only" do
			upload( (1..12).map {|i| draft( "a#{i}", i ) } )

			expect( stored( 'drafts' ).map {|d| d['id'] } ).to eq (3..12).map {|i| "a#{i}" }
		end

		it "ignores a broken payload" do
			draft_plugin( 'formplugin', 'plugin_draft_sync' => '[{' )

			expect( storage.get( 'drafts' ) ).to be_nil
		end
	end

	describe "when a diary is submitted" do
		before do
			storage.set( 'drafts', [draft( 'a1', 1 ), draft( 'b2', 2 )].to_json )
		end

		it "deletes the submitted draft and remembers it" do
			draft_plugin( 'append', 'plugin_draft_id' => 'a1' ).instance_eval { update_proc }

			expect( stored( 'drafts' ) ).to eq [draft( 'b2', 2 )]
			expect( stored( 'deleted' ) ).to eq ['a1']
		end

		it "leaves the drafts alone when a comment is posted" do
			draft_plugin( 'comment', 'plugin_draft_id' => 'a1' ).instance_eval { update_proc }

			expect( stored( 'drafts' ).size ).to eq 2
			expect( storage.get( 'deleted' ) ).to be_nil
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
