#!/bin/bash
if [ ! -f tdiary.conf ]; then
	cp tdiary.conf.beginner tdiary.conf
fi
bundle config set path vendor/bundle
bundle config set with development:test
bundle install --jobs=4 --retry=3
bundle exec rake assets:copy
if [ ! -f .htpasswd ]; then
	bundle exec bin/tdiary htpasswd
fi
git ls-remote -q > /dev/null
