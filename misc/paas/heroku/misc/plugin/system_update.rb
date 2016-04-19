#
# system update plugin: automatic update tDiary usging GitHub and Heroku
#
# Copyright (C) 2015 by TADA Tadashi <t@tdtds.jp>
# You can redistribute it and/or modify it under GPL2 or any later version.
#

def system_update
	token = @conf['system_update.token'] || ''
	user  = @conf['system_update.user'] || ''
	raise StandardError.new('no token or user') if token.empty? || user.empty?

	begin
		@logger.info 'starting syatem update...'
		client = Octokit::Client.new(access_token: token)
		title = "system update on #{Time.now}"
		body = 'update by system_update plugin'
		pull_request = client.create_pull_request("#{user}/tdiary-core", 'master', 'tdiary:master', title, body)
		client.merge_pull_request("#{user}/tdiary-core", pull_request[:number])
		@logger.info 'syatem update finished'
	rescue Octokit::UnprocessableEntity
		@logger.info(@error = 'no commits in upstream')
	end
end

add_conf_proc('system_update', 'システム更新', 'basic') do
	if @mode == 'saveconf' then
		@conf['system_update.token'] = @cgi.params['system_update.token'][0]
		@conf['system_update.user']  = @cgi.params['system_update.user'][0]

		begin
			system_update if @cgi.valid?('system_update.run')
		rescue
			@logger.error(@error = $!.message)
		end
	end

	r = <<-HTML
		<h3 class="subtitle">tDiaryシステムの更新</h3>
		<p>GitHubとHerokuの連携機能を使って、tDaiaryシステムの更新を行います。あらかじめ<a href="https://github.com/tdiary/tdiary-core">tDiaryの公式リポジトリ</a>を自分のアカウントにforkし、そのリポジトリをHerokuのGitHub Deployに指定しておく必要があります。更新はmasterブランチを使って行われます。</p>
		<p>GitHub access token (40文字): <input type="text" id="system_update.token" name="system_update.token" size="40" value="#{h @conf['system_update.token']}"></p>
		<p>GitHub user name: <input type="text" id="system_update.user" name="system_update.user" size="20" value="#{h @conf['system_update.user']}"></p>
		<hr>
		<p><label for="system_update.run">
			<input type="checkbox" id="system_update.run" name="system_update.run" value="1">システムを更新する</input> <strong>#{h @error}</strong>
		</label></p>
	HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
