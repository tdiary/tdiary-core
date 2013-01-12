#!/usr/bin/env ruby
=begin
= rd2html-ext-opt.rb
$Id: rd2html-ext-opt.rb,v 1.5 2003/10/30 12:12:33 rubikitch Exp rubikitch $
Copyright(c) 2003 Rubikitch
Licence: Ruby's License or GPL-2+
=end
require 'rd/rd2html-opt'

q = ARGV.options

q.on_tail("--ref-extension") do
  $Visitor.opt_ref_extension = true
end

q.on_tail("--headline-title") do
  $Visitor.opt_headline_title = true
end

q.on_tail("--headline-secno") do
  $Visitor.opt_headline_secno = true
end

q.on_tail("--enable-br") do
  $Visitor.opt_enable_br = true
end

q.on_tail("--native-inline") do
  $Visitor.opt_native_inline = true
end

q.on_tail("--head-element") do
  $Visitor.opt_head_element = true
end
