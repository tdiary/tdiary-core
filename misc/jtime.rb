#
# 「%J」で日本語の曜日名を出すTimeクラス改造版
# tdiary.conf内でrequireして使う
#
class Time
   alias strftime_ strftime
   JWDAY = %w(日 月 火 水 木 金 土)
   def strftime( format )
      strftime_( format.gsub( '%J', JWDAY[self.wday] ) )
   end
end

