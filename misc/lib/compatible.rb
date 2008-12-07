# = for Ruby1.9.0 compatible =
#
# == 前提条件 ==
#
#  * Ruby1.9 の場合は --encoding=Binary オプションで動作させること

# --------------------------------------------------------
# 汎用的な設定
# --------------------------------------------------------

# for Ruby1.9.0

unless "".respond_to?('to_a')
  class String
    def to_a
      [ self ]
    end
  end
end

unless "".respond_to?('each')
  class String
    alias each each_line
  end
end

# Ruby1.9では String が Enumerable ではなくなった
class String
  def method_missing(name, *args, &block)
    each_line.__send__(name, *args, &block)
  end
end


# for Ruby1.8.X

unless "".respond_to?('force_encoding')
  class String
    def force_encoding(encoding)
      self
    end
  end
end

unless "".respond_to?('bytesize')
  class String
    alias bytesize size
  end
end

unless "".respond_to?('ord')
  class String
    def ord
      self[0]
    end
  end

  class Integer
    def ord
      self
    end
  end
end

# --------------------------------------------------------
# tDiary 用の設定
# --------------------------------------------------------

# Ruby1.9でNKF::nkfを呼ぶと文字列のencodingが変わってしまう。
# そのため、encodingがBinaryの環境で動かすと
# "character encodings differ" エラーとなる。
begin
  require 'nkf'
  module NKF
    alias :_nkf :nkf
    def nkf(option, src)
      r = _nkf(option, src)
      r.force_encoding('Binary')
    end
    module_function :nkf, :_nkf
  end
rescue
end

# 日本語を含むツッコミを入れると diary.last_modified が String になる (原因不明)
# (PStore 保存前は Time だが, 保存後に String となる)
# 暫定的に String だったら Time へ変換する
module TDiary
  class WikiDiary
    def last_modified
      if @last_modified.instance_of? String
        @last_modified = Time.at(0)
      end
      @last_modified
    end
  end
end
