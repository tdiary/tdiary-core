['..', '../misc/plugin'].each do |path|
  $LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), path))
end

require 'tdiary/environment'
require 'test/unit'
