# IMMO BURUNDI Mobile — App Architecture

Target: Flutter 3.38.5 · Dart 3.10.4 · Material 3
Location: `mobile/` (sits beside `apps/`, `packages/`, `docs/`)

---

## 1. Guiding constraints

1. **Structure from YouTube, colour from IMMO.** Every colour, string and URL
   lives in a config/theme/l10n file. No widget hard-codes a hex, a literal string
   or a hostname.
2. **Images only.** No video package may appear in `pubspec.yaml`.
3. **Same backend.** The existing `apps/api` is reused verbatim. No new backend.
4. **No fake data in the shipped build.** Mock data only behind
   `--dart-define=USE_MOCK=true`.
5. **Feature-first clean architecture.** Each feature owns its own
   data → domain → presentation, and depends only on `core/`.

---

## 2. Package selection

| Concern | Package | Why |
| --- | --- | --- |
| State management | **`flutter_riverpod` ^2.6** | see §3 |
| Networking | **`dio` ^5.7** | interceptor chains are the core requirement (auth attach + single-flight refresh + error mapping). `http` would mean hand-rolling all three. |
| Routing | **`go_router` ^14.6** | `StatefulShellRoute.indexedStack` gives per-tab history **and** scroll-position preservation for free; declarative `redirect` can gate on auth. |
| Secure storage | **`flutter_secure_storage` ^9.2** | Keychain / EncryptedSharedPreferences for the token pair. |
| Preferences | **`shared_preferences` ^2.3** | theme, locale, currency, recent searches, filter presets. |
| Images | **`cached_network_image` ^3.4** + **`flutter_cache_manager` ^3.4** | disk + memory cache, progressive load, placeholder/fade. |
| Skeletons | **`shimmer` ^3.0** | YouTube-style shimmer feed. |
| Lottie splash | **`lottie` ^3.1** | the website's `home.json`. |
| Localization | **`intl` ^0.19** + **`flutter_localizations`** + **gen-l10n** | ARB → fr/en/sw. |
| Fonts | bundled **Roboto** TTFs | see §7. Avoids `google_fonts`' runtime network fetch. |
| Connectivity | **`connectivity_plus` ^6.1** | offline banner. |
| Haptics | **`flutter_riverpod`** + `HapticFeedback` (SDK) | no package needed. |
| Image picker | **`image_picker` ^1.1** | profile photo (camera + gallery). |
| Crop | **`image_cropper`** or a custom `InteractiveViewer`-based crop screen | profile photo crop |
| Permissions | **`permission_handler` ^11.3** | camera / photos / notifications |
| WebView | **`webview_flutter` ^4.10** | ⚠️ *payment links are a native flow, not a webview* — see §9 |
| URL launcher | **`url_launcher` ^6.3** | `tel:`, `wa.me`, `mailto:`, external browser |
| Share | **`share_plus` ^10.1** | native share sheet |
| JSON | **`json_serializable` + `build_runner`** | see §4 |
| Testing | **`flutter_test`**, **`mocktail` ^1.0**, **`riverpod_test` ^2.6** | |

### Explicitly **not** added (images-only rule)
`video_player`, `better_player`, `chewie`, `media_kit`, `flick`, anything from
`youtube_player_flutter`. Verified absent in Phase 4.

---

## 3. State management — **Riverpod**, justified

**Chosen: `flutter_riverpod` 2.x (no freezed codegen).**

Reasons, in order of weight:

1. **Our state is read-heavy and write-light.** Roughly 90% of app state is
   "fetch once, invalidate later" (feeds, profile, notifications). Riverpod's
   `AsyncNotifier` + `ref.invalidate` expresses that in one line;
   Bloc needs `event → bloc → state` for every screen.
2. **Direct compile-time dependency wiring.** `ref.watch(dioProvider)` replaces the
   website's `<AuthContext>` / `<CurrencyContext>` provider nesting almost 1:1, so
   the mental model transfers straight from the codebase we just read.
3. **Derived state is free.** "Am I signed in?" / "what is the effective theme?" /
   "the favourites count" become `Provider`s instead of manual `useEffect` chains —
   which is how the website currently ends up with stale badges.
4. **Testable without a widget harness.** Providers are overridable in tests, so
   widget tests for auth/like/booking can inject fakes directly.
5. **Avoiding codegen in the theme/route layer** keeps `flutter analyze` fast and
   build failures easy to localise. We use codegen only where it clearly pays:
   `json_serializable`.

We use `flutter_riverpod` (no `riverpod_annotation`) to avoid a second
`build_runner` graph. Two `StateNotifierProvider`s (`auth`, `prefs`) and a set of
`AsyncNotifierProvider`s cover the app.

**Structure:**
```
core providers
   dioProvider ──> ApiClient ──> *Repository
   tokenStoreProvider
   authProvider (StateNotifier<AuthState>)
   prefsProvider (theme / locale / currency)
   connectivityProvider

feature providers
   propertyFeedProvider(arg)   -> paginated PropertySummary list
   propertyDetailProvider(id)
   relatedPropertiesProvider(id)
   agentDetailProvider(id)
   agentListProvider(filters)
   favoritesProvider
   recentViewsProvider
   myBookingsProvider
   myEnquiriesProvider
   myApplicationsProvider
   notificationsProvider
   provincesProvider / communesProvider(provinceId)
   exchangeRatesProvider
   searchHistoryProvider
   savedSearchFilterProvider (StateNotifier, persisted)
   paymentLinkProvider(token)
```

---

## 4. Networking layer

### 4.1 The envelope

The API always answers `{success, data, meta}` or `{success:false, error:{code,
message, details}}` (`apps/api/src/helpers/http.ts`). A single
`EnvelopeInterceptor` unwraps it, so every repository returns the **payload**, not
the envelope.

```dart
// lib/core/network/api_exception.dart
class ApiException implements Exception {
  final int? statusCode;
  final String code;       // e.g. 'SESSION_UNAVAILABLE'
  final String message;    // human-readable, already localised server-side
  final Map<String, dynamic>? details;
}
```

### 4.2 Interceptor chain (order matters)

| # | Interceptor | Job |
| --- | --- | --- |
| 1 | `AuthInterceptor` | attach `Authorization: Bearer <access>` |
| 2 | `RefreshInterceptor` | on 401 → single-flight refresh → replay the queue |
| 3 | `EnvelopeInterceptor` | unwrap `data` / map errors to `ApiException` |
| 4 | `LoggingInterceptor` | behind `--dart-define=LOG_HTTP=true` only |

**Single-flight refresh** — mirrors the website's `refreshPromise`
(`apps/web/src/lib/api.ts:140-174`) but with the correct detail the website
misses: the website's 404 branch wrongly signs the user out, so our interceptor
**only** reacts to `401` + code `UNAUTHORIZED`/`TOKEN_EXPIRED`. A `NOT_FOUND`
passes straight through.

### 4.3 Endpoints

`lib/core/network/api_client.dart` exposes namespaces mirroring `api.ts` 1:1, so
the mapping is auditable:

```
AuthApi        AuthApiClient        propertiesApi  PropertiesApiClient
FavoritesApi   FavoritesApiClient   agentsApi      AgentsApiClient
GeoApi         GeoApiClient         visitsApi      VisitsApiClient
EnquiriesApi   EnquiriesApiClient   rentalApi      RentalApplicationsApiClient
PaymentLinksApi PaymentLinksApiClient
NotificationsApi NotificationsApiClient
UsersApi       UsersApiClient       reportsApi     ReportsApiClient
FilesApi       FilesApiClient       messagesApi    MessagesApiClient
```

Every method mirrors the website's helper **including its query-parameter names**,
so nothing has to be translated at runtime.

### 4.4 Token refresh

`POST /auth/refresh` → `{accessToken, refreshToken}` (the API **rotates** the
refresh token — `apps/api/src/modules/auth/auth.service.ts:395-415`). The old
refresh JTI is blacklisted server-side, so:

- refresh tokens are **single-use**;
- a 401 `REFRESH_REVOKED` means someone else already used it → sign out.

Both tokens are replaced atomically after a successful refresh. A failure clears
storage and drops to unauthenticated.

### 4.5 Errors the UI must special-case

| Code | Screen behaviour |
| --- | --- |
| `ACCOUNT_SETUP_REQUIRED` | route to the setup-account screen |
| `ACCOUNT_INACTIVE`, `UNAUTHENTICATED`, `TOKEN_EXPIRED` | sign out with an explanatory snackbar |
| `INVALID_CREDENTIALS` | inline on the password field |
| `PHONE_TAKEN`, `EMAIL_TAKEN` | inline on the offending field |
| `ALREADY_BOOKED`, `SESSION_UNAVAILABLE` | booking sheet stays open, shows the reason |
| `LINK_EXPIRED`, `LINK_CANCELLED`, `LINK_ALREADY_PAID` | payment screen terminal state |
| `SETUP_LINK_USED` (410) | "this link was already used" screen |
| `PROPERTY_NOT_FOUND`, `NOT_FOUND` | **not-found state — never a sign-out** |

---

## 5. Secure storage

| Key | Store | Contents |
| --- | --- | --- |
| `immo_access_token` | `flutter_secure_storage` | access JWT (15 min) |
| `immo_refresh_token` | `flutter_secure_storage` | refresh JWT (30 d, rotating) |
| `immo_theme` | `shared_preferences` | `device` \| `light` \| `dark` |
| `immo_language` | `shared_preferences` | `fr` \| `en` \| `sw` |
| `immo_currency` | `shared_preferences` | `BIF` \| `USD` |
| `immo_search_history` | `shared_preferences` | JSON array, max 20 |
| `immo_searched` | `shared_preferences` | bool — gates the "Recommended" section |
| `immo_seen_onboarding` | `shared_preferences` | bool |

Android: `encryptedSharedPreferences: true`. iOS: default Keychain with
`accessibility: first_unlock_this_device`.

---

## 6. Local cache / offline

`flutter_cache_manager` for images (1000 files / 30 d). A small
`KeyValueCache` (SharedPreferences + JSON) for **read-mostly reference data** so
the province/commune/currency lists render instantly:

| Cache | TTL | Stale-while-revalidate |
| --- | --- | --- |
| provinces | 24 h | yes |
| communes (per province) | 24 h | yes |
| exchange rates | 1 h | yes |
| property feed page 1 | 5 min | yes (shown, then refreshed) |

Feeds beyond page 1 are **not** cached — a stale price is worse than a spinner.

`connectivity_plus` drives a persistent offline banner and pauses retry loops.

---

## 7. Theme system

**One file owns every colour.** `lib/app/theme/app_colors.dart` holds raw values;
`app_theme.dart` builds two `ThemeData`s (light + dark) from them; widgets only
ever read `Theme.of(context).colorScheme` / `extension`.

```dart
abstract final class AppColors {
  // verbatim from apps/web/src/index.css
  static const brand        = Color(0xFF0057FF);
  static const brandDeep    = Color(0xFF0043CC);
  static const accent       = Color(0xFFFFE135);   // carried into BOTH modes
  static const accentStrong = Color(0xFFE6B200);
  static const verified     = Color(0xFF16A34A);
  static const partial      = Color(0xFFCA8A04);
  static const danger       = Color(0xFFDC2626);

  static const lightBg = Color(0xFFFFFFFF);  static const darkBg = Color(0xFF000000);
  static const lightSurface = Color(0xFFFFFFFF); static const darkSurface = Color(0xFF181818);
  static const lightText = Color(0xFF191919); static const darkText = Color(0xFFF0F0F0);
  static const lightText2 = Color(0xFF6B6B6B); static const darkText2 = Color(0xFFA3A3A3);
  static const lightField = Color(0xFFF7F7F7); static const darkField = Color(0xFF1F1F1F);
  static const lightBorder = Color(0xFFE5E5E5); static const darkBorder = Color(0xFF303030);
}
```

Also:
- `AppSpacing` — 4px increments: `4 8 12 16 20 24 32 40` (+ `pageMargin = 16`,
  matching YouTube).
- `AppRadii` — `sm 8 · md 10 · lg 12 · xl 16 · tile 8 · cardImage 12 · sheet 28 · pill 999`.
  Note: YouTube thumbnails are **12dp**; the site uses 8dp — we follow YouTube per
  the brief, and keep 8dp for dense list rows.
- `AppTypography` — Roboto, matching YouTube: `titleLarge 28/700` (site h1),
  `titleMedium 16/500` (site h2 **and** card title), `bodyMedium 14/400`,
  `labelLarge 14/500` (nav/buttons), `bodySmall 12/400` (meta, `--immo-text-2`),
  `bodySmallDense 13/400` (the site's `--fs-card-title` scale, used in list rows).
- `AppMotion` — `tab 250ms · push 280ms · pop 220ms · sheet 200ms · fade 200ms`,
  all `Curves.easeOutCubic`; shimmer loop 1200ms.
- `ThemeExtension` `ImmoTokens` for the semantic colours Material's
  `ColorScheme` has no slot for (verified / partial / onAccent / tileNavy).

**Roboto is bundled** (`assets/fonts/Roboto-*.ttf`, weights 400/500/700/900)
rather than pulled by `google_fonts`, so the app renders correctly offline and on
first launch.

---

## 8. Localization

- `flutter: generate: true` + `l10n.yaml` → `AppLocalizations` from ARB.
- `lib/l10n/app_en.arb` (**template, complete**), `app_fr.arb`, `app_sw.arb`.
- Generated from the website's `translations.ts` by a one-off Node script
  (`tool/export_translations.mjs`) that flattens the dotted keys
  (`'common.currency'` → `commonCurrency`) and preserves `{param}` placeholders.
  English is the template because it is the complete source; `fr` and `sw` are the
  website's merged overrides — so a missing French key falls back to English,
  **identical to the website's behaviour**.
- Website default language is **`fr`**; the app defaults to `fr` too, then falls
  back to the device locale, then `fr`.
- Supported-ICU so dates/numbers localise: `flutter_localizations` +
  `intl` date symbols. This **fixes** the website's hardcoded `en-GB`/`en-US`
  formatters (finding M3).

---

## 9. Image strategy

### 9.1 Cache + progressive load
`CachedNetworkImage` with:
- `memCacheWidth` set from the render box (avoids decoding a 4000px JPEG into a
  180dp thumbnail),
- `maxWidthDiskCache` sized per use-site,
- a themed shimmer placeholder and a `fadeInDuration: 200ms`,
- `errorWidget` → brand-tinted gradient tile (mirrors the site's
  `MEDIA_PLACEHOLDER_COLORS`).

### 9.2 Right-sized URLs
The API returns whatever the seed produced: Cloudinary `secure_url`s or Unsplash
URLs. Both support on-the-fly transforms, so `lib/core/utils/image_url.dart`
rewrites the URL for the target render size:

| Host | Transform |
| --- | --- |
| `res.cloudinary.com` | insert `/upload/w_<w>,h_<h>,c_fill,q_auto,f_auto/` |
| `images.unsplash.com` | set/replace `?w=<w>&q=<q>&auto=format&fit=crop` |
| anything else | return unchanged |

Thumbnail requests use `w_400`; feed covers `w_800`; detail hero `w_1200`;
full-screen viewer `w_1600` (or the original). This is a real bandwidth win on a
mobile network and mirrors what the website's own seed URLs already do
(`?auto=format&fit=crop&w=1400`).

### 9.3 Gallery memory
`PageView` + `PageController` with `viewportFraction: 1.0`; each page builds its
image at the **current** screen width and only the ±1 neighbours are mounted. Full
-screen viewer uses `InteractiveViewer` with `maxScale: 4`, releases the decoded
bitmap on dismiss, and supports swipe-down-to-dismiss via
`GestureDetector.onVerticalDragEnd`.

### 9.4 Media semantics
`Property.media[]` items carry `isPrimary` (cover image), `sortOrder`,
`mediaType`, `caption`, `url`, `thumbUrl`. The app uses `isPrimary` for the feed
cover and falls back to `media.first` — matching the API's own
`agentPortfolio` logic (`apps/api/src/modules/verification/verification.service.ts:390`).

---

## 10. Routing & deep links

`go_router` with a `StatefulShellRoute.indexedStack` for the shell so each tab
keeps its **history and scroll position** (`PageStorageKey` on every scroll view).

### Shell — 4 tabs (Q7; mirrors YouTube minus Shorts)

| # | Tab | Route | Icon |
| --- | --- | --- | --- |
| 0 | Home | `/home` | `Icons.home_outlined` / `home` |
| 1 | Explore | `/explore` | `Icons.explore_outlined` / `explore` |
| 2 | Saved | `/saved` | `Icons.favorite_border` / `favorite` |
| 3 | You | `/you` | `Icons.person_outline` / `person` |

Tab change = **feed slides up** + cross-fade, 250ms `easeOutCubic` (the shipped
Oct-2025 YouTube behaviour).

### Full route table

```
/splash                              Lottie, no chrome
/onboarding                          3 slides (see §12, question)
/login  /signup  /setup-account/:token

Shell
  /home          Home feed
  /home/see-all  → category listing (buy|rent|land|commercial|featured|verified)
  /explore       categories, popular locations, verified, agents
  /explore/agents
  /saved         favorites | recent views (segmented)
  /saved/visits        my visit bookings
  /saved/applications  my rental applications
  /saved/enquiries     my enquiries
  /you          profile + shortcuts
  /you/notifications

Pushed
  /search                      full-screen search surface
  /search/filters              modal bottom sheet
  /search/sort                 modal bottom sheet
  /property/:id                detail (watch-page layout)
  /property/:id/gallery        full-screen image viewer
  /property/:id/visit          booking sheet
  /property/:id/report         report sheet
  /agent/:id                   agent channel
  /pay/:token                  payment link (unguarded)
  /settings
  /settings/profile  /settings/appearance  /settings/language
  /settings/currency /settings/photo /settings/password
  /about /privacy /terms /cookies /verification-disclaimer
  *                             not-found
```

### Deep links

| URI | Target |
| --- | --- |
| `immo://property/<id>` | `/property/<id>` |
| `immo://pay/<token>` | `/pay/<token>` |
| `immo://agent/<id>` | `/agent/<id>` |
| `immo://setup-account/<token>` | `/setup-account/<token>` |
| `https://www.immoburundi.bi/property/<id>` | same (App Link) |
| `https://www.immoburundi.bi/pay/<token>` | same (App Link) |
| `https://www.immoburundi.bi/immobilier/<slug>` | `/explore/location/<slug>` |

Handled via `go_router` + `app_links`. `<intent-filter>` on Android and
`Associated Domains` on iOS (host — Q8).

**Auth gate.** A `redirect` runs the session check. `/pay/:token` and all auth
routes are **public** (matches the website, where `/pay/:token` has no guard).
Agents are redirected away from the browse tabs, reproducing the website's
`NonAgentRoute`.

---

## 11. Folder structure (feature-first clean)

```
mobile/
  pubspec.yaml
  analysis_options.yaml
  l10n.yaml
  build.yaml
  android/  ios/  web/
  assets/
    fonts/Roboto-{Regular,Medium,Bold,Black}.ttf
    lottie/home.json                    ← from apps/web/src/assets/lottie/
    images/logo.png  logo-crop.png  favicon.svg
    images/empty_no_content.svg  empty_no_content_dark.svg
    images/empty_start_searching.svg  og-image.png
  lib/
    main.dart
    app/
      app.dart                MaterialApp.router + global providers
      router.dart             GoRouter, redirect, deep links
      bootstrap.dart          runApp sequence
      theme/
        app_colors.dart       ← ALL colour constants
        app_theme.dart        light + dark ThemeData
        app_tokens.dart       ThemeExtension (verified/partial/onAccent/…)
        app_spacing.dart      4px scale
        app_radii.dart
        app_typography.dart
        app_motion.dart       durations + curves
      config/
        app_config.dart       env via --dart-define
    core/
      network/
        dio_provider.dart
        api_client.dart
        api_exception.dart
        interceptors/
          auth_interceptor.dart
          refresh_interceptor.dart
          envelope_interceptor.dart
          logging_interceptor.dart
        endpoints/
          auth_api.dart  properties_api.dart  favorites_api.dart
          agents_api.dart  geo_api.dart  visits_api.dart
          enquiries_api.dart  rental_api.dart  payment_links_api.dart
          notifications_api.dart  users_api.dart  reports_api.dart
          files_api.dart
      storage/
        secure_token_store.dart
        prefs_store.dart
        key_value_cache.dart
      models/
        property.dart  user.dart  agent.dart  geo.dart  media.dart
        visit.dart  enquiry.dart  rental_application.dart
        notification_item.dart  payment_link.dart  auth_result.dart
        paginated.dart  api_error.dart
      repositories/
        property_repository.dart  auth_repository.dart  …
      realtime/
        socket_service.dart     Socket.IO + 20s poll fallback
      utils/
        formatters.dart  msisdn.dart  image_url.dart  result.dart
        whatsapp.dart     search_history.dart
      widgets/
        immo_image.dart  skeleton_box.dart  shimmer.dart
        empty_state.dart  error_state.dart  offline_banner.dart
        capsule_button.dart  section_header.dart  filter_chip_row.dart
        bottom_sheet_scaffold.dart  immo_snackbar.dart  avatar.dart
        badge_pill.dart  rating_row.dart  skeleton_property_card.dart
    features/
      splash/       data/ presentation/
      onboarding/   presentation/
      auth/         data/ domain/ presentation/{login,signup,setup_account}/
      shell/        presentation/ (bottom nav, tab shells)
      home/         data/ presentation/
      explore/      data/ presentation/
      category/     data/ presentation/  (shared CategoryListingPage)
      search/       data/ presentation/
      property_detail/ data/ presentation/widgets/
      gallery/      presentation/
      saved/        data/ presentation/
      booking/      data/ presentation/
      payment/      data/ presentation/
      agents/       data/ presentation/
      profile/      data/ presentation/
      settings/     data/ presentation/
      legal/        presentation/
    l10n/           app_en.arb  app_fr.arb  app_sw.arb
  test/
    ...
  tool/
    export_translations.mjs   one-off: translations.ts → ARB
```

Each feature keeps `data/` (api + repository + providers), `domain/` (models +
validation), `presentation/` (screens + widgets). Cross-feature imports are
blocked by convention; `core/` imports nothing from `features/`.

---

## 12. Payments — native, not a webview

The website's payment page is a **native flow**, not a hosted page: resolve the
link, pick one of three mobile-money operators, type a phone number, confirm. So
the app builds it natively and does **not** embed a webview.

```
/pay/:token
  → GET  /payment-links/r/:token          resolve + status
  → (terminal states: PAID | CANCELLED | EXPIRED)
  → choose provider (Lumicash #EE0033 · EcoCash #FFCC00 · iHela #0F766E)
  → MSISDN input, live `79 11 10 01` formatting, ^[267]\d{7}$
  → POST /payment-links/r/:token/pay      { provider, payerPhone }
  → success sheet: paymentReference, amount, paidAt, propertyMarkedSold
```

**No gateway is wired server-side** — the API records a `COMPLETED` payment and
marks the property SOLD (`apps/api/src/modules/paymentLinks/paymentLinks.service.ts:186-288`).
The app must therefore present this as **"payment recorded"**, not "payment settled",
and never claim a bank confirmation it did not receive.

`webview_flutter` is therefore **not** in the dependency list. If the user later
wants a hosted checkout, it drops in then.

---

## 13. Onboarding

The website has **no onboarding**. YouTube has a 3-slide first-run intro. Adding
one is a deviation from "never invent features", so it is gated behind
`--dart-define=ONBOARDING=true` (**off by default**), shown once, skippable, and
persisted in `immo_seen_onboarding`. It introduces *navigation only* — no claims
about features the site does not have.

> **Status: not implemented, and the `ONBOARDING` define has been deleted.**
> The flag below was removed rather than left at `false`, because a switch that
> routes nowhere is a trap: it documented a feature the app does not have, and
> turning it on produced a redirect to a route that was never registered. If
> onboarding is ever wanted, build the screen *and* the route first, then
> reintroduce the flag. The two rows above that mention `/onboarding` and
> `immo_seen_onboarding` are likewise stale; `/` resolves the session directly.

---

## 14. Accessibility & responsiveness

- 48×48dp minimum tap target; `Semantics` labels + state on every icon-only
  control (overflow, gallery counter, save/favourite announced as
  "Save property"/"Saved").
- Contrast: `--immo-text-2` on both surfaces clears **4.5:1**; verified/partial/
  danger on their tints clear 4.5:1 in both modes.
- Respects the OS text-scale factor up to 2.0 without clipping; card titles grow
  to 3 lines before truncating.
- `ScrollConfiguration` without overscroll glow; `Brightness` never forced.
- **Responsive:** phone = 1-column feed, 2-up grids. ≥600dp (tablet) = 2-column
  feed, 3-up grids, ≥840dp = 3-column feed + a permanent `NavigationRail` in place
  of the bottom bar. A `Breakpoints` helper reads `MediaQuery.size`.
- `TextScaler` is never clamped.

---

## 15. Testing plan

| Suite | Covers |
| --- | --- |
| `auth_flow_test` | login → token write → `me` → home; wrong password inline; expired token triggers exactly one refresh + replay |
| `save_flow_test` | optimistic favourite, snackbar, rollback on network failure, idempotent re-tap |
| `booking_flow_test` | pick session → people → confirm → `bookingReference` sheet; `SESSION_UNAVAILABLE` keeps the sheet open |
| `payment_flow_test` | resolve → provider → MSISDN validation (accepts `79 11 10 01`, rejects `30…`) → pay → success |
| `feed_pagination_test` | page 1 → scroll → page 2 appended once, no duplicates |
| `theme_test` | `device/light/dark` persisted and applied |
| `l10n_test` | every `fr`/`sw` key resolves; no missing-message fallback |
| `model_test` | `PropertySummaryDTO` parses the real seeded payload shape |

---

## 16. Build-time configuration

`lib/app/config/app_config.dart` reads `--dart-define` only — never a hard-coded
host in a widget.

| Define | Default | Purpose |
| --- | --- | --- |
| `API_BASE_URL` | `https://immo-api.onrender.com` | prod API origin |
| `ENV` | `prod` | label shown in About |
| `USE_MOCK` | `false` | mock repository (dev only) |
| `LOG_HTTP` | `false` | verbose Dio logging |
| `ONBOARDING` | `false` | enable the first-run intro |
| `SITE_URL` | `https://www.immoburundi.bi` | shown in About, used by deep links |

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000 --dart-define=ENV=dev
```

---

## 17. Open questions carried from Phase 1

See `docs/feature_inventory.md` §17 — **Q1–Q9**. The ones that block or shape the
build:

- **Q1** property Questions — client-local on the site. *(Building it as
  local-only, matching the site, pending your call.)*
- **Q2** `messagesApi.listConversations` has no UI on the site.
- **Q3** confirm agent contact is call + WhatsApp only (no follow).
- **Q4** notification preferences — no backend.
- **Q5** confirm auth is login / register / Google / setup-account only.
- **Q6** 15 vs 18 provinces.
- **Q7** confirm the 4-tab set **Home · Explore · Saved · You**.
- **Q8** deep-link host for App Links.
- **Q9** the dead `ContactActions.tsx` offers more actions than the live UI.

Proceeding with the documented defaults until told otherwise.
