# -*- coding: utf-8; mode: ruby -*-
Gem::Specification.new do |s|
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = "1.3.5"

  s.name = 'rdtool'
  s.version = '0.6.38'
  s.date = '2012-11-27'

  s.summary = "RDtool is formatter for RD."
  s.description = "RD is multipurpose documentation format created for documentating Ruby and output of Ruby world. You can embed RD into Ruby script. And RD have neat syntax which help you to read document in Ruby script. On the other hand, RD have a feature for class reference."
  s.authors = ["Youhei SASAKI"]
  s.email = "uwabami@gfd-dennou.org"
  s.homepage = "http://github.com/uwabami/rdtool"
  s.licenses = ["GPL-2+", "Ruby"]
  s.require_paths = ["lib"]
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.test_files = `git ls-files -- test/*`.split("\n")

  s.add_development_dependency('racc', "~> 1.4.6")
  s.add_development_dependency('rake', ">= 0") unless defined? Rake

  # = MANIFEST =
  s.files = %w[
    COPYING.txt
    Gemfile
    HISTORY
    LGPL-2.1
    LICENSE.txt
    README.html
    README.ja.html
    README.rd
    README.rd.ja
    Rakefile
    TODO
    bin/rd2
    bin/rdswap.rb
    doc/rd-draft.html
    doc/rd-draft.ja.html
    doc/rd-draft.rd
    doc/rd-draft.rd.ja
    lib/rd/block-element.rb
    lib/rd/complex-list-item.rb
    lib/rd/desclist.rb
    lib/rd/document-struct.rb
    lib/rd/dot.rd2rc
    lib/rd/element.rb
    lib/rd/filter.rb
    lib/rd/head-filter.rb
    lib/rd/inline-element.rb
    lib/rd/labeled-element.rb
    lib/rd/list.rb
    lib/rd/loose-struct.rb
    lib/rd/methodlist.rb
    lib/rd/output-format-visitor.rb
    lib/rd/package.rb
    lib/rd/parser-util.rb
    lib/rd/post-install
    lib/rd/pre-setup.rb
    lib/rd/rbl-file.rb
    lib/rd/rbl-suite.rb
    lib/rd/rd-struct.rb
    lib/rd/rd2html-ext-lib.rb
    lib/rd/rd2html-ext-opt.rb
    lib/rd/rd2html-lib.rb
    lib/rd/rd2html-opt.rb
    lib/rd/rd2man-lib.rb
    lib/rd/rd2rdo-lib.rb
    lib/rd/rd2rmi-lib.rb
    lib/rd/rdblockparser.ry
    lib/rd/rdblockparser.tab.rb
    lib/rd/rdfmt.rb
    lib/rd/rdinlineparser.ry
    lib/rd/rdinlineparser.tab.rb
    lib/rd/rdvisitor.rb
    lib/rd/reference-resolver.rb
    lib/rd/search-file.rb
    lib/rd/tree.rb
    lib/rd/version.rb
    lib/rd/visitor.rb
    rdtool.gemspec
    setup.rb
    test/data/includee1.html
    test/data/includee2.html
    test/data/includee3.nothtml
    test/data/includee4.xhtml
    test/data/label.rbl
    test/data/label2.rbl
    test/data/sub/includee2.html
    test/data/sub/includee4.html
    test/dummy-observer.rb
    test/dummy.rb
    test/temp-dir.rb
    test/test-block-parser.rb
    test/test-desclist-item.rb
    test/test-document-element.rb
    test/test-document-struct.rb
    test/test-element.rb
    test/test-headline.rb
    test/test-inline-parser.rb
    test/test-list-item.rb
    test/test-list.rb
    test/test-methodlist-item.rb
    test/test-nonterminal-element.rb
    test/test-nonterminal-inline.rb
    test/test-output-format-visitor.rb
    test/test-parser-util.rb
    test/test-rbl-file.rb
    test/test-rbl-suite.rb
    test/test-rd2html-lib.rb
    test/test-rdtree.rb
    test/test-rdvisitor.rb
    test/test-reference-resolver.rb
    test/test-reference.rb
    test/test-search-file.rb
    test/test-terminal-inline.rb
    test/test-textblock.rb
    test/test-tree.rb
    test/test-version.rb
    test/test-visitor.rb
    utils/rd-mode.el
  ]
  # = MANIFEST =

end
