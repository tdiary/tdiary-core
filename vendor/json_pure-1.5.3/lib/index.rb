#!/usr/bin/env ruby
require 'json'
require 'cgi'

cgi = CGI.new
puts cgi.header
puts 'Hello'.to_json

