#!/bin/bash
set -euo pipefail

# Fixes: Xcode failed to resolve Swift Package Manager dependencies
# (GoogleUtilities 8.1.4 / google_sign_in) when mixed with CocoaPods ML Kit.
#
# Disables Flutter Swift Package Manager and rebuilds iOS via CocoaPods only.

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

echo "==> Disable Flutter Swift Package Manager"
flutter config --no-enable-swift-package-manager

echo "==> Clean Flutter / iOS / SPM caches"
flutter clean
rm -rf build
rm -rf ios/Flutter/ephemeral
rm -rf ios/.symlinks
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm
rm -rf ios/Runner.xcworkspace/xcshareddata/swiftpm
rm -rf "$HOME/Library/Developer/Xcode/DerivedData/Runner-"*

echo "==> flutter pub get"
flutter pub get

echo "==> Generate iOS config / plugin symlinks"
flutter build ios --config-only --debug --no-codesign

echo "==> pod install"
cd ios
pod install
cd ..

echo ""
echo "Done. Run the app again from your IDE, or:"
echo "  flutter run"
