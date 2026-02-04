#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   scripts/build_release.sh android   # builds Android appbundle (.aab)
#   scripts/build_release.sh ios       # builds iOS release (no codesign)
#   scripts/build_release.sh sksl      # capture SKSL and build with it (android)
#
# Output symbols are written to build/symbols for obfuscation stacktraces.

CMD=${1:-}
FLAVOR=${2:-prod}
if [[ -z "$CMD" ]]; then
  echo "Usage: $0 [android|ios|sksl] [dev|staging|prod]"
  exit 1
fi

mkdir -p build/symbols

case "$CMD" in
  android)
    flutter clean
    flutter pub get
    flutter build appbundle \
      --release \
      --flavor "$FLAVOR" \
      --dart-define=ENV="$FLAVOR" \
      --obfuscate \
      --split-debug-info=build/symbols \
      --tree-shake-icons
    echo "Built Android AAB at build/app/outputs/bundle/release/app-release.aab"
    ;;
  ios)
    flutter clean
    flutter pub get
    flutter build ios \
      --release \
      --no-codesign \
      --dart-define=ENV="$FLAVOR" \
      --obfuscate \
      --split-debug-info=build/symbols \
      --tree-shake-icons
    echo "Built iOS release (no codesign). Archive via Xcode or Fastlane."
    ;;
  sksl)
    echo "Run the app in profile to generate SKSL, then provide the path here if needed."
    echo "Example capture (on device): flutter run --profile --cache-sksl --purge-persistent-cache"
    echo "After capture, copy flutter_01.sksl.json and pass via --bundle-sksl-path"
    flutter build appbundle \
      --release \
      --flavor "$FLAVOR" \
      --dart-define=ENV="$FLAVOR" \
      --obfuscate \
      --split-debug-info=build/symbols \
      --tree-shake-icons \
      --bundle-sksl-path flutter_01.sksl.json
    ;;
  *)
    echo "Unknown command: $CMD"; exit 1;;
 esac
