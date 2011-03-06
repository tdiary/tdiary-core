# -*- coding: utf-8 -*-
require File.expand_path('../../tdiary/environment', __FILE__)
Bundler.require :test if defined?(Bundler)

$:.unshift File.expand_path('../..', __FILE__)
require 'tdiary'

def assert_diary(htmlExpected, htmlResult)
  if htmlExpected == htmlResult
    assert(true)
  else
    $diffOutput ||= File.open("tmp/style_test.diff", "w")
    require "tempfile"
      files = [htmlExpected, htmlResult].collect { |content|
      tmpfile = Tempfile.new("style")
      tmpfile.write(content)
      tmpfile.flush
      tmpfile.path
    }
    $diffOutput.print(`diff -u #{files[0]} #{files[1]}`)
    assert(false, "(See tmp/style_test.diff)\n-- Expected\n#{htmlExpected}\n-- Result\n#{htmlResult}")
  end
end
