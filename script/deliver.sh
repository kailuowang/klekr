#!/bin/sh
echo "Please make sure spork is running otherwise tests will fail!"
set -e

bundle exec rake shove
cap deploy:simple POST_DEPLOY=$POST_DEPLOY
