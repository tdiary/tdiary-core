# -*- coding: utf-8 -*-
# counter.rb
#
# Access counter plugin.
#
# 1. Usage
# counter(figure, filetype = ""): Show number of all visitors.
# counter_today(figure, filetype = ""): Show number of visitors for today.
# counter_today(figure, filetype = ""): Show number of visitors for yesterday.
#	 filetype: jpg, gif, png ... .
#
# kiriban?: Return true when the number is a kiriban.
# kiriban_today?: Return true when the number is a kiriban(for today's couner).
#
# counter
# counter 3
# coutner 3, "jpg"
# counter_today 4, "jpg"
# counter_yesterday
#
# 2. Documents
# See URLs below for more details.
#   http://ponx.s5.xrea.com/hiki/counter.rb.html (English)
#   http://ponx.s5.xrea.com/hiki/ja/counter.rb.html (Japanese)
#
# Copyright (c) 2002-2006 Masao Mutoh
# You can redistribute it and/or modify it under GPL2.
#
=begin ChangeLog
2006-02-14 Masao Mutoh
   * Add some user-agents.
   * 2.0.2

2006-02-14 mitty
   * Fixed a problem when counter2_access.dat is broken.

2006-02-07 Masao Mutoh
   * Revert the log file name from counter2.log to counter.log.
     Reported by Ken-ichi Mito.
   * 2.0.1

2006-01-20 Masao Mutoh
   * Improves the speed and stability.
     - Separate data to counterdata and accessdata.
     - counterdata is the target of backup, but accessdata doesn't do backup.
     - change a key of an Array of String to a hash.
     - Removed "counter.daily_backup" option. Now daily_backup is applied
       everyday unless this setting.
     - Add a new "counter.max_keep_access_num" option which you can set the max
       number to keep users in the accessdata file to avoid to become
       too large the accessdata file.
   * Follow tDiary framework.
     - Add configuration page.
   * Misc
     - Removed "counter.deny_remote_addrs" option.

2004-10-01 Masao Mutoh
   * Improved process against bots. @options["bot"] is now supported.

2003-11-15 Masao Mutoh
   * translate documents to English.

2003-02-15 Masao Mutoh
   * counter.datが大きくなる不具合の修正
   * version 1.6.3

2002-11-26 Junichiro Kita <kita@kitaj.no-ip.com>
   * remove 'cgi.cookies = nil' in TDiaryCounter::main

2002-11-19 TADA Tadashi <sho@spc.gr.jp>
   * for squeeze.rb error more.
   * version 1.6.2

2002-11-13 TADA Tadashi <sho@spc.gr.jp>
   * for squeeze.rb error.

2002-10-12 Masao Mutoh
   * 初めて使うときに動作しなくなっていた不具合の修正。
   * 1日1回保持しているユーザ情報をクリーンアップするようにした。
   * version 1.6.1

2002-08-30 Masao Mutoh
   * データファイルが読み込めなくなったとき、1つ前のバックアップデータ
     を用いて復旧するようにした(その際に、1つ前のバックアップデータは
     counter.dat.?.bakという名前でバックアップされる)。さらに1つ前の
     バックアップデータからも復旧できなかった場合は全てのカウンタ値を
     0にしてエラー画面が表示されないようにした。
   * version 1.6.0

2002-07-23 Masao Mutoh
   * バックアップファイルのファイル名のsuffixを曜日(0-6の数値)にした。
      従って、1週間毎に古いファイルは上書きされるのでファイルの数は
      最大7つとなる。数字が新しいものが最新というわけではないので注意。
      (proposed by Junichiro KITA <kita@kitaj.no-ip.com>)
   * version 1.5.1

2002-07-19 Masao Mutoh
   * 日々単位でデータをバックアップするようにした。
     @options["counter.dairy_backup"]で指定。falseを指定しない限り
     バックアップする。
   * Date#==メソッドでnilを渡さないように修正
   * require 'pstore'追加(tDiary version 1.5.x系対応)
   * logのフォーマット変更(全て・今日・昨日のデータを出力)
   * @options["counter.deny_same_src_interval"]のデフォルト値を2時間
     に変更した。
   * version 1.5.0

2002-05-19 Masao Mutoh
   * Cookieを使うことのできない同一クライアントからの連続アクセスを、
     カウントアップしないようにした。
   * @options["counter.deny_same_src_interval"]追加。連続GETの間隔を指定。
     デフォルトで0.1時間(6分)。
   * version 1.4.0

2002-05-11 Masao Mutoh
   * 初期値を与えない場合は5桁としていたが、「前0をなくす」に変更した。
     また、前0を無くす場合は0を指定しても良い。
   * version 1.3.0

2002-05-05 Masao Mutoh
   * @debug = true 削除 :->
   * コメント変更
   * version 1.2.1

2002-05-04 Masao Mutoh
   * tlinkプラグインからのアクセスをカウントしてしまう不具合の修正
   * @options["counter.deny_user_agents"]追加
   * @options["counter.deny_remote_addrs"]追加
   * @options["counter.init_num"]追加。キリ番機能との関係で、counter
   * メソッドの引数のinit_numはobsoleteとします。
   * @options["counter.kiriban"], @options["counter.kiriban_today"]追加
   * キリ番機能追加(kiriban?,kiriban_today?メソッド追加)
   * version 1.2.0

2002-04-27 Masao Mutoh
   * add_header_procを使わないようにした
   * @options["counter.timer"]が有効にならない不具合の修正
   * @options["counter.log"]追加。trueを指定するとcounter.dat
      と同じディレクトリにcounter.logというファイルを作成し
      1日前のアクセス数を記録するようにした
   * cookieの値としてバージョン番号を入れるようにした
   * version 1.1.0

2002-04-25 Masao Mutoh
   * HEADでアクセスがあった場合に再びカウントされるように
      なってしまっていた不具合の修正(by NT<nt@24i.net>)
   * version 1.0.4

2002-04-24 Masao Mutoh
   * ツッコミを入れたときにエラーが発生する不具合の修正
   * version 1.0.3

2002-04-23 Masao Mutoh
   * データファイルを削除後、クッキーが有効期間中の端末から
      アクセスした場合に@todayが0になる不具合の修正
   * コメント入れたときに数字が表示されない不具合の修正
   * HEADでアクセスがあった場合はカウントしないようにした
      (reported by NT<nt@24i.net>, suggested a solution
         by TADA Tadashi <sho@spc.gr.jp>)
   * version 1.0.2

2002-04-21 Masao Mutoh
   * CSSで_を使っているところを-に直した(reported by NT<nt@24i.net>)
   * TDiaryCountData#upで@allが+1されない不具合の修正
   * version 1.0.1

2002-04-14 Masao Mutoh
   * version 1.0.0
=end

@counter_default_user_agents = "feed|tlink|WWWOFFLE|^WWWC|^Wget|WWWD|fetch|Antenna|antenna|Infoseek SideWinderBlogRanking|^ichiro|CaptainNAMAAN|Download Ninja|ping.blogger.jp|ia_archiver|Nutch|^Mediapartners.Google|lwp.trivial|nomadscafe_ra|rawler|KMHTTP|Tarantula|Pockey|Microsoft URL Control|Livedoor SF|^Blogline|Yahoo|^Y.J|Ask Jeeves|^Commerobo|^livedoorCheckers|^voyager|^findlinks|^\-$|FunWebProducts|^Headline|lmspider|^FreshReader|^FyberSpider|^Hatena|^intraVnews|^Nandemorss|^Nutch|^1.0$|^Blogshares|Crawl|MSNPTC|MS Search|^Pompos|^Portsurvey|^RSS_READER|^gooRSSreader|^kinja|^larbin|^research\-spider|bot|^HTTP$|SBIder|StackRambler|Wavefire|samidare|MarkAgent|^Java|NewsWire|libwww|ping.blo.gs|wish.lim|Mozilla.4.76|rAntenna|PEAR|Blogslive|edgeio.retriever|^Jakarta"

#not bot: RssBar, AppleSyndication

def counter_allow?
	return false if bot?
	if @options
		if @options["counter.deny_user_agents"]
			if @options["counter.deny_user_agents"].kind_of? Array
				@options["counter.deny_user_agents"] = @options["counter.deny_user_agents"].uniq.join('|')
			elsif @options["counter.deny_user_agents"].size > 1
				agents = Regexp.new("(#{@counter_default_user_agents}|#{@options["counter.deny_user_agents"]})", true)
			else
				agents = Regexp.new("(#{@counter_default_user_agents})", true)
			end
		else
			agents = Regexp.new("(#{@counter_default_user_agents})", true)
		end
		return false if agents =~ @cgi.user_agent
	end
	true
end

if @cgi.request_method == 'GET' and counter_allow?
	require 'date'
	require 'pstore'
	require 'fileutils'

eval(<<TOPLEVEL_CLASS, TOPLEVEL_BINDING)
	class TDiaryAccessData
		attr_accessor :ignore_cookie #means ALWAYS ignore a cookie.
		def previous_access_time(time, remote_addr, user_agent, interval, maxaccessnum)
			@time = time
			@users = Hash.new unless @users
			key = (remote_addr + user_agent).hash
			ret = @users[key]
			remove_olddata(interval)

			@users[key] = @time if @users.size < maxaccessnum
			ret
		end

		def remove_olddata(interval)
			@users.reject!{|key, val|
				@time - val > interval * 3600
			}
		end
	end
	class TDiaryCountData
		attr_reader :today, :yesterday, :all, :newestday

		def initialize(path, all = 0, today = 0, yesterday = 0)
			@path = path
			@newestday = Date.today
			@all, @today, @yesterday = all, today, yesterday
		end

		def up(now, cache_path, cgi, _log)
			if @newestday
				if now == @newestday
					@today += 1
				else
					log if _log
					@yesterday = ((now - 1) == @newestday) ? @today : 0
					@today = 1
					@newestday = now
					time = Time.now
				end
			else
				@yesterday = 0
				@today = 1
				@newestday = now
			end
			@all += 1
			save
		end

		def load
			begin
				open(File.join(@path, "counter2.dat"), "r") do |io|
					eval(io.read)
				end
			rescue Exception
				back = (Dir.glob(File.join(@path, "counter2.dat.?")).sort{|a,b|
						File.mtime(a) <=> File.mtime(b)}.reverse)[0]
				open(back, "r") do |io|
					begin
						eval(io.read)
					rescue Exception
					end
				end
				save
			end
			self
		end

		def save(file = "counter2.dat")
			open(File.join(@path, file), "w") do |io|
				io.print "@newestday = Date.parse('" + @newestday.to_s + "'); "
				io.print "@all = " + @all.to_s + "; "
				io.print "@today = " + @today.to_s + "; "
				io.print "@yesterday = " + @yesterday.to_s
			end
		end

		def log
			if @newestday
				open(File.join(@path, "counter.log"), "a") do |io|
					io.print @newestday, " : ", @all, ",", @today, ",", @yesterday, "\n"
				end
				save("counter2.dat." + @newestday.wday.to_s)
			end
		end
	end
TOPLEVEL_CLASS

	module TDiaryCounter
		extend ERB::Util
		@version = "2.0.2"

		def run(cache_path, cgi, options)
			timer = options["counter.timer"] if options
			timer = 12 unless timer	# 12 hour
			@init_num = options["counter.init_num"] if options
			@init_num = 0 unless @init_num
			dir = File.join(cache_path, "counter")
			path = File.join(dir, "counter2_access.dat")
			today = Date.today
			Dir.mkdir(dir, 0700) unless FileTest.exist?(dir)

			cookie = nil
			begin
				cookie = main(cache_path, cgi, options, timer, dir, path, today)
			rescue => e
				@cnt = TDiaryCountData.new(dir).load
				if e.message =~ /marshal|dump|load|referred|depth|io needed|size/i
					begin
						File.unlink path
					rescue
					end
				end
			end
			cookie
		end

		def main(cache_path, cgi, options, timer, dir, path, today)
			cookie = nil
			if FileTest.exist?(File.join(dir, "counter.dat"))
				db = PStore.new(File.join(dir, "counter.dat"))
				db.transaction do
					old = db["countdata"]
					TDiaryCountData.new(dir, old.all, old.today, old.yesterday).save
				end
				FileUtils.mv(File.join(dir, "counter.dat"), File.join(dir, "counter.dat.old"))
			end
			db = PStore.new(path)
			db.transaction do
				begin
					@access = db["accessdata"]
				rescue PStore::Error
				end
				unless @access
					@access = TDiaryAccessData.new
				end

				begin
					@cnt = TDiaryCountData.new(dir).load
				rescue Exception
					@cnt = TDiaryCountData.new(dir)
				end

				changed = false
				if new_user?(cgi, options)
					@cnt.up(today, dir, cgi, (options and options["counter.log"]))
					cookie = CGI::Cookie.new({"name" => "tdiary_counter",
							"value" => @version,
							"expires" => Time.now + timer * 3600})
					changed = true
				end

				if options["counter.kiriban"]
					if options["counter.kiriban"].kind_of? String
						if options["counter.kiriban"] == ""
							options["counter.kiriban"] = [-1]
						elsif options["counter.kiriban"].include?(",")
							options["counter.kiriban"] =
								options["counter.kiriban"].split(",").collect{|i| i.to_i}
						else
							options["counter.kiriban"] = [options["counter.kiriban"].to_i]
						end
					end
					@kiriban = options["counter.kiriban"].include?(@cnt.all + @init_num)
				end

				if ! @kiriban and options["counter.kiriban_today"]
					if options["counter.kiriban_today"].kind_of? String
						if options["counter.kiriban_today"] == ""
							options["counter.kiriban_today"] = [-1]
						elsif options["counter.kiriban_today"].include?(",")
							options["counter.kiriban_today"] =
								options["counter.kiriban_today"].split(",").collect{|i| i.to_i}
						else
							options["counter.kiriban_today"] = [options["counter.kiriban_today"].to_i]
						end
					end
					@kiriban_today = options["counter.kiriban_today"].include?(@cnt.today)
				end

				if @access.ignore_cookie
					@access.ignore_cookie = false
					changed = true
				end

				#when it is kiriban time, ignore the cookie next access time.
				if @kiriban or @kiriban_today
					@access.ignore_cookie = true
					changed = true
				end

				if changed
					db["accessdata"] = @access
				end
			end
			cookie
		end

		def new_user_without_cookie?(cgi, options)
			if options
				interval = options["counter.deny_same_src_interval"]
				maxaccessnum = options["counter.max_keep_access_num"]
			end
			interval = 2 unless interval	         # 2 hour.
			maxaccessnum = 10000 unless maxaccessnum # 2 hour.
			current_time = Time.now
			previous_access_time = @access.previous_access_time(current_time, cgi.remote_addr,
				cgi.user_agent, interval, maxaccessnum)
			if previous_access_time
				ret = current_time - previous_access_time > interval * 3600
			else
				ret = true
			end
			ret
		end

		def new_user?(cgi, options)
			return true if @access.ignore_cookie
			if cgi.cookies
				if cgi.cookies.keys.include?("tdiary_counter")
					ret = false
				else
					ret = new_user_without_cookie?(cgi, options)
				end
			else
				ret = new_user_without_cookie?(cgi, options)
			end
			ret
		end

		def format(classtype, theme_url, cnt, figure = 0, filetype = "", init_num = 0, &proc)
			str = "%0#{figure}d" % (cnt + init_num)
			result = %Q[<span class="counter#{classtype}">]
			depth = 0
			str.scan(/./).each do |num|
				if block_given?
					result << %Q[<img src="#{h theme_url}/#{yield(num)}" alt="#{num}" />]
				elsif filetype == ""
					result << %Q[<span class="counter-#{depth}"><span class="counter-num-#{num}">#{num}</span></span>]
				else
					result << %Q[<img src="#{h theme_url}/#{num}.#{filetype}" alt="#{num}" />]
				end
				depth += 1
			end
			result << "</span>"
		end

		def called?; @called; end
		def called; @called = true; end
		def all; @cnt.all + @init_num; end
		def today; @cnt.today; end
		def yesterday; @cnt.yesterday; end
		def kiriban?; @kiriban; end
		def kiriban_today?; @kiriban_today; end

		module_function :new_user?, :new_user_without_cookie?, :all, :today, :yesterday, :format,
      :main, :run, :kiriban?, :kiriban_today?
	end

	#init_num is deprecated.
	#please replace it to @options["counter.init_num"]
	def counter(figure = 0, filetype = "", init_num = 0, &proc)
		TDiaryCounter.format("", theme_url, TDiaryCounter.all, figure, filetype, init_num, &proc)
	end

	def counter_today(figure = 0, filetype = "", &proc)
		TDiaryCounter.format("-today", theme_url, TDiaryCounter.today, figure, filetype, 0, &proc)
	end

	def counter_yesterday(figure = 0, filetype = "", &proc)
		TDiaryCounter.format("-yesterday", theme_url, TDiaryCounter.yesterday, figure, filetype, 0, &proc)
	end

	def kiriban?
		TDiaryCounter.kiriban?
	end

	def kiriban_today?
		TDiaryCounter.kiriban_today?
	end

	tdiary_counter_cookie = TDiaryCounter.run(@cache_path, @cgi, @options)
	if tdiary_counter_cookie
		if defined?(add_cookie)
			add_cookie(tdiary_counter_cookie)
		else
			@cookie = tdiary_counter_cookie if tdiary_counter_cookie
		end
	end

	def kiriban
		if kiriban?
			msg = @options["counter.kiriban_msg"] ? @options["counter.kiriban_msg"] : ""
			ERB.new(msg.untaint).result(binding)
		elsif kiriban_today?
			msg = @options["counter.kiriban_today_msg"] ? @options["counter.kiriban_today_msg"] : ""
			ERB.new(msg.untaint).result(binding)
		else
			msg = @options["counter.kiriban_nomatch_msg"] ? @options["counter.kiriban_nomatch_msg"] : ""
		end
	end
end

@counter_conf_counter ||= "アクセスカウンタ"
@counter_conf_init_head ||= "初期値の指定"
@counter_conf_init_desc ||= "「全て」表示の際のカウンタの初期値を指定できます。他のアクセスカウンタからの乗り換える時などに使用すると良いでしょう。デフォルトは0です。"
@counter_conf_init_label ||= " 初期値："
@counter_conf_log_head ||= "ログの取得"
@counter_conf_log_desc ||= " 日別のアクセス数をログファイルに残したい場合に指定します。デフォルトは「残す」です。基本的には残すようにしましょう。<br/>ログファイルは、&quot;#{@cache_path}/counter/counter.log&quot; に保存されます。"
@counter_conf_log_true ||= "残す"
@counter_conf_log_false ||= "残さない"
@counter_conf_timer_head ||= "訪問間隔の指定"
@counter_conf_timer_desc ||= "指定した期間、繰り返し訪問してくるユーザをカウントアップしないようになっています(Cookieを使っています)。デフォルトは12(時間)です。"
@counter_conf_timer_label ||= "訪問間隔："
@counter_conf_timer_unit ||= "時間"
@counter_conf_deny_same_src_interval_head ||= "カウントアップしない連続アクセス間隔の指定"
@counter_conf_deny_same_src_interval_desc ||= "前出の「訪問間隔の指定」では、Cookie機能を持たないクライアントからのアクセスがあると、アクセスがあるたびにカウントアップしてしまいます。こちらの機能は、同一IPアドレス/クライアントアプリケーションからの連続アクセスをカウントアップしないようにします。デフォルトは4時間です。"
@counter_conf_deny_same_src_interval_label ||= "カウントアップしない連続アクセス間隔："
@counter_conf_deny_same_src_interval_unit ||= "時間"
@counter_conf_max_keep_access_num_head ||= "最大保持アクセス数の指定"
@counter_conf_max_keep_access_num_desc ||= "前出の「カウントアップしない連続アクセス間隔の指定」で内部的に保持するクライアントユーザ数を指定します。数が多いほど処理に時間がかかるようになるため、小さい方が望ましいです。デフォルトは10000件です。"
@counter_conf_max_keep_access_num_label ||= "最大保持アクセス数："
@counter_conf_max_keep_access_num_unit ||= "件"
@counter_conf_deny_user_agents_head ||= "カウントアップしないユーザエージェント"
@counter_conf_deny_user_agents_desc ||= "カウントしないユーザーエージェントを指定します。ロボットなどを指定すると良いでしょう。各エージェントを'|'(パイプ)で区切って並べてください（正規表現を使うことができます）。<pre>例：Googlebot|Bulkfeeds</pre><p>指定しない場合でも以下のユーザーエージェントからのアクセスはカウントされません。</p>"
@counter_conf_deny_user_agents_label ||= "カウントしないユーザーエージェント："
@counter_conf_kiriban_head ||= "キリ番の指定"
@counter_conf_kiriban_desc ||= "「全て」「今日」のキリ番を指定します。複数指定する場合は','(カンマ)を使ってください（例：100,123,300）。"
@counter_conf_kiriban_label_all ||= "「全て」のキリ番："
@counter_conf_kiriban_label_today ||= "「今日」のキリ番："
@counter_conf_kiriban_messages_head ||= "kiribanプラグインで出力されるメッセージの指定"
@counter_conf_kiriban_messages_desc ||= "ヘッダやサイドメニュー等に、&lt;%= kiriban %&gt;という形でキリ番プラグインを記述しておくと、キリ番になったときに（あるいはキリ番で無いときに）ここで記述する内容を表示します。ヘッダ同様、HTML形式です。"
@counter_conf_kiriban_messages_label_all ||= "「全て」のキリ番メッセージ："
@counter_conf_kiriban_messages_label_today ||= "「今日」のキリ番メッセージ："
@counter_conf_kiriban_messages_label_nomatch ||= "キリ番では無いときのメッセージ："

def print_conf_html
	@conf["counter.init_num"] ||= 0
	@conf["counter.log"] ||= true
	@conf["counter.timer"] ||= 12
	@conf["counter.deny_same_src_interval"] ||= 4
	@conf["counter.deny_user_agents"] ||= ""
	@conf["counter.max_keep_access_num"] ||= 10000

	@conf["counter.kiriban"] ||= ""
	if @conf["counter.kiriban"].kind_of? Array
		@conf["counter.kiriban"] = @conf["counter.kiriban"].join(", ")
	end
	@conf["counter.kiriban_today"] ||= ""
	if @conf["counter.kiriban_today"].kind_of? Array
		@conf["counter.kiriban_today"] = @conf["counter.kiriban_today"].join(", ")
	end

	@conf["counter.kiriban_msg"] ||= ""
	@conf["counter.kiriban_today_msg"] ||= ""
	@conf["counter.kiriban_nomatch_msg"] ||= ""

	if @mode == 'saveconf' then
		@conf["counter.init_num"] = @cgi.params['counter.init_num'][0].to_i
		@conf["counter.log"] = @cgi.params['counter.log'][0] == "true"
		@conf["counter.timer"] = @cgi.params['counter.timer'][0].to_i
		@conf["counter.deny_same_src_interval"] = @cgi.params['counter.deny_same_src_interval'][0].to_i
		@conf["counter.deny_user_agents"] = @cgi.params['counter.deny_user_agents'][0]
		@conf["counter.max_keep_access_num"] ||= @cgi.params["counter.max_keep_access_num"][0].to_i
		@conf["counter.kiriban"] = @cgi.params["counter.kiriban"][0]
		@conf["counter.kiriban_today"] = @cgi.params["counter.kiriban_today"][0]
		@conf["counter.kiriban_msg"] = @conf.to_native(@cgi.params["counter.kiriban_msg"][0]).gsub(/\r\n/, "\n" ).gsub(/\r/, '').sub(/\n+\z/, '')
		@conf["counter.kiriban_today_msg"] = @conf.to_native(@cgi.params["counter.kiriban_today_msg"][0]).gsub(/\r\n/, "\n").gsub(/\r/, '').sub(/\n+\z/, '')
		@conf["counter.kiriban_nomatch_msg"] = @conf.to_native(@cgi.params["counter.kiriban_nomatch_msg"][0]).gsub(/\r\n/, "\n").gsub(/\r/, '').sub(/\n+\z/, '')
	end

	<<-HTML
	<h3 class="subtitle">#{@counter_conf_init_head}</h3>
 	<p>#{@counter_conf_init_desc}</p>
	<p>#{@counter_conf_init_label}<input name="counter.init_num" value="#{h @conf["counter.init_num"]}" size="5"></p>

	<h3 class="subtitle">#{@counter_conf_log_head}</h3>
	<p>#{@counter_conf_log_desc}</p>
	<p>
		<select name="counter.log">
			<option value="true"#{" selected" if @conf["counter.log"]}>#{@counter_conf_log_true}</option>
			<option value="false"#{" selected" if ! @conf["counter.log"]}>#{@counter_conf_log_false}</option>
		</select></li>
	</p>

	<h3 class="subtitle">#{@counter_conf_timer_head}</h3>
	<p>#{@counter_conf_timer_desc}</p>
	<p>#{@counter_conf_timer_label}<input name="counter.timer" value="#{h @conf["counter.timer"]}" size="2">#{@counter_conf_timer_unit}</p>

	<h3 class="subtitle">#{@counter_conf_deny_same_src_interval_head}</h3>
	<p>#{@counter_conf_deny_same_src_interval_desc}</p>
	<p>#{@counter_conf_deny_same_src_interval_label}<input name="counter.deny_same_src_interval" value="#{h @conf["counter.deny_same_src_interval"]}" size="2">#{@counter_conf_deny_same_src_interval_unit}</p>

	<h3 class="subtitle">#{@counter_conf_max_keep_access_num_head}</h3>
	<p>#{@counter_conf_max_keep_access_num_desc}</p>
	<p>#{@counter_conf_max_keep_access_num_label}<input name="counter.max_keep_access_num" value="#{h @conf["counter.max_keep_access_num"]}" size="7">#{@counter_conf_max_keep_access_num_unit}</p>

	<h3 class="subtitle">#{@counter_conf_deny_user_agents_head}</h3>
	<p>#{@counter_conf_deny_user_agents_desc}</p>
	<blockquote>#{(@conf["bot"]||[]).join(", ")}, #{@counter_default_user_agents.gsub(/\|/, ", ")}</blockquote>
	<dl><li>#{@counter_conf_deny_user_agents_label}<br/><textarea name="counter.deny_user_agents" cols="70" rows="3">#{@conf["counter.deny_user_agents"]}</textarea></li></dl>

	<h3 class="subtitle">#{@counter_conf_kiriban_head}</h3>
	<p>#{@counter_conf_kiriban_desc}</p>
	<p><dl>
		<li>#{@counter_conf_kiriban_label_all}<input name="counter.kiriban" value="#{h @conf["counter.kiriban"]}" size="60"></li>
		<li>#{@counter_conf_kiriban_label_today}<input name="counter.kiriban_today" value="#{h @conf["counter.kiriban_today"]}" size="60"></li>
	</dl></p>
	<h3 class="subtitle">#{@counter_conf_kiriban_messages_head}</h3>
	<p>#{@counter_conf_kiriban_messages_desc}</p>
	<p><dl>
	<li>#{@counter_conf_kiriban_messages_label_all}<br/>
		<textarea name="counter.kiriban_msg" cols="70" rows="10">#{CGI.escapeHTML(@conf["counter.kiriban_msg"])}</textarea></li>
	<li>#{@counter_conf_kiriban_messages_label_today}<br/>
		<textarea name="counter.kiriban_today_msg" cols="70" rows="10">#{CGI.escapeHTML(@conf["counter.kiriban_today_msg"])}</textarea></li>
	<li>#{@counter_conf_kiriban_messages_label_nomatch}<br/>
		<textarea name="counter.kiriban_nomatch_msg" cols="70" rows="10">#{CGI.escapeHTML(@conf["counter.kiriban_nomatch_msg"])}</textarea></li>
	</dl>
	</p>
	HTML
end

# Configure
add_conf_proc('counter', @counter_conf_counter) do
	print_conf_html
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
