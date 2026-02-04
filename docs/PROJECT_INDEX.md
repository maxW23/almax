# LKLK Project Index (Code Context Map)

Generated: 2026-01-15 17:36 (+03)
Root: `/Users/abo_alhuda/Documents/flutter_projects_abo_alhuda/new_work/lklk`

This is a comprehensive, navigable index of the codebase to onboard any engineer/AI quickly. It maps entry points, layers, modules, flows, and key dependencies without modifying code.

---

## Overview

- **App type**: Flutter (mobile) social audio/chat app with rooms, gifts/entries, profiles, tasks, and overlays.
- **State management**: Flutter Bloc (Cubit) across features.
- **Networking**: Dio via `ApiService` with auth interceptor, retry, and optional request debounce.
- **Audio/RTC**: Zego Express + ZIM bridged via `ExpressService` and `ZEGOSDKManager`, with an optional LiveKit audio delegation mode.
- **Overlay**: `x_overlay` powers room minimize/restore with `AudioRoomOverlayPage` and `RoomViewBloc`.
- **Storage**: flutter_secure_storage (tokens), Hive (entities/caches), SharedPreferences (light caches, counters), and custom room LRU cache.
- **Localization**: `flutter_intl` with AR/EN, `lib/l10n/*.arb`.
- **Entry flow**: `main.dart` → `AppInitializer.initialize()` → `SplashView` → login/auth → `HomeView`.

---

## Folder Structure (high level)

- `lib/`
  - `main.dart` — bootstrapping, theme, localization, overlay injection.
  - `core/` — config, DI, services (network, auth, notifications), utils, widgets, performance, initialization.
  - `features/` — domain feature modules (auth, home, room, chat, profile_users, tasks, splash, livekit_audio, invitations, etc.).
  - `components/` — reusable UI components per domain (audio_room, call, common, pk).
  - `internal/` — Zego/LiveKit internal SDK wrappers, business defines.
  - `generated/`, `gen/`, `resources/` — generated assets/localization.
  - `pages/` — legacy pages (entry_* and live_streaming, call, login, home_page).
  - Other integration helpers: `zego_*_manager.dart`, `live_audio_room_manager.dart`.
- `assets/` — icons, images, svga placeholders, vip, waves, tasks, etc.
- `docs/` — release docs and this index.
- `packages/` — local overrides (e.g., `webview_flutter_android`, `on_audio_query_android`).

---

## Core Services

- `lib/core/initialization/app_initializer.dart`
  - Loads env, configures image cache, orientation, initializes DI (`service_locator.init()`), Hive, SharedPreferences, foreground service, notifications, optional ads/downloads.
  - Derives LiveKit server URL from env or API host and toggles LiveKit audio delegation in `ExpressService`.
- `lib/core/service_locator.dart`
  - Registers Cubits, UseCases, Repositories, `ApiService` (with request debounce support), LiveKit token/api facades.
- `lib/core/services/api_service.dart`
  - Dio client with baseUrl (`AppConfig.apiBaseUrl`), auth header via `AuthService`, preview logs, exponential backoff, optional debounce, and upload helpers.
- `lib/core/services/auth_service.dart` + `lib/core/services/secure_storage_service.dart`
  - Token/user storage with in-memory cache; primary storage in secure storage; migration/fallback to SharedPreferences.
- `lib/core/realtime/notification_realtime_service.dart`
  - Appwrite realtime notifications; unread counters by category; debounced persistence and reconnect.
- `lib/internal/sdk/express/express_service.dart` + parts
  - Wrapper around Zego Express. Delegates audio to LiveKit when enabled; manages room login/logout, streams, callbacks, sound levels.
- `lib/internal/sdk/livekit/livekit_audio_service.dart`
  - Lightweight LiveKit room join, audio route/mic control, sound-level monitor, and event bridging.
- `lib/core/cache/room_details_cache_manager.dart`
  - Per-room LRU cache (last 3 rooms) of room + users/admin/banned/top for fast restores.

---

## State Management (Bloc/Cubit)

Global providers are wired in `lib/main.dart` via `MultiBlocProvider`:
- `UserCubit` — auth, profile, version checks.
- `RoomCubit` — fetching room details (`/room/{id}?pass=`), updates (type/name/image/pass), admin/ban actions, online users list; exposes `usersServer`, `adminsListUsers`, `bannedUsers`, `topUsers`.
- `LanguageCubit` — locale load/save, AR/EN.
- `RoomsCubit`, `RoomMessagesCubit`, `AlertCubit`, `GiftsShowCubit`, `GiftCubit` — home lists, banners, alerts, gift overlay.
- Player stack: `PlaybackCubit`, `PlaylistCubit`, `BottomSheetCubit`.
- `LuckBagCubit` — money bag flows.
- `LiveKitAudioCubit` — presentation cubit controlling speaker/mic via repository.

Room-view scoped providers (`RoomView.providersMultiBlocProvider`) add:
- `RoomMessagesCubit`, `EmojiPrivateCubit`, `EmojiCubit`, `TopBarRoomCubit`, `MoneyBagTopBarCubit`, `LiveKitAudioCubit`.

---

## UI / Views / Screens

- `lib/main.dart`
  - `MyApp` builds `MaterialApp`, injects `AudioRoomOverlayPage` in a global `Stack`, wraps app with LTR `Directionality` (intentional UI choice), uses `ScreenUtilInit`.
- `features/splash/presentation/views/splash_view.dart` + `widgets/splash_view_body.dart`
  - Startup checks: env/version; offline fallback to `AuthView`; optional forced/optional update dialogs; auto-login path flows to Zego login service then navigates to Home.
- `features/home/presentation/views/home_view.dart`
  - 3-tab `IndexedStack`: Profile, Chat, RoomsHome; realtime notifications init; background prefetch for rooms/profile/messages/banners; optional downloads seed.
- `features/room/presentation/views/widgets/room_view.dart`
  - Composes background, `RoomViewBody`, `GiftOverlay`, SVGA gifts and top bars; handles exit/minimize dialog; overlays via `XOverlayButton`.
- `features/room/presentation/views/widgets/room_view_body.dart`
  - Core room logic: create engine, `loginRoom()`, or overlay restore (_restoreRoomStateFromOverlay), seat/chat layout, sound/watchdogs, ZIM/Zego subscriptions, gift animations, message manager.
- `core/widgets/overlay/page.dart` + `defines.dart`
  - `AudioRoomOverlayPage` hosts overlay controller; restore path builds `RoomViewBloc` (overlay-aware room loader).
- `features/tasks/presentation/views/tasks_page.dart` (and related widgets)
  - Tasks/Rankings UI with localization and progress states.

---

## Network Layer / API

- Base URL: `AppConfig.apiBaseUrl` from env or fallback `https://lklklive.com/api`.
- Auth: Bearer token added by `ApiService` interceptor via `AuthService.getTokenFromSharedPreferences()`; Accept header forced to JSON.
- Retry: Exponential backoff for network/429/timeouts.
- Debounce: Optional request dedup with per-endpoint timing.

Key consumers:
- `features/home/presentation/manger/room_cubit/room_cubit_cubit.dart`
  - `fetchRoomById(id, pass)` calls `/room/{id}?pass={pass}` to get full room + users/admin/banned/top.
  - `updatedfetchRoomById(roomId, where, pass)` uses same endpoint; lightweight ‘track’ mode emits only room/admins.
  - `editRoom*` mutators, ban/admin changes, image upload via `uploadFile()`.
- `features/tasks/data/datasources/tasks_api_service.dart`
  - `GET /user/mession?ln=ar|en` — missions, bearer required.
  - Additional: `POST cointo/point`, `GET change/wp`, `POST user/mission/claim`, `GET user/level`, `GET rankings` (typed params).
- `livekit/token` (on backend) fetched by `ExpressService` for LiveKit audio when enabled.

---

## Storage / DB

- `flutter_secure_storage`: token, user, email/password, type (`SecureStorageService`).
- `SharedPreferences`: fallbacks/migration; various caches (tasks raw JSON + TTL, unread counters, room LRU, settings).
- `Hive`: initialized in `AppInitializer`; adapters for profile elements (`ElementsEntity`), cached user data; boxes include `elementsBox`, `giftCacheBox`, `frameCacheBox`, `entryCacheBox`.
- Custom caches:
  - `RoomDetailsCacheManager`: last 3 rooms (room/users/admins/banned/top) to speed restore and avoid stale backgrounds.

---

## Audio/RTC & Overlay Flow

- `ZEGOSDKManager` bridges `ExpressService` (Zego) + `ZIMService` for messaging.
- `ExpressService` supports `useLiveKitAudio` flag:
  - In LiveKit mode: subscribe to audio tracks via LiveKit; Zego audio is globally muted and audio callbacks disabled; UI callbacks bridged.
  - In Zego mode: regular publish/play streams, room events, sound levels.
- `RoomViewBody` flow:
  - Normal entry: `_createEngineAndLoginRoom()` → `loginRoom()` → host seat, connect speaker, fetch online users in background, recompute layout.
  - Overlay restore: `_restoreRoomStateFromOverlay()` → `updatedfetchRoomById(..., pass)` → `fetchOnlineUsersFromRoom()` → recompute role/audio → ensure seat list; fallback to `loginRoom()` if needed.
- `AudioRoomOverlayPage` uses `XOverlayPage` with `AudioRoomOverlayData` (roomId, role, pass, bg image). Restore builds `RoomViewBloc` for hydrated room.

---

## Tasks & Localization

- `TasksCubit` parses `GET /user/mession?ln=ar|en` into two lists: my-level and upgrade tasks. Uses SharedPreferences for raw cache per-language and compute() isolate for JSON parsing. Fallback Arabic sample data when endpoint errors.
- Localization via `lib/l10n/*.arb`, `flutter_intl` settings in `pubspec.yaml` and `l10n.yaml`.

---

## Third Party SDKs / Plugins (selected)

From `pubspec.yaml` dependencies:
- Networking/Storage: `dio`, `shared_preferences`, `flutter_secure_storage`, `hive/hive_flutter`, `flutter_cache_manager`.
- State/UI: `flutter_bloc`, `provider` (light usage), `flutter_svg`, `cached_network_image`, `shimmer`, `flutter_screenutil`.
- Media/RTC: `zego_express_engine`, `zego_zim`, `livekit_client`, `just_audio`, `record`.
- System: `flutter_foreground_task`, `flutter_local_notifications`, `background_downloader`, `flutter_downloader`, `permission_handler`, `wakelock_plus`.
- Ads/Payments: `google_mobile_ads`, `in_app_purchase`.
- Realtime/Backend: `appwrite`.
- Misc: `image_picker`, `file_picker`, `flutter_svga`, `emoji_picker_flutter`, `web_socket_channel`, `webview_flutter`, `logger`.

---

## Critical Flows

- **Startup**: `main.dart` → `AppInitializer.initialize()` (env, DI, Hive, prefs, notifications) → `runApp(MyApp)` → `SplashView` → version check → auth → `zegoLoginService` → `HomeView`.
- **Home Prefetch**: `HomeView.initState()` triggers `RoomsCubit.fetchRooms()`, `RoomMeCubit.fetchRoomsMe()`, `BannerCubit.fetchBanners()`, `UserCubit.getProfileUser()`, `HomeMessageCubit.fetchLastMessages()`, `FreindCubit.*`.
- **Room Entry**: `RoomView` → `RoomViewBody` → create engine + (normal login or overlay restore) → set speaker, configure role, host seat, fetch online users, start monitors.
- **Chat/Gifts**: `ChatSection` + `OptimizedMessageManager` handle ZIM barrage messages; entry notifications → `GiftsShowCubit` via `GiftEntity`; money bag events via `CombinedRealtimeService` with top bars.
- **Overlay Minimize/Restore**: `XOverlayButton` on `RoomView` navigates back to `HomeView` while keeping overlay bubble; `AudioRoomOverlayPage` restores to `RoomViewBloc` with hydrated state and server refresh.

---

## Issues Found / Observations

- **ApiService instantiation inconsistency**: `RoomCubit` creates `ApiService()` directly instead of using the DI singleton (`service_locator`). This may bypass global options (request debounce, future overrides) and duplicate clients.
- **LTR Directionality**: `MaterialApp.builder` enforces LTR via `_getTextDirection()` regardless of locale. Likely intentional for design, but it overrides RTL Arabic rendering.
- **Spellings/Paths**: Asset folders named `wakala_chanllage`, `cp_chanllage`, `socail_media_svg` — misspellings make maintenance harder.
- **Splash offline path**: `AppInitializer.initializeAppwriteDeferred()` exists but is not invoked in `main.dart`; if Appwrite features are required early, consider scheduling.
- **Room overlay restore edge**: `_restoreRoomStateFromOverlay()` already calls `updatedfetchRoomById(..., pass)` and `fetchOnlineUsersFromRoom()`, then falls back to `loginRoom()` when seats list empty. This matches the intended fix and reduces flicker; ensure backend `/room/{id}` always returns users/admin/top to avoid empty states.
- **Chat entry overlay duration**: `_entryUiDurationMs` hardcoded to 6000ms in `ChatSection`; if the requirement is 5500ms, this needs alignment.

---

## Remaining Questions

1. Should `ApiService` be centrally injected everywhere (e.g., `RoomCubit`) via `sl<ApiService>()` to ensure consistent interceptors/debounce?
2. Confirm the design choice to force LTR across languages. Any screens require RTL mirroring?
3. Is `initializeAppwriteDeferred()` called elsewhere? If Appwrite realtime is critical, schedule it after first frame in `main.dart`.
4. Are the misspelled asset directories intentional (compatibility with CDN/backend) or should we standardize naming?
5. Overlay restore: any backend constraints for `/room/{id}?pass=` when restoring (rate limits, larger payload)? If heavy, should we switch to a staged fetch (room→admins→users)?

---

## Quick References (by file)

- Entry: `lib/main.dart`, `features/splash/presentation/views/splash_view.dart`
- DI: `lib/core/service_locator.dart`, `lib/core/initialization/app_initializer.dart`
- Network: `lib/core/services/api_service.dart`, `lib/features/tasks/data/datasources/tasks_api_service.dart`
- Room: `lib/features/room/presentation/views/widgets/room_view.dart`, `.../room_view_body.dart`, `.../chat_section.dart`, `.../gift_overlay.dart`
- Overlay: `lib/core/widgets/overlay/page.dart`, `.../defines.dart`, `features/room/presentation/views/widgets/room_view_bloc.dart`
- Audio: `lib/internal/sdk/express/express_service.dart`, `lib/internal/sdk/livekit/livekit_audio_service.dart`, `lib/zego_sdk_manager.dart`, `lib/live_audio_room_manager.dart`
- State: `lib/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart`, `.../language_cubit.dart`, many cubits under `features/**/manger/**`
- Storage: `lib/core/services/auth_service.dart`, `lib/core/services/secure_storage_service.dart`, `lib/core/cache/room_details_cache_manager.dart`
- Localization: `lib/l10n/*.arb`, `lib/l10n/l10n.dart`, `lib/generated/l10n.dart`

---

## Notes for Future Work

- Use this index as the canonical reference for onboarding and code navigation.
- Keep it updated when adding features (add pointers in Relevant Files and Flows sections).
- Consider adding lightweight architecture diagrams if flows change significantly.
