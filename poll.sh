#!/bin/sh
if [ -f /secrets/env ]; then
  export $(cat /secrets/env | xargs)
fi

if [ -z $itc_password ]; then
  echo "Can't run without a password"
  exit 1
fi

cd /app

bundle exec ruby poll-itc.rb
