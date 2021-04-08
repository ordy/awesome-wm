#!/usr/bin/env bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

nm-applet &
autorandr -c &
feh --bg-fill $(head -n 2 .config/nitrogen/bg-saved.cfg | tail -n 1 | cut -c 6-) &
run picom --config ./.config/picom.conf
