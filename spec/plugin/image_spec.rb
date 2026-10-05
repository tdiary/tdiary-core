require File.expand_path('../plugin_helper', __FILE__)
require 'tmpdir'

describe "image plugin" do
	let(:gif) { "GIF89a\x01\x00\x01\x00\x80\x00\x00\x00\x00\x00\xff\xff\xff,\x00\x00\x00\x00\x01\x00\x01\x00\x00\x02\x02D\x01\x00;".b }

	around do |example|
		Dir.mktmpdir {|dir| @image_dir = dir; example.run }
	end

	let(:conf) {
		PluginFake::Config.new.tap {|conf|
			conf.plugin_path = "spec/fixtures/plugin"
			conf.lang = "ja"
			conf.options['image.dir'] = @image_dir
			conf.options['image.url'] = 'http://example.com/images'
		}
	}

	def image_plugin( mode, params = {} )
		cgi = Struct.new(:params).new( Hash.new( [] ).merge( params ) )
		TDiary::Plugin.new( conf: conf, mode: mode, cgi: cgi, date: Time.local( 2026, 10, 5 ) ).tap {|plugin|
			plugin.load_plugin( "misc/plugin/image.rb" )
		}
	end

	it "stores every file posted at once under its own number" do
		File.binwrite( File.join( @image_dir, '20261005_0.gif' ), gif )

		image_plugin( 'formplugin',
			'plugin_image_addimage' => ['true'],
			'plugin_image_file' => [StringIO.new( gif ), StringIO.new( gif )] )

		expect( Dir.children( @image_dir ).sort ).to eq %w(20261005_0.gif 20261005_1.gif 20261005_2.gif)
	end

	it "marks the images just uploaded in the form" do
		File.binwrite( File.join( @image_dir, '20261005_0.gif' ), gif )

		plugin = image_plugin( 'formplugin',
			'plugin_image_addimage' => ['true'],
			'plugin_image_file' => [StringIO.new( gif )] )
		plugin.instance_eval { def csrf_protection; ''; end }
		form = plugin.instance_eval { form_proc( Time.local( 2026, 10, 5 ) ) }

		expect( form ).to include '<img id="image-index-1" class="image-img form" data-added="true"'
		expect( form ).to include '<img id="image-index-0" class="image-img form" src='
	end

	it "lets the preview page upload images of the day" do
		settings = image_plugin( 'preview' ).instance_variable_get( :@javascript_setting ).to_h
		expect( settings['$tDiary.plugin.image.date'] ).to eq "'20261005'"
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
