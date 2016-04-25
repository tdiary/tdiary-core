# ping.rb Japanese resources
if /conf/ =~ @mode then
	@ping_label_conf = '更新通知'
	@ping_label_list = '通知先リスト'
	@ping_label_list_desc = '更新通知をするpingサービスのURLを、1行につき1つ入力してください。なお、あまりたくさん指定すると、途中でタイムアウトしてしまうかも知れません'
	@ping_label_timeout = 'タイムアウト(秒)'
end

@ping_label_send = '更新情報を送る'

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
