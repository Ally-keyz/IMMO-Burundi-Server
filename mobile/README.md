# IMMO BURUNDI — mobile

Flutter client for IMMO BURUNDI, the property platform for buyers, renters and
owners in Burundi. The public site (`www.immoburundi.bi`) and the API are the
source of truth for behaviour; this app renders the same data for mobile.

Images only — there is no video playback anywhere in the app. `assets/lottie/`
holds the single decorative animation.

## Requirements

- Flutter 3.38.5 (Dart 3.10.4)
- An API to talk to. The defaults point at the deployed service, so
  `flutter run` works with no flags.

## Running

```bash
flutter pub get
flutter gen-l10n                 # after touching anything in lib/l10n/*.arb
flutter run
```

### Configuration

Every environment value comes from `--dart-define`; no hostname is hard-coded
anywhere else. See `lib/app/config/app_config.dart`.

| Define | Default | Notes |
| --- | --- | --- |
| `API_BASE_URL` | `https://immo-api.onrender.com` | API origin, no trailing slash |
| `SITE_URL` | `https://www.immoburundi.bi` | About, share links, deep links |
| `ENV` | `prod` | Shown on the About screen |
| `USE_MOCK` | `false` | Mock repository; never `true` in a release build |
| `LOG_HTTP` | `false` | Verbose request/response logging |

There is no onboarding flag: the website has no first-run intro, and a dead
switch that pretends otherwise is worse than a missing feature.

Against a local API:

```bash
# Android emulator: 10.0.2.2 is the host loopback, localhost is the emulator
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000 --dart-define=ENV=dev

# iOS simulator
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:4000 --dart-define=ENV=dev
```

## Checks

```bash
dart format lib test
flutter analyze
flutter test
```

The test suite runs against the real controllers, the real Dio interceptor
chain and a real `SecureTokenStore`; only the HTTP socket is faked
(`test/support/fake_dio.dart`). That means auth refresh, envelope unwrapping and
pagination are exercised the way the app actually uses them.

### Localization

User-facing strings live in `lib/l10n/app_{en,fr,sw}.arb`. App-only strings are
in `tool/app_overrides.{en,fr,sw}.json`. After editing either, regenerate:

```bash
node tool/export_translations.mjs
flutter gen-l10n
node tool/check_arb_keys.cjs        # must print "no case-insensitive key collisions"
```

Generated output under `lib/l10n/generated/` must not be edited by hand.

The app overlays sit on top of the website's own translations, so a new app-only
key can collide with a site key that differs only in case — `propertyWhatsApp`
against `propertyWhatsapp`, or `enquiryStatusOpen` against `enquiryStatusOPEN`.
JSON and `gen-l10n` both accept that, and Dart happily emits two getters that
differ only in case, so the wrong one compiles and silently shows the wrong
label. `check_arb_keys.cjs` is the guard; run it after every export.

## Layout

```
lib/
  app/          App shell, router, theme, app config
  core/         Models, JSON readers, network stack, storage, shared widgets
  features/     One folder per user-facing area (auth, home, explore, property,
                saved, search, agent, payment, profile, settings, legal, ...)
  l10n/         ARB sources and generated localizations
```

State is Riverpod throughout. Networking is a single Dio chain per purpose:

- `dioProvider` — the app client: auth header, single-flight token refresh,
  envelope unwrapping.
- `bareDioProvider` — no auth and no refresh, so the refresh call itself can
  never recurse. It still unwraps the response envelope, because the API wraps
  every answer.

## Conventions

- Material 3, Roboto (bundled), 4px spacing, light and dark themes.
- Colours live in `lib/app/theme/`; URLs in `lib/app/config/app_config.dart`;
  user-facing text in the ARB files.
- Model constructors are tolerant of the API's TypeScript-shaped DTOs. The
  `as*` readers in `lib/core/models/json.dart` are the single place numbers and
  strings get coerced, so a missing optional field degrades to a default instead
  of throwing.
