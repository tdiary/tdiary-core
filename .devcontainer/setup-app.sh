#!/bin/bash
if [ ! -f tdiary.conf ]; then
	cp tdiary.conf.beginner tdiary.conf
fi
bundle --path=vendor/bundle --jobs=4 --retry=3
bundle exec rake assets:copy
if [ ! -f .htpasswd ]; then
	bundle exec bin/tdiary htpasswd
fi
