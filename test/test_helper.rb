# -*- coding: utf-8 -*-
require File.expand_path('../../tdiary/environment', __FILE__)
Bundler.require :test if defined?(Bundler)

$:.unshift File.expand_path('../..', __FILE__)
require 'tdiary'
