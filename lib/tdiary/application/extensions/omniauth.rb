# -*- coding: utf-8 -*-
require 'tdiary/application'
begin
	require 'rack/session/dalli'
rescue LoadError
end

TDiary::Application.configure do
	config.builder do
		if ::Rack::Session.const_defined? :Dalli
			use ::Rack::Session::Dalli, cache: Dalli::Client.new, expire_after: 2592000
		else
			use ::Rack::Session::Pool, expire_after: 2592000
		end
		use OmniAuth::Builder do
			configure {|conf| conf.path_prefix = "/auth" }
			provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
		end

		map('/auth') do
			run TDiary::Rack::Auth::OmniAuth::CallbackHandler.new
		end
	end

	config.authenticate TDiary::Rack::Auth::OmniAuth, :twitter do |auth|
		# TODO: an user can setting
		auth.info.nickname == ENV['TWITTER_NAME']
	end
end
