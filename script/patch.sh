#!/bin/sh
echo "Please make sure spork is running otherwise tests will fail!"
set -e

bundle exec rake
git push
cap deploy:patch
