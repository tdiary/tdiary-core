#!/bin/bash
source `dirname $0`/setup-app.sh
bundle exec rackup -o 0.0.0.0 -p 9292
