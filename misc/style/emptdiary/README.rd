=begin
= emptDiaryスタイル((-$Id: README.rd,v 1.5 2003-11-06 09:43:46 zunda Exp $-))

== 概要
((:emptDiaryスタイル:))((-emptDiaryは'empty line permitted tDiary style'
を省略したものです。長いねぇ。-))は、((:tDiaryス タイル:))に加えて、プラ
グインの引数に空白行を許すスタイルです。このスタイルを使うと、日記をセク
ションに分ける際に、<%と%>の間の空白行を無視してもらえます。

日記にプログラムリストなどを書く場合に、リストが空白行を含むと、
((:tDiaryス タイル:))ではリストの途中から次のセクションになってしまいま 
す。((:emptDiaryスタイル:))では、プラグインの引数の中の空白を無視するの
で、例えばpre.rbプラグインのヒアドキュメントとしてプログラムリストを記述
することで、プログラムリストに何の変更もなく、日記にリストを書くことがで
きます。

((:emptDiaryスタイル:))の最新版は、
((<URL:http://zunda.freeshell.org/d/misc/style/emptdiary/emptdiary_style.rb>))から、
このファイルの最新版は、
((<URL:http://zunda.freeshell.org/d/misc/style/emptdiary/README.rd>))か
ら、 入手できるでしょう。

また、pre.rbの最新版は、
((<URL:http://zunda.freeshell.org/d/plugin/pre.rb>))から入手できるはずで
す。

== Usage
このスタイルを使うには、
(1) emptdiary_style.rb ファイルを、tdiary/ ディレクトリにコピーしてくだ
    さい。tdiary/ ディレクトリは、tdiary.rb ファイルのあるトップディレク
    トリの下にあります。
(2) tdiary.confに以下の行を書いてください。
      @style = 'emptDiary'

日記は、((:tDiaryスタイル:))とほとんど同じように書くことができます。
HOWTO-write-tDiary.htmlに書かれている通り、
* 空白無しで始まる行は、((:セクションタイトル:))になります。この行には、
  ((:セクションアンカー:))が付きます。
* ((:セクションタイトル:))に続く行は、その((:セクション:))の内容になりま
  す。
* 空白行によって、次の((:セクション:))と分かれます。
* ((:セクション:))の最初の行を空白や<で始めることによって、
  ((:セクションタイトル:))の無い((:セクション:))を作ることができます。

((:emptDiaryスタイル:))では、上記のルールに加えて、
* <%と%>に囲まれた空白行は、セクションを分割する際に無視されます。つまり、
  あるセクションに、<%と%>に囲まれた空白行を含めることができます。
* 副作用として、日記には、<%と%>が同数、それぞれペアになって含まれていな
  いといけません。

つまり、pre.rbを使って、
  セクションタイトル
  <p>セクションの内容</p>
  <%=pre <<'_PRE'
  #include <stdio.h>

  /* 上記は空白行 */
  int
  main (int argc, char *argv[])
  {
    puts ("Hello world.");
  }
  _PRE
  %>
などというセクションを作ることができます。不等号やアンパーサンドの実体参
照への変換は、pre.rbで行われることに注意してください。

== 謝辞
このスタイルは、((:tDiaryスタイル:))のTdiarySectionとTdiaryDiaryをsuper
classとして実装されています。このようなフレキシブルなクラスを提供されて
いる、tdiary_style.rbの著者の方々に感謝します。

== 著作権
Copyright 2003 zunda <zunda at freeshell.org>

Permission is granted for use, copying, modification, distribution,
and distribution of modified versions of this work under the terms
of GPL version 2 or later.                                                  
=end
=begin ChangeLog
* Mon Feb 17, 2003 zunda <zunda at freeshell.org>
- first draft
=end
