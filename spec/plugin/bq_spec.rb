# -*- coding: utf-8 -*-
require File.expand_path('../plugin_helper', __FILE__)

describe "bq plugin w/" do
	def setup_bq_plugin( mode )
		fake_plugin(:bq) { |plugin|
			plugin.mode = mode
		}
	end

	describe "src only." do
		before do
			plugin = setup_bq_plugin('lateste')
			@body_snippet = plugin.bq('foo')
		end

		it { expect(@body_snippet).to eq(expected_html_body(
				:src => 'foo')) }
	end

	def expected_html_body(options)
		expected = %|<blockquote>\n<p>#{options[:src]}</p>\n</blockquote>\n|
	end
end
