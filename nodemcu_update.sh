#!/bin/bash
set -e
nodemcu-uploader --port /dev/ttyUSB0 file remove init.lua 
sleep 1
nodemcu-uploader --port /dev/ttyUSB0 upload init.lua application.lua location.lua 
echo "uploaded lua-files"
sleep 1
nodemcu-uploader --port /dev/ttyUSB0 node restart
echo "restarted node"
nodemcu-uploader --port /dev/ttyUSB0 terminal
