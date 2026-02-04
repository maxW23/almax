# iOS Flavors (Schemes & Configurations)

This guide shows how to create Dev / Staging / Prod flavors on iOS.

## 1) Duplicate configurations
Open `ios/Runner.xcworkspace` in Xcode.

- Select the project `Runner` → `Info` tab.
- Under `Configurations`, duplicate `Debug` and `Release` to:
  - `Debug-Dev`, `Release-Dev`
  - `Debug-Staging`, `Release-Staging`
  - Keep `Debug-Prod`, `Release-Prod` (or reuse existing `Debug`/`Release` for Prod).

## 2) Create schemes
- Product → Scheme → Manage Schemes…
- Duplicate your `Runner` scheme twice and rename to:
  - `Runner-Dev`
  - `Runner-Staging`
  - `Runner-Prod`
- For each scheme → `Edit`:
  - `Build` and `Run/Test/Archive` use the matching configuration (e.g. `Runner-Dev` → `Debug-Dev` / `Release-Dev`).

## 3) Bundle identifiers & Display Name
- Target `Runner` → `Build Settings` → filter `Product Bundle Identifier`.
- Use conditional values per configuration (click the `+` to add per-config values):
  - `Release-Prod`/`Debug-Prod`: `com.company.app`
  - `Release-Staging`/`Debug-Staging`: `com.company.app.staging`
  - `Release-Dev`/`Debug-Dev`: `com.company.app.dev`

- Target `Runner` → `Info` → `Bundle name` (or `InfoPlist.strings` per config) to set display names:
  - Prod: `Lklk`
  - Staging: `Lklk (Staging)`
  - Dev: `Lklk (Dev)`

## 4) Dart-define per scheme (optional)
- Add `--dart-define=ENV=<dev|staging|prod>` in your CI or Fastlane.
- Locally:
```bash
flutter run --flavor dev -t lib/main.dart --dart-define=ENV=dev
flutter build ios --release --no-codesign --dart-define=ENV=prod
```

## 5) Signing
- For each configuration, assign the appropriate `Provisioning Profile` and `Signing Certificate`.

## 6) Build & Archive
- Select the scheme (e.g. `Runner-Prod`) → Product → Archive.
- For CI, you can call:
```bash
flutter build ios --release --no-codesign --dart-define=ENV=prod
```

Notes:
- On iOS, `--flavor` controls which Xcode scheme is invoked when configured via `flutter` tooling. Name your scheme matching the flavor name.
- Ensure `Info.plist` per-configuration overrides are set for display name and any environment-dependent keys if needed.
