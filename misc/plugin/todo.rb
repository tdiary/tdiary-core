# -*- coding: utf-8 -*-
# todo.rb
#
# todo: show ToDo lists.
#
# CSS samples for ToDo:
#
#  div.todo {
#  	font-size: 80%;
#  }
#
#  div.todo-title {
#  	font-weight: bold;
#  }
#
#  div.todo-body {
#  }
#
#  span.todo-priority {
#  	font-weight: bold;
#  }
#
#  span.todo-in-time {
#  }
#
#  span.todo-today {
#  	color: blue;
#  }
#
#  span.todo-too-late {
#  	color: red;
#  	font-weight: bold;
#  }
#
# Copyright (c) 2001,2002,2003 Junichiro KITA <kita@kitaj.no-ip.com>
# Distributed under the GPL
#

require 'fileutils'
require 'time'
class ToDo
	attr_reader :prio, :todo, :limit
	def initialize(prio, todo, limit, deleted = nil)
		@prio, @todo, @limit, @deleted = prio, todo, limit, deleted
	end

	def deleted?
		@deleted != ""
	end

	def <=>(other)
		other.prio.to_i <=> @prio.to_i
	end

	def to_s
		r = "#{@deleted}#{@prio}"
		r << "[#{@limit}]" if @limit
		r << " #{@todo}"
		r.sub!(/^\s+/, '')
		r
	end
end

def todo_parse(src)
	todos = []
	src.each do |l|
		deleted, prio, limit, todo = l.scan(/^(#?)(\d{0,2})(?:\[(.*)\])? *(.+)$/)[0]
		if (0..99).include? prio.to_i and todo
			todos.push ToDo.new(prio, todo, limit, deleted)
		end
	end
	if todos.size > 0
		todos.sort!
	end
	todos
end

def todo_pretty_print(todos)
	s = ''
	s << %Q|<ul>\n|
	now = Time.now
	today = Time.local(now.year, now.month, now.day)
	todos.each_with_index do |x, idx|
		break if idx >= @conf['todo.n']
		s << "<li>"
		s << %Q|<del>| if x.deleted?
		s << %Q|<span class="todo-priority">#{if x.prio != '' then '%02d' % x.prio else '' end}</span> #{apply_plugin x.todo}|
		if x.limit
			s << "(~#{x.limit}"
			ymd = Time.parse(x.limit)
			y = ymd.year
			m = ymd.month
			d = ymd.day
			y = today.year unless y
			if y and m and d
				limit = Time.local(y, m, d)
				diff = ((limit - today)/86400).to_i
				if diff > 0
					s << %Q| <span class="todo-in-time">#{todo_msg_in_time(diff)}</span>|
				elsif diff == 0
					s << %Q| <span class="todo-today">#{todo_msg_today}</span>|
				else
					s << %Q| <span class="todo-too-late">#{todo_msg_late(diff.abs)}</span>|
				end
			end
			s << ")"
		end
		s << %Q|</del>| if x.deleted?
		s << "</li>\n"
	end
	s << %Q|</ul>\n|
end

@todos = []  # parsed todos. generated from @conf['todo.todos'].

def todo_init
	@conf['todo.n'] ||= 10
	@conf['todo.title'] ||= 'ToDo:'
	unless @conf['todo.todos']
		begin
			@conf['todo.todos'] = File.readlines(todo_file).join if FileTest::exist?(todo_file)
		rescue
		end
	end
	@conf['todo.todos'] ||= ''
	@todos = todo_parse(@conf['todo.todos'].split(/\n/))
end

def todo
	todo_init
	<<TODO
<div class="todo">
	<div class="todo-title">
		<p>#{@conf['todo.title']}</p>
	</div>
	<div class="todo-body">
#{todo_pretty_print(@todos)}
	</div>
</div>
TODO
end

def navi_t(name = todo_config_label)
	%Q|<span class="adminmenu"><a href="#{h @update}?conf=ToDo">#{name}</a></span>\n|
end

# backward compatibility
def todo_file
	if File.exist?( "#{@cache_path}/todo" ) then
		FileUtils.mv( "#{@cache_path}/todo", "#{@conf.data_path}/todo")
	end
	(@options && @options['todo.path'] || @conf.data_path) + "/todo"
end

#
# for conf_proc
#
def config_options2(op2_key)
	op2_val = @cgi.params[op2_key][0]
	if (0 < op2_val.size)
		@conf[op2_key] = (block_given? ? yield(op2_val) : op2_val)
	else
		@conf.delete(op2_key)
	end
end
private :config_options2

def saveconf_todo
	if @mode == 'saveconf' then
		config_options2('todo.todos')
		config_options2('todo.title')
		config_options2('todo.n'){|op2_val| op2_val.to_i}
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
