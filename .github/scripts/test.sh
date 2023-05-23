#!/bin/bash

set -eo pipefail

# xcrun simctl create "iPhone 14" \
#   "com.apple.CoreSimulator.SimDeviceType.iPhone-14" \
#   "com.apple.CoreSimulator.SimRuntime.iOS-16-2"
xcodebuild -project Riverbed.xcodeproj \
           -scheme Riverbed \
           -destination platform="iOS Simulator,OS=16.2,id=004DCB5F-255C-4ECE-9C55-651D4312C607" \
           clean test | xcpretty
