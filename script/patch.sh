#!/bin/sh
set -e

script/shove.sh
cap deploy:patch
