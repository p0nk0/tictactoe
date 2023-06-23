#!/bin/sh

SERVER_EXE="_build/default/server/bin/main.exe"
CLIENT_JS="_build/default/client/bin/main.bc.js"

if test -f "$SERVER_EXE"; then
  if test -f "$CLIENT_JS"; then
    $SERVER_EXE -js-file "$CLIENT_JS" $@
    exit 0;
  fi
fi

dune build
$SERVER_EXE -js-file "$CLIENT_JS" $@

