#!/bin/bash

set -eo pipefail

# xcrun simctl create "iPhone 14" \
#   "com.apple.CoreSimulator.SimDeviceType.iPhone-14" \
#   "com.apple.CoreSimulator.SimRuntime.iOS-16-2"
xcodebuild -project Riverbed.xcodeproj \
           -scheme Riverbed \
           -destination platform="iOS Simulator,OS=16.2,name=iPhone 14" \
           clean test | xcpretty
