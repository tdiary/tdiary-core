#!/usr/bin/env ruby
# -*- mode: ruby; coding: utf-8; indent-tabs-mode: nil -*-
#
# Copyright(C) Youhei SASAKI All rights reserved.
# $Lastupdate: 2012/05/06 23:15:30$
#
# License: Ruby's License or GPL-2+
#
# Code:
Dir.chdir("#{srcdir_root}")
Dir.glob("./lib/rd/*.ry").each { |f|
  obj = f.gsub(/\.ry$/,'.tab.rb')
  unless FileTest.exists?(obj)
    puts "racc #{f} -o #{obj}"
    system "racc #{f} -o #{obj}" unless srcfile?(obj)
  end
}

