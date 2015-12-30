require 'omniauth'
require 'tdiary/rack/auth/omniauth/authorization'

class TDiary::Rack::Auth::OmniAuth
	class NoStrategyFoundError < StandardError; end
	@provider_procs = {}

	class << self
		attr_reader :provider_procs
	end

	def self.add_provider(name, &block)
		@provider_procs[name] = block
	end

	def initialize(app)
		provider = enabled_providers.first
		unless provider
			raise NoStrategyFoundError.new("Not found any strategies. Write the omniauth strategy in your Gemfile.local.")
		end

		@app = ::Rack::Builder.new(app) {
			use TDiary::Rack::Session
		}.tap {|builder|
			builder.instance_eval(&self.class.provider_procs[provider])
		}.to_app
	end

	def call(env)
		@app.call(env)
	end

	add_provider(:Twitter) do
		# https://apps.twitter.com/
		# https://github.com/arunagw/omniauth-twitter
		use ::OmniAuth::Builder do
			provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
		end
		use TDiary::Rack::Auth::OmniAuth::Authorization, :twitter do |auth|
			ENV['TWITTER_NAME'].split(/,/).include?(auth.info.nickname)
		end
	end

	add_provider(:Facebook) do
		# https://developers.facebook.com/apps/
		# https://github.com/mkdynamic/omniauth-facebook
		use ::OmniAuth::Builder do
			provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']
		end
		use TDiary::Rack::Auth::OmniAuth::Authorization, :facebook do |auth|
			ENV['FACEBOOK_EMAIL'].split(/,/).include?(auth.info.email)
		end
	end

	add_provider(:GitHub) do
		# https://github.com/settings/applications
		# https://github.com/intridea/omniauth-github
		use ::OmniAuth::Builder do
			provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
		end
		use TDiary::Rack::Auth::OmniAuth::Authorization, :github do |auth|
			ENV['GITHUB_NAME'].split(/,/).include?(auth.info.nickname)
		end
	end

	add_provider(:GoogleOauth2) do
		# https://code.google.com/apis/console/
		# https://github.com/zquestz/omniauth-google-oauth2
		use ::OmniAuth::Builder do
			provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"]
		end
		use TDiary::Rack::Auth::OmniAuth::Authorization, :google_oauth2 do |auth|
			ENV['GOOGLE_EMAIL'].split(/,/).include?(auth.info.email)
		end
	end

private

	def enabled_providers
		::OmniAuth::Strategies.constants.select do |name|
			self.class.provider_procs.has_key?(name)
		end
	end
end
