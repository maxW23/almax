# Android Release & Flavors

## Flavors
Defined in `android/app/build.gradle.kts`:
- dev → applicationIdSuffix `.dev`, versionNameSuffix `-dev`, app name `Lklk (Dev)`
- staging → suffix `.staging`, `-stg`, app name `Lklk (Staging)`
- prod → no suffixes, app name `Lklk`

Build commands:
```bash
# Dev flavor AAB
flutter build appbundle --release --flavor dev --dart-define=ENV=dev --obfuscate --split-debug-info=build/symbols --tree-shake-icons

# Staging flavor AAB
flutter build appbundle --release --flavor staging --dart-define=ENV=staging --obfuscate --split-debug-info=build/symbols --tree-shake-icons

# Prod flavor AAB
flutter build appbundle --release --flavor prod --dart-define=ENV=prod --obfuscate --split-debug-info=build/symbols --tree-shake-icons
```

Or use the helper script:
```bash
scripts/build_release.sh android dev
scripts/build_release.sh android staging
scripts/build_release.sh android prod
```

## ProGuard / R8
- Enabled `minifyEnabled` and `shrinkResources` in `release`.
- Rules: `android/app/proguard-rules.pro` with ZEGO/WebRTC/Flutter/ExoPlayer keeps.

## ABI Splits
- Only `armeabi-v7a` and `arm64-v8a` are packaged.
- Universal APK disabled to reduce size.

## Signing
- `key.properties` loaded if present; set:
```
storeFile=/absolute/path/to/keystore.jks
storePassword=...
keyAlias=...
keyPassword=...
```

## SKSL Optional
```bash
flutter run --profile --cache-sksl --purge-persistent-cache
# save flutter_01.sksl.json
flutter build appbundle --release --flavor prod --dart-define=ENV=prod --bundle-sksl-path flutter_01.sksl.json
```
