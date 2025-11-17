#!/bin/bash
set -e

pulseaudio -D

sleep 1
echo "Starting ledfx"
exec ledfx -c "$HOME/ledfx-config" "$@"
