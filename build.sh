#!/usr/bin/bash

pkg -t node6-linux-x64 --output build/Release/host-edit.linux index.js
pkg -t node6-macos-x64 --output build/Release/host-edit.mac index.js
pkg -t node6-win-x64 --output build/Release/host-edit.exe index.js
