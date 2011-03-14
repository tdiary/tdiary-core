#!/usr/bin/env ruby
# Make for rdtool.
# Copyright (C) 2004 MoonWolf <moonwolf@moonwolf.com>
require 'rbconfig'
require 'optparse'
require 'find'

bindir     = Config::CONFIG['bindir']
sitelibdir = Config::CONFIG['sitelibdir']
racc       = nil
version    = ARGV.shift || "0.6.21"
$dryrun    = false
$force     = false
$quiet     = false

opt = OptionParser.new

opt.on('--bindir=DIR')     {|v| bindir     = v }
opt.on('--sitelibdir=DIR') {|v| sitelibdir = v }
opt.on('--with-racc=RACC') {|v| racc       = v }
opt.on('--version')        {|v| version    = v }
opt.on('-n', '--dry-run')  {$dryrun = true}
opt.on('--force')          {$force = true}
opt.on('--quiet')          {$quiet = true}

opt.parse!(ARGV)

Find.find('.') {|path|
  path = File.expand_path(path)
  next if FileTest.directory? path
  next if path=~/\/(\..+|HISTORY|test-version\.rb)\z/
  next unless orig = IO.read(path)
  after = orig.gsub(/0\.\d\.\d+/, version)
  unless after == orig
    open(path,'wb') {|f|
      f.write after
    }
  end
}

racc ||= 'racc'
rd2 = File.join(File.dirname(File.expand_path(__FILE__)),'bin','rd2')

def uptodate?(new, old_list)
  if !$force and File.exist?(new)
    new_time = File.mtime(new)
    !old_list.any? {|old| File.exist?(old) and File.mtime(old) > new_time}
  else
    false
  end
end

def run(*args)
  puts args.join(' ') unless $quiet
  system(*args) unless $dryrun
end

def depend(dest, src)
  uptodate?(dest, src) or yield(src, dest)
end

# Parser make
Dir.glob('lib/rd/*.ry') do |ry|
  depend(ry.chomp(".ry") + ".tab.rb", [ry]) do
    run(racc, ry)
  end
end

# Document make
Dir.glob('**/*.rd{,.*}') do |rd|
  depend(rd.sub(/\.rd(.*)\z/, '\1.html'), [rd]) do
    html = rd.sub(/\.rd/, '')
    run(rd2, "-o", html, rd)
  end
end
