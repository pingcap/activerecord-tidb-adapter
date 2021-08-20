#!/bin/bash

set -eo pipefail

bundle config set --local path '/tmp/buildkite-cache' 

echo "Setup gem mirror"
bundle config mirror.https://rubygems.org https://gems.ruby-china.com 

echo "Bundle install"
bundle install

echo "Setup database for testing"
tidb=1 ARCONN=tidb bundle exec rake db:tidb:build && tidb=1 ARCONN=tidb bundle exec rake test:tidb
