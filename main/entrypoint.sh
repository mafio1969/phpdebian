#!/usr/bin/env bash
service supervisor start
echo "${APP_ENV}"

if [ "${APP_ENV}" = "local" ]; then
  echo 'Local instance'
fi

if [ "${APP_ENV}" = "dev" ]; then
   echo 'Server instance'
fi

apache2-foreground
exec "$@"
