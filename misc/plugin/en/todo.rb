# en/todo.rb
#
# English resources for todo.rb
#
# Copyright (c) 2001,2002,2003 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL2 or any later version.
#

def todo_msg_today; "today"; end
def todo_msg_in_time(days); "#{days} day(s) left to go"; end
def todo_msg_late(days); "#{days} day(s) delay"; end
def todo_config_label; "Edit ToDo"; end

add_conf_proc('ToDo', 'ToDo plugin') do
	saveconf_todo
	todo_init

	<<-HTML
	<h3 class="subtitle">How to use</h3>
	<p>put '&lt;%=todo%&gt;' in the <a href="#{h @update}?conf=header">Header/Footer</a>.</p>
	<h3 class="subtitle">Edit ToDo</h3>
	<p>Each line has one ToDo entry, which is in the form of:</p>
	<pre>priority[deadline] what to do</pre>
	<p>'priority' and 'what to do' is separated by a apace character.</p>
	<p>Priority is optional.  If you specify priority, put an integer between 1 and 99, otherwise the entry is ignored.</p>
	<p>Deadline is optional.  If you specify deadline, put '[' and ']' around deadline.  Deadline is parsed by <a href="http://www.ruby-lang.org/ja/man-1.6/?cmd=view;name=ParseDate">ParseDate module</a></p>
	<p><textarea name="todo.todos" cols="70" rows="15">#{h @todos.join("\n")}</textarea></p>

	<h3 class="subtitle">Title for ToDo</h3>
	<p><input name="todo.title" value="#{h(@conf['todo.title']) if @conf['todo.title']}"></p>

	<h3 class="subtitle">Max number of ToDo entries to be displayed</h3>
	<p><input name="todo.n" value="#{h @conf['todo.n']}" size="3"> entries</p>
	HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
