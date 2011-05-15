#!/bin/sh
echo "Please make sure spork is running otherwise tests will fail!"
set -e

rake
git push
cap deploy:simple POST_DEPLOY=$POST_DEPLOY
