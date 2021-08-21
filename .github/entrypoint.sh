#!/bin/bash
set -eu
service supervisor start

while sleep 60; do
  ps aux |grep tidb |grep -q -v grep
  TIDB_STATUS=$?
  ps aux |grep tikv |grep -q -v grep
  TIKV_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $TIDB_STATUS -ne 0 -o $TIKV_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit 1
  fi
done