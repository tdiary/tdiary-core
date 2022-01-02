#!/bin/bash
cp .devcontainer/tdiary.conf .
cp .devcontainer/Gemfile.local .
bundle config set path vendor/bundle
bundle config set with development:test
bundle install --jobs=4 --retry=3
bundle exec rake assets:copy
gem install debug
#git ls-remote -q > /dev/null
