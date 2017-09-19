# name spaces reservation
module TDiary; end
module TDiary::Cache; end

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../../Gemfile', __FILE__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])

# FIXME: workaround fix for tainted path from Gemfile.local
$LOAD_PATH.each{|lp| $LOAD_PATH << $LOAD_PATH.shift.dup.untaint}

if defined?(Bundler)
  env = [:default, :rack]
  env << :development if ENV['RACK_ENV'].nil? || ENV['RACK_ENV'].empty?
  env << ENV['RACK_ENV'].intern if ENV['RACK_ENV']
  env = env.reject{|e|
	  (Bundler.settings.without rescue Bundler.settings[:without]).include? e
  }
  Bundler.require *env
end

# Bundler.require doesn't load gems specified in .gemspec
# see: https://github.com/bundler/bundler/issues/1041
#
# load gems dependented by tdiary
tdiary_spec = Bundler.definition.specs.find {|spec| spec.name == 'tdiary'}
if tdiary_spec
  tdiary_spec.dependent_specs.each {|dep_spec|
    begin
      require dep_spec.name
    rescue LoadError => e
      STDERR.puts "failed require '#{dep_spec.name}'"
      STDERR.puts e
    end
  }
end
