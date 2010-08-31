require "test/unit"
rootdir = "#{File::dirname(__FILE__)}/.."
require "#{rootdir}/lib/hikidoc"

class HikiDocTestCase < Test::Unit::TestCase
  def test_plugin
    assert_convert("<div class=\"plugin\">{{hoge}}</div>\n",
                   "{{hoge}}")
    assert_convert("<p>a<span class=\"plugin\">{{hoge}}</span>b</p>\n",
                   "a{{hoge}}b")
    assert_convert("<p>\\<span class=\"plugin\">{{hoge}}</span></p>\n",
                   "\\{{hoge}}")
    assert_convert("<p>a{{hoge</p>\n",
                   "a{{hoge")
    assert_convert("<p>hoge}}b</p>\n",
                   "hoge}}b")
    assert_convert("<p><span class=\"plugin\">{{hoge}}</span>\na</p>\n",
                   "{{hoge}}\na")
    assert_convert("<div class=\"plugin\">{{hoge}}</div>\n<p>a</p>\n",
                   "{{hoge}}\n\na")
  end

  def test_plugin_with_quotes
    assert_convert("<div class=\"plugin\">{{hoge(\"}}\")}}</div>\n",
                   '{{hoge("}}")}}')
    assert_convert("<div class=\"plugin\">{{hoge(\'}}\')}}</div>\n",
                   "{{hoge('}}')}}")
    assert_convert("<div class=\"plugin\">{{hoge(\'\n}}\n\')}}</div>\n",
                   "{{hoge('\n}}\n')}}")
  end

  def test_plugin_with_meta_char
    assert_convert("<div class=\"plugin\">{{hoge(\"a\\\"b\")}}</div>\n",
                   '{{hoge("a\\"b")}}')
    assert_convert("<div class=\"plugin\">{{hoge(\"&lt;a&gt;\")}}</div>\n",
                   '{{hoge("<a>")}}')
    assert_convert("<p>a<span class=\"plugin\">{{hoge(\"&lt;a&gt;\")}}</span></p>\n",
                   'a{{hoge("<a>")}}')
  end

  def test_plugin_with_default_syntax
    # test HikiDoc#valid_plugin_syntax?
    # default syntax checking pairs of quote like "..." or '...'
    assert_convert(%q!<p>{{'}}</p>! + "\n",
		   %q!{{'}}!)
    assert_convert(%q!<div class="plugin">{{''}}</div>! + "\n",
		   %q!{{''}}!)
    assert_convert(%q!<p>{{'"}}</p>! + "\n",
		   %q!{{'"}}!)
    assert_convert(%q!<div class="plugin">{{'\''}}</div>! + "\n",
		   %q!{{'\''}}!)
    assert_convert(%q!<div class="plugin">{{'abc\\\\'}}</div>! + "\n",
		   %q!{{'abc\\\\'}}!)
    assert_convert(%q!<div class="plugin">{{\"""}}</div>! + "\n",
		   %q!{{\"""}}!)
    assert_convert(%q!<div class="plugin">{{"ab\c"}}</div>! + "\n",
		   %q!{{"ab\c"}}!)
  end

  def test_plugin_with_custom_syntax
    assert_convert("<p>{{&lt;&lt;\"End\"\nfoo's bar\nEnd\n}}</p>\n",
                   "{{<<\"End\"\nfoo's bar\nEnd\n}}")

    options = {:plugin_syntax => method(:custom_valid_plugin_syntax?)}
    assert_convert(%Q|<div class="plugin">{{&lt;&lt;"End"\nfoo's bar\nEnd\n}}</div>\n|,
                   %Q!{{<<"End"\nfoo's bar\nEnd\n}}!,
                   options)
    assert_convert(%Q|<div class="plugin">{{&lt;&lt;"End"\nfoo\nEnd}}</div>\n|,
                   %Q!{{<<"End"\nfoo\nEnd}}!,
                   options)
  end

  def test_multi_line_plugin
    assert_convert(<<-END_OF_EXPECTED, <<-END_OF_INPUT)
<div class="plugin">{{&lt;&lt;TEST2
 test2
TEST2}}</div>
                   END_OF_EXPECTED
{{<<TEST2
 test2
TEST2}}
                   END_OF_INPUT

    assert_convert(<<-END_OF_EXPECTED, <<-END_OF_INPUT)
<div class="plugin">{{&lt;&lt;TEST
&lt;&lt;&lt;
here is not pre but plugin.
&gt;&gt;&gt;
TEST}}</div>
                   END_OF_EXPECTED
{{<<TEST
<<<
here is not pre but plugin.
>>>
TEST}}
                   END_OF_INPUT
  end

  def test_blockquote
    assert_convert("<blockquote><p>hoge</p>\n</blockquote>\n",
                   %Q|""hoge\n|)
    assert_convert("<blockquote><p>hoge\nfuga</p>\n</blockquote>\n",
                   %Q|""hoge\n""fuga\n|)
    assert_convert("<blockquote><p>hoge</p>\n<blockquote><p>fuga</p>\n</blockquote>\n</blockquote>\n",
                   %Q|""hoge\n"" ""fuga\n|)
    assert_convert("<blockquote><h1>hoge</h1>\n</blockquote>\n",
                   %Q|"" ! hoge\n|)
    assert_convert("<blockquote><p>foo\nbar</p>\n<p>foo</p>\n</blockquote>\n",
                   %Q|""foo\n""bar\n""\n""foo|)
    assert_convert("<blockquote><p>foo\nbar</p>\n<h1>foo</h1>\n</blockquote>\n",
                   %Q|""foo\n""bar\n""!foo|)
    assert_convert("<blockquote><p>foo\nbar</p>\n<pre>baz</pre>\n</blockquote>\n",
                   %Q|""foo\n"" bar\n""  baz|)
    assert_convert("<blockquote><p>foo\nbar</p>\n<pre>baz</pre>\n</blockquote>\n",
                   %Q|""foo\n""\tbar\n""\t\tbaz|)
  end

  def test_header
    assert_convert("<h1>hoge</h1>\n", "!hoge")
    assert_convert("<h2>hoge</h2>\n", "!! hoge")
    assert_convert("<h3>hoge</h3>\n", "!!!hoge")
    assert_convert("<h4>hoge</h4>\n", "!!!! hoge")
    assert_convert("<h5>hoge</h5>\n", "!!!!!hoge")
    assert_convert("<h6>hoge</h6>\n", "!!!!!! hoge")
    assert_convert("<h6>! hoge</h6>\n", "!!!!!!! hoge")

    assert_convert("<h1>foo</h1>\n<h2>bar</h2>\n",
                   "!foo\n!!bar")
  end

  def test_list
    assert_convert("<ul>\n<li>foo</li>\n</ul>\n",
                   "* foo")
    assert_convert("<ul>\n<li>foo</li>\n<li>bar</li>\n</ul>\n",
                   "* foo\n* bar")
    assert_convert("<ul>\n<li>foo<ul>\n<li>bar</li>\n</ul></li>\n</ul>\n",
                   "* foo\n** bar")
    assert_convert("<ul>\n<li>foo<ul>\n<li>foo</li>\n</ul></li>\n<li>bar</li>\n</ul>\n",
                   "* foo\n** foo\n* bar")
    assert_convert("<ul>\n<li>foo<ol>\n<li>foo</li>\n</ol></li>\n<li>bar</li>\n</ul>\n",
                   "* foo\n## foo\n* bar")
    assert_convert("<ul>\n<li>foo</li>\n</ul><ol>\n<li>bar</li>\n</ol>\n",
                   "* foo\n# bar")
  end

  def test_list_skip
    assert_convert("<ul>\n<li>foo<ul>\n<li><ul>\n<li>foo</li>\n</ul></li>\n</ul></li>\n<li>bar</li>\n</ul>\n",
                   "* foo\n*** foo\n* bar")
    assert_convert("<ol>\n<li>foo<ol>\n<li><ol>\n<li>bar</li>\n<li>baz</li>\n</ol></li>\n</ol></li>\n</ol>\n",
                   "# foo\n### bar\n###baz")
  end

  def test_hrules
    assert_convert("<hr />\n", "----")
    assert_convert("<p>----a</p>\n", "----a")
  end

  def test_pre
    assert_convert("<pre>foo</pre>\n",
                   " foo")
    assert_convert("<pre>\\:</pre>\n",
                   ' \:')
    assert_convert("<pre>foo</pre>\n",
                   "\tfoo")
    assert_convert("<pre>foo\nbar</pre>\n",
                   " foo\n bar")
    assert_convert("<pre>foo\nbar</pre>\n",
                   " foo\n bar\n")
    assert_convert("<pre>&lt;foo&gt;</pre>\n",
                   " <foo>")
    assert_convert("<pre>{{_:a/a}}</pre>\n",
                   " {{_:a/a}}")
    assert_convert("<pre>[[_:a/a]]</pre>\n",
                   " [[_:a/a]]")
  end

  def test_multi_pre
    assert_convert("<pre>foo</pre>\n",
                   "<<<\nfoo\n>>>")
    assert_convert("<pre>foo\n bar</pre>\n",
                   "<<<\nfoo\n bar\n>>>")
    assert_convert("<pre>foo</pre>\n<pre>bar</pre>\n",
                   "<<<\nfoo\n>>>\n<<<\nbar\n>>>")
    assert_convert("<pre>&lt;foo&gt;</pre>\n",
                   "<<<\n<foo>\n>>>")
  end

  def test_multi_pre_with_plugin
    assert_convert("<pre>{{{}}}</pre>\n" +
                   "<div class=\"plugin\">{{'test'}}</div>\n",
                   "<<<\n{{{}}}\n>>>\n{{'test'}}")
  end

  def test_comment
    assert_convert("", "// foo")
    assert_convert("", "// foo\n")
  end

  def test_paragraph
    assert_convert("<p>foo</p>\n", "foo")

    assert_convert("<p>foo</p>\n<p>bar</p>\n",
                   "foo\n\nbar")
    assert_convert("<p>foo</p>\n<p>bar</p>\n",
                   "foo\r\n\r\nbar")

    assert_convert("<p>foo </p>\n<p>b a r </p>\n",
                   "foo \n\nb a r ")
  end

  def test_escape
    assert_convert(%Q|<p>\\"\\"foo</p>\n|,
                   %q|\"\"foo|)
  end

  def test_link
    assert_convert(%Q|<p><a href="http://hikiwiki.org/">http://hikiwiki.org/</a></p>\n|,
                   "http://hikiwiki.org/")
    assert_convert(%Q|<p><a href="http://hikiwiki.org/">http://hikiwiki.org/</a></p>\n|,
                   "[[http://hikiwiki.org/]]")
    assert_convert(%Q|<p><a href="http://hikiwiki.org/">Hiki</a></p>\n|,
                   "[[Hiki|http://hikiwiki.org/]]")
    assert_convert(%Q|<p><a href="/hikiwiki.html">Hiki</a></p>\n|,
                   "[[Hiki|http:/hikiwiki.html]]")
    assert_convert(%Q|<p><a href="hikiwiki.html">Hiki</a></p>\n|,
                   "[[Hiki|http:hikiwiki.html]]")
    assert_convert(%Q|<p><img src="http://hikiwiki.org/img.png" alt="img.png" /></p>\n|,
                   "http://hikiwiki.org/img.png")
    assert_convert(%Q|<p><img src="http://hikiwiki.org:80/img.png" alt="img.png" /></p>\n|,
                   "http://hikiwiki.org:80/img.png")
    assert_convert(%Q|<p><a href="http://hikiwiki.org/ja/?c=edit;p=Test">| +
                   %Q|http://hikiwiki.org/ja/?c=edit;p=Test</a></p>\n|,
                   "http://hikiwiki.org/ja/?c=edit;p=Test")
    assert_convert(%Q|<p><a href="http://hikiwiki.org/ja/?c=edit&amp;p=Test">| +
                   %Q|http://hikiwiki.org/ja/?c=edit&amp;p=Test</a></p>\n|,
                   "http://hikiwiki.org/ja/?c=edit&p=Test")
    assert_convert(%Q|<p><img src="/img.png" alt="img.png" /></p>\n|,
                   "http:/img.png")
    assert_convert(%Q|<p><img src="img.png" alt="img.png" /></p>\n|,
                   "http:img.png")
    assert_convert(%Q|<p><a href="%CB%EE">Tuna</a></p>\n|,
                   "[[Tuna|%CB%EE]]")
    assert_convert(%Q|<p><a href="&quot;&quot;">""</a></p>\n|,
                   '[[""]]')
    assert_convert(%Q|<p><a href="%22">%22</a></p>\n|,
                   "[[%22]]")
    assert_convert(%Q|<p><a href="&amp;">&amp;</a></p>\n|,
                   "[[&]]")
    assert_convert(%Q|<p><a href="aa">aa</a>bb<a href="cc">cc</a></p>\n|,
                   "[[aa]]bb[[cc]]")
    assert_convert(%Q!<p><a href="aa">a|a</a></p>\n!,
                   "[[a|a|aa]]")
  end

  def test_inter_wiki_name
    assert_convert("<p><a href=\"scheme:keyword\">scheme:keyword</a></p>\n",
                   "[[scheme:keyword]]")
    assert_convert("<p><a href=\"scheme:keyword\">label</a></p>\n",
                   "[[label|scheme:keyword]]")
  end

  def test_wiki_name
    assert_convert("<p><a href=\"WikiName\">WikiName</a></p>\n",
                   "WikiName")
    assert_convert("<p><a href=\"HogeRule1\">HogeRule1</a></p>\n",
                   "HogeRule1")

    assert_convert("<p><a href=\"WikiName1WikiName2\">WikiName1WikiName2</a></p>\n",
                   "WikiName1WikiName2")
    assert_convert("<p><a href=\"WikiName1\">WikiName1</a> " +
                      "<a href=\"WikiName2\">WikiName2</a></p>\n",
                   "WikiName1 WikiName2")

    assert_convert("<p>NOTWIKINAME</p>\n",
                   "NOTWIKINAME")
    assert_convert("<p>NOT_WIKI_NAME</p>\n",
                   "NOT_WIKI_NAME")
    assert_convert("<p>WikiNAME</p>\n",
                   "WikiNAME")
    assert_convert("<p>fooWikiNAME</p>\n",
                   "fooWikiNAME")

    assert_convert("<p>RSSPage</p>\n",
                   "RSSPage")
    assert_convert("<p><a href=\"RSSPageName\">RSSPageName</a></p>\n",
                   "RSSPageName")
  end

  def test_not_wiki_name
    assert_convert("<p>WikiName</p>\n",
                   "^WikiName")
    assert_convert("<p>^<a href=\"WikiName\">WikiName</a></p>\n",
                   "^WikiName",
                   :use_not_wiki_name => false)
    assert_convert("<p>^WikiName</p>\n",
                   "^WikiName",
                   :use_wiki_name => false)
    assert_convert("<p>^WikiName</p>\n",
                   "^WikiName",
                   :use_wiki_name => false,
                   :use_not_wiki_name => false)
    assert_convert("<p>foo WikiName bar</p>\n",
                   "foo ^WikiName bar")
  end

  def test_use_wiki_name_option
    assert_convert("<p><a href=\"WikiName\">WikiName</a></p>\n",
                   "WikiName")
    assert_convert("<p>WikiName</p>\n",
                   "WikiName",
                   :use_wiki_name => false)
  end

  def test_image_link
    assert_convert(%Q|<p><img src="http://hikiwiki.org/img.png" alt="img.png" /></p>\n|,
                   "[[http://hikiwiki.org/img.png]]")
    assert_convert(%Q|<p><a href="http://hikiwiki.org/img.png">http://hikiwiki.org/img.png</a></p>\n|,
                   "[[http://hikiwiki.org/img.png]]",
                   :allow_bracket_inline_image => false)

    assert_convert(%Q|<p><img src="http://hikiwiki.org/img.png" alt="img" /></p>\n|,
                   "[[img|http://hikiwiki.org/img.png]]")
    assert_convert(%Q|<p><a href="http://hikiwiki.org/img.png">img</a></p>\n|,
                   "[[img|http://hikiwiki.org/img.png]]",
                   :allow_bracket_inline_image => false)
  end

  def test_definition
    assert_convert("<dl>\n<dt>a</dt>\n<dd>b</dd>\n</dl>\n",
                   ":a:b")
    assert_convert("<dl>\n<dt>a</dt>\n<dd>b\n</dd>\n<dd>c</dd>\n</dl>\n",
                   ":a:b\n::c")
    assert_convert("<dl>\n<dt>a\\</dt>\n<dd>b:c</dd>\n</dl>\n",
                   ':a\:b:c')
    assert_convert("<dl>\n<dt>a</dt>\n<dd>b\\:c</dd>\n</dl>\n",
                   ':a:b\:c')
    assert_convert("<dl>\n<dt>a</dt>\n<dd>b:c</dd>\n</dl>\n",
                   ":a:b:c")
  end

  def test_definition_title_only
    assert_convert("<dl>\n<dt>a</dt>\n</dl>\n",
                   ":a:")
  end

  def test_definition_description_only
    assert_convert("<dl>\n<dd>b</dd>\n</dl>\n",
                   "::b")
  end

  def test_definition_with_link
    assert_convert("<dl>\n<dt><a href=\"http://hikiwiki.org/\">Hiki</a></dt>\n" +
                   "<dd>Website</dd>\n</dl>\n",
                   ":[[Hiki|http://hikiwiki.org/]]:Website")
    assert_convert("<dl>\n<dt>a</dt>\n" +
                   "<dd><a href=\"http://hikiwiki.org/\">Hiki</a></dd>\n" +
                   "</dl>\n",
                   ":a:[[Hiki|http://hikiwiki.org/]]")
  end

  def test_definition_with_modifier
    assert_convert("<dl>\n<dt><strong>foo</strong></dt>\n" +
                   "<dd>bar</dd>\n</dl>\n",
                   ":'''foo''':bar")
    assert_convert("<dl>\n<dt>foo</dt>\n" +
                   "<dd><strong>bar</strong></dd>\n</dl>\n",
                   ":foo:'''bar'''")
    assert_convert("<dl>\n<dt>foo</dt>\n" +
                   "<dd><tt>bar</tt></dd>\n</dl>\n",
                   ":foo:``bar``")
  end

  def test_definition_with_modifier_link
    assert_convert("<dl>\n<dt>" +
                   "<strong><a href=\"http://hikiwiki.org/\">Hiki</a></strong>" +
                   "</dt>\n<dd>Website</dd>\n</dl>\n",
                   ":'''[[Hiki|http://hikiwiki.org/]]''':Website")
    assert_convert("<dl>\n<dt>Website</dt>\n<dd>" +
                   "<strong><a href=\"http://hikiwiki.org/\">Hiki</a></strong>" +
                   "</dd>\n</dl>\n",
                   ":Website:'''[[Hiki|http://hikiwiki.org/]]'''")
    assert_convert("<dl>\n<dt>Website</dt>\n<dd>" +
                   "<tt><a href=\"http://hikiwiki.org/\">Hiki</a></tt>" +
                   "</dd>\n</dl>\n",
                   ":Website:``[[Hiki|http://hikiwiki.org/]]``")
  end

  def test_table
    assert_convert(%Q|<table border=\"1\">\n<tr><td>a</td><td>b</td></tr>\n</table>\n|,
                   "||a||b")
    assert_convert(%Q|<table border=\"1\">\n<tr><td>a</td><td>b</td></tr>\n</table>\n|,
                   "||a||b||")
    assert_convert(%Q|<table border=\"1\">\n<tr><td>a</td><td>b</td></tr>\n</table>\n|,
                   "||a||b||")
    assert_convert(%Q|<table border=\"1\">\n<tr><td>a</td><td>b</td><td> </td></tr>\n</table>\n|,
                   "||a||b|| ")
    assert_convert(%Q|<table border=\"1\">\n<tr><th>a</th><td>b</td></tr>\n</table>\n|,
                   "||!a||b||")
    assert_convert(%Q|<table border=\"1\">\n<tr><td colspan=\"2\">1</td><td rowspan=\"2\">2\n</td></tr>\n<tr><td rowspan=\"2\">3</td><td>4\n</td></tr>\n<tr><td colspan=\"2\">5</td></tr>\n</table>\n|,
                   "||>1||^2\n||^3||4\n||>5")
    assert_convert(%Q|<table border=\"1\">\n<tr><td>a</td><td>b</td><td>c</td></tr>\n<tr><td></td><td></td><td></td></tr>\n<tr><td>d</td><td>e</td><td>f</td></tr>\n</table>\n|,
                   "||a||b||c||\n||||||||\n||d||e||f||")
  end

  def test_table_with_modifier
    assert_convert("<table border=\"1\">\n<tr><td>'''</td><td>'''</td><td>bar</td></tr>\n</table>\n",
                   "||'''||'''||bar")
    assert_convert("<table border=\"1\">\n<tr><td>'''\\</td><td>'''</td><td>bar</td></tr>\n</table>\n",
                   "||'''\\||'''||bar")
  end

  def test_modifier
    assert_convert("<p><strong>foo</strong></p>\n",
                   "'''foo'''")
    assert_convert("<p><em>foo</em></p>\n",
                   "''foo''")
    assert_convert("<p><del>foo</del></p>\n",
                   "==foo==")
    assert_convert("<p><em>foo==bar</em>baz==</p>\n",
                   "''foo==bar''baz==")
    assert_convert("<p><strong>foo</strong> and <strong>bar</strong></p>\n",
                   "'''foo''' and '''bar'''")
    assert_convert("<p><em>foo</em> and <em>bar</em></p>\n",
                   "''foo'' and ''bar''")
    assert_convert("<p><tt>foo</tt></p>\n",
                   "``foo``")
    assert_convert("<p><tt>foo==bar</tt>baz==</p>\n",
                   "``foo==bar``baz==")
  end

  def test_nested_modifier
    assert_convert("<p><em><del>foo</del></em></p>\n",
                   "''==foo==''")
    assert_convert("<p><del><em>foo</em></del></p>\n",
                   "==''foo''==")
  end

  def test_modifier_and_link
    assert_convert("<p><a href=\"http://hikiwiki.org/\"><strong>Hiki</strong></a></p>\n",
                   "[['''Hiki'''|http://hikiwiki.org/]]")
    assert_convert("<p><strong><a href=\"http://hikiwiki.org/\">Hiki</a></strong></p>\n",
                   "'''[[Hiki|http://hikiwiki.org/]]'''")
    assert_convert("<p><tt><a href=\"http://hikiwiki.org/\">Hiki</a></tt></p>\n",
                   "``[[Hiki|http://hikiwiki.org/]]``")
  end

  def test_pre_and_plugin
    assert_convert(%Q|<pre>{{hoge}}</pre>\n|,
                   " {{hoge}}")
    assert_convert(%Q|<pre>{{hoge}}</pre>\n|,
                   "<<<\n{{hoge}}\n>>>")
    assert_convert("<div class=\"plugin\">{{foo\n 1}}</div>\n",
                   "{{foo\n 1}}")
  end

  def test_plugin_in_modifier
    assert_convert("<p><strong><span class=\"plugin\">{{foo}}</span></strong></p>\n",
                   "'''{{foo}}'''")
    assert_convert("<p><tt><span class=\"plugin\">{{foo}}</span></tt></p>\n",
                   "``{{foo}}``")
  end

  def test_syntax_ruby
    if Object.const_defined?(:Syntax)
      assert_convert("<pre><span class=\"keyword\">class </span><span class=\"class\">A</span>\n  <span class=\"keyword\">def </span><span class=\"method\">foo</span><span class=\"punct\">(</span><span class=\"ident\">bar</span><span class=\"punct\">)</span>\n  <span class=\"keyword\">end</span>\n<span class=\"keyword\">end</span></pre>\n",
                     "<<< ruby\nclass A\n  def foo(bar)\n  end\nend\n>>>")
      assert_convert("<pre><span class=\"keyword\">class </span><span class=\"class\">A</span>\n  <span class=\"keyword\">def </span><span class=\"method\">foo</span><span class=\"punct\">(</span><span class=\"ident\">bar</span><span class=\"punct\">)</span>\n  <span class=\"keyword\">end</span>\n<span class=\"keyword\">end</span></pre>\n",
                     "<<< Ruby\nclass A\n  def foo(bar)\n  end\nend\n>>>")
      assert_convert("<pre><span class=\"punct\">'</span><span class=\"string\">a&lt;&quot;&gt;b</span><span class=\"punct\">'</span></pre>\n",
                     "<<< ruby\n'a<\">b'\n>>>")

      # redefine method for below tests
      class << Syntax::Convertors::HTML
	def for_syntax(syntax)
	  raise
	end
      end
    end

    # use google-code-prettify
    assert_convert("<pre class=\"prettyprint\">class A\n  def foo(bar)\n  end\nend</pre>\n",
                   "<<< ruby\nclass A\n  def foo(bar)\n  end\nend\n>>>")
    assert_convert("<pre class=\"prettyprint\">class A\n  def foo(bar)\n  end\nend</pre>\n",
                   "<<< Ruby\nclass A\n  def foo(bar)\n  end\nend\n>>>")
    assert_convert("<pre class=\"prettyprint\">'a&lt;\"&gt;b'</pre>\n",
                   "<<< ruby\n'a<\">b'\n>>>")
  end

  def test_plugin_in_pre_with_header
    assert_convert("<h1>Title</h1>\n<pre>{{_/a:a}}</pre>\n",
                   "! Title\n {{_/a:a}}")
    assert_convert("<h1>Title</h1>\n<pre>{{_/a:a}}\n{{_/a:a}}</pre>\n",
                   "! Title\n {{_/a:a}}\n {{_/a:a}}")
  end

  private
  def assert_convert(expected, markup, options={}, message=nil)
    assert_equal(expected, HikiDoc.to_xhtml(markup, options), message)
  end

  def custom_valid_plugin_syntax?(code)
    eval("BEGIN {return true}\n#{code}", nil, "(plugin)", 0)
  rescue SyntaxError
    false
  end
end
