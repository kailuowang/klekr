#!/bin/sh
set -e

script/shove.sh
cap deploy:simple POST_DEPLOY=$POST_DEPLOY
