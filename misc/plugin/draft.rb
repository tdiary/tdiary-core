#
# draft.rb: save draft data to Web Storage automatically
#           and keep a copy of them on the server
#
# options:
#   @options['draft.sync_interval'] : seconds between uploads to the server (default 300)
#
# Copyright (c) MATSUOKA Kohei <http://www.machu.jp/>
# Distributed under the GPL2 or any later version.
#
require 'json'

def draft_max_count
	10
end

def draft_restore( db )
	%w(drafts deleted).map {|key| JSON.parse( db.get( key ) || '[]' ) }
end

def draft_id?( id )
	id.kind_of?( String ) and /\A[0-9a-z]{1,32}\z/.match?( id )
end

def draft_valid?( item )
	item.kind_of?( Hash ) and
		draft_id?( item['id'] ) and
		item['date'].kind_of?( Integer ) and
		item['value'].kind_of?( String ) and !item['value'].empty?
end

def draft_sync( items )
	transaction( 'draft' ) do |db|
		drafts, deleted = draft_restore( db )
		items.each do |item|
			# a draft submitted as a diary must not come back from another browser
			next if !draft_valid?( item ) or deleted.include?( item['id'] )
			stored = drafts.find {|d| d['id'] == item['id'] }
			if !stored
				drafts << item.slice( 'id', 'date', 'value' )
			elsif stored['date'] < item['date']
				stored.update( item.slice( 'date', 'value' ) )
			end
		end
		db.set( 'drafts', drafts.sort_by {|d| d['date'] }.last( draft_max_count ).to_json )
	end
end

def draft_delete( id )
	transaction( 'draft' ) do |db|
		drafts, deleted = draft_restore( db )
		db.set( 'drafts', drafts.reject {|d| d['id'] == id }.to_json )
		db.set( 'deleted', (deleted - [id] + [id]).last( 100 ).to_json )
	end
end

if /\A(form|edit|preview|showcomment)\z/ === @mode then
	enable_js('draft.js')
	server = nil
	transaction( 'draft' ) do |db|
		drafts, deleted = draft_restore( db )
		server = { 'drafts' => drafts, 'deleted' => deleted, 'max' => draft_max_count }
	end
	add_js_setting( '$tDiary.plugin.draft' )
	# keep the drafts from closing the script element
	add_js_setting( '$tDiary.plugin.draft.server', server.to_json.gsub( '<', '\\u003c' ) )
	add_js_setting( '$tDiary.plugin.draft.interval', (@conf['draft.sync_interval'] || 300).to_i )
end

if @mode == 'formplugin' and @cgi.params['plugin_draft_sync'][0] then
	begin
		items = JSON.parse( @cgi.params['plugin_draft_sync'][0] )
		draft_sync( items ) if items.kind_of?( Array )
	rescue JSON::ParserError
	end
end

add_update_proc do
	id = @cgi.params['plugin_draft_id'][0]
	if /\A(append|replace)\z/ =~ @mode and draft_id?( id ) then
		draft_delete( id )
	end
end

add_edit_proc do
	<<-EOS
	<div class="draft">
		下書き:
		<select name="drafts"></select>
		<button type="button" id="draft_load">読み込み</button>
		<input type="hidden" name="plugin_draft_id" value="">
	</div>
	EOS
end
