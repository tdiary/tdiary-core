#!/usr/bin/env ruby

require "test/unit"

if Test::Unit.respond_to?(:setup_argv)
  Test::Unit::setup_argv{[File.dirname($0)]}
else
  if Test::Unit::AutoRunner.respond_to?(:standalone?)
    exit Test::Unit::AutoRunner.run($0, File.dirname($0))
  else
    exit Test::Unit::AutoRunner.run(false, File.dirname($0))
  end
end
