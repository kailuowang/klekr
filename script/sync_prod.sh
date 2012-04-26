#!/bin/sh
set -e

nohup bundle exec rake sync:all_streams --trace RAILS_ENV=production > log/one_time_sync.out 2> log/one_time_sync.err < /dev/null &