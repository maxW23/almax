# iOS Release Optimization Guide

Follow these steps in Xcode and CocoaPods for optimal release builds.

## Xcode Build Settings (Release configuration)
- Optimization Level: `Fast, Smallest [-Os]`
- Dead Code Stripping: `Yes`
- Strip Debug Symbols During Copy: `Yes`
- Enable Bitcode: `No` (bitcode deprecated)
- Build Active Architecture Only: `No`
- Debug Information Format: `DWARF with dSYM File`

## Signing
- Set a valid Release `Signing Certificate` and `Provisioning Profile` for your bundle id.
- Ensure your Apple developer account/logins are configured in Xcode Preferences.

## CocoaPods
```bash
cd ios
pod repo update
pod install
```

## Flutter build (no codesign)
```bash
flutter build ios \
  --release \
  --no-codesign \
  --dart-define=ENV=prod \
  --obfuscate \
  --split-debug-info=build/symbols \
  --tree-shake-icons
```
Then open `ios/Runner.xcworkspace` and Archive from Xcode using your Release configuration for TestFlight/App Store.

## Optional: SKSL warm-up
1) Run the app on a device in profile with `--cache-sksl` and navigate hotspots.
2) Save SKSL `flutter_01.sksl.json` and rebuild with:
```bash
flutter build ios --release --bundle-sksl-path flutter_01.sksl.json
```
