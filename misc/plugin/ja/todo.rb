# ja/todo.rb
#
# Japanese resources for todo.rb
#
# Copyright (c) 2001,2002,2003 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL2 or any later version.
#

def todo_msg_today; "今日"; end
def todo_msg_in_time(days); "あと#{days}日"; end
def todo_msg_late(days); "#{days}日遅れ"; end
def todo_config_label; "ToDo編集"; end

add_conf_proc('ToDo', 'ToDoプラグイン') do
	saveconf_todo
	todo_init

	<<-HTML
	<h3 class="subtitle">使い方</h3>
	<p><a href="#{h @update}?conf=header">ヘッダ・フッタ</a>に'&lt;%=todo%&gt;'を追加して下さい．</p>
	<h3 class="subtitle">ToDo編集</h3>
	<p>一行に一つずつToDoを記述します．ToDoの形式は</p>
	<pre>優先度[期限] すること</pre>
	<p>です．「優先度」と「すること」の間は1つ以上のスペースで区切ります．</p>
	<p>優先度は省略可能です。優先度を指定する場合は1〜99の整数を指定します．それ以外の優先度を指定した場合，そのToDoは無視されます．</p>
	<p>期限は省略可能です．期限を指定する場合は'['と']'で囲むようにしてください．期限で指定した文字列をrubyの<a href="http://www.ruby-lang.org/ja/man-1.6/?cmd=view;name=ParseDate">ParseDateモジュール</a>で解析できれば，期限までの日数もあわせて表示します．</p>
	<p><textarea name="todo.todos" cols="70" rows="15">#{@todos.join("\n")}</textarea></p>

	<h3 class="subtitle">ToDoリストのタイトル</h3>
	<p>ToDoリストのタイトルを指定します。何も指定しないと、&quot;ToDo:&quot;が利用されます。</p>
	<p><input name="todo.title" value="#{h(@conf['todo.title']) if @conf['todo.title']}"></p>

	<h3 class="subtitle">表示するToDoの件数</h3>
	<p>表示するToDoの件数を表示します。何も指定しないと、10件が設定されます。</p>
	<p>最大<input name="todo.n" value="#{h @conf['todo.n']}" size="3">件</p>
	HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
