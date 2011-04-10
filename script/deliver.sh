#!/bin/sh
rake
git push
cap deploy:simple POST_DEPLOY=$POST_DEPLOY