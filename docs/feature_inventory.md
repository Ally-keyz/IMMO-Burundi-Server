# IMMO BURUNDI Mobile — Feature Inventory (checklist)

**Source of truth:** the live website at `apps/web` + `apps/api` (read 2026-09-30).
**Scope:** normal users only. Agent and admin surfaces are **excluded**.
**Media rule:** images only. The website's two hero videos
(`apps/web/public/assets/videos/vid.mp4`, `the-skyline-penthouse.mp4`) are
**excluded (images only)**.

Status legend: `[ ]` not started · `[~]` in progress · `[x]` done

> **Progress note (2026-10-01).** The checklist below was extracted from the
> website as a *specification*. It is not a live status board: sections are only
> ticked off once the mobile behaviour is implemented and covered by a test.
> Sections 7 (E1–E5), 8 (P1–P9) and 15/16 are reconciled with the code as of
> this date, and G10/G11 were implemented and covered by tests in the same pass.
> The remaining sections are still to be walked item by item against
> `mobile/test`. Treat an unticked box as "not yet verified", not "not built".

---

## 1. Design tokens (extracted from the website)

### 1.1 Light mode — `apps/web/src/index.css` `:root`

| Token | RGB | Hex | Use |
| --- | --- | --- | --- |
| `--immo-bg` | 255 255 255 | `#FFFFFF` | page background |
| `--immo-surface` | 255 255 255 | `#FFFFFF` | cards, app bar, sheets |
| `--immo-text` | 25 25 25 | `#191919` | primary text |
| `--immo-text-2` | 107 107 107 | `#6B6B6B` | secondary / meta text |
| `--immo-text-3` | 158 158 158 | `#9E9E9E` | tertiary text |
| `--immo-text-placeholder` | 117 117 117 | `#757575` | input placeholder |
| `--immo-field` | 247 247 247 | `#F7F7F7` | input fill, section band |
| `--immo-border` | 229 229 229 | `#E5E5E5` | hairline border |
| `--immo-subtle` | 247 247 247 | `#F7F7F7` | section band |
| `--immo-ink` | 25 25 25 | `#191919` | near-black pill button |
| `--immo-accent` | 255 225 53 | `#FFE135` | banana yellow accent |
| `--immo-accent-strong` | 230 178 0 | `#E6B200` | deeper yellow |
| `--immo-brand` | 0 87 255 | `#0057FF` | **primary brand blue** |
| `--immo-on-accent` | 25 25 25 | `#191919` | text on yellow |
| `--immo-tile-accent` | 27 95 255 | `#1B5FFF` | filter tile overlay |
| `--immo-tile-navy` | 4 21 29 | `#04151D` | "Featured" tile |
| `--immo-verified` | 22 163 74 | `#16A34A` | verified badge |
| `--immo-partial` | 202 138 4 | `#CA8A04` | partially verified badge |
| `--immo-danger` | 220 38 38 | `#DC2626` | not-verified / error |

Brand scale (Tailwind `brand`): 50 `#EEF4FF` · 100 `#DBE7FF` · 200 `#B8CEFF` ·
300 `#85AAFF` · 400 `#4D86FF` · 500 `#1E6BFF` · 600 `#0057FF` · 700 `#0043CC` ·
800 `#003599` · 900 `#002A7D` · 950 `#001A4D`.

> **Note:** the website does **not** redefine `--immo-accent` or `--immo-brand` in
> dark mode. We preserve that — brand blue and yellow are constant across modes,
> only the neutrals invert.

### 1.2 Dark mode — `apps/web/src/index.css` `.dark`

| Token | Hex |
| --- | --- |
| `--immo-bg` | `#000000` (pure black) |
| `--immo-surface` | `#181818` |
| `--immo-text` | `#F0F0F0` |
| `--immo-text-2` | `#A3A3A3` |
| `--immo-text-3` | `#737373` |
| `--immo-text-placeholder` | `#737373` |
| `--immo-field` | `#1F1F1F` |
| `--immo-border` | `#303030` |
| `--immo-subtle` | `#181818` |
| gray 300 / 400 / 600 / 700 / 800 | `#404040` `#737373` `#A3A3A3` `#D4D4D4` `#E5E5E5` |
| `--immo-accent`, `--immo-brand` | **carried over from `:root`** |

### 1.3 Radii, spacing, elevation

`--radius-sm` 8 · `--radius-md` 10 · `--radius-lg` 12 · `--radius-xl` 16 ·
`--radius-tile` 8 · `--radius-card-image` 8 · `--radius-pill` 999.
`--shadow-soft` `0 1px 2px rgb(25 25 25/.04), 0 2px 10px rgb(25 25 25/.05)` ·
`--shadow-pop` `0 4px 16px rgb(25 25 25/.08), 0 8px 28px rgb(25 25 25/.1)`.
Spacing uses **4px increments** (Tailwind default). Tailwind shadows map to
Flutter: `soft` ≈ `(0,1,2,.05)`, `pop` ≈ `(0,6,20,.10)`.

### 1.4 Typography — website scale

Roboto. `h1` 28/700 · `h2` 16/500 · `h3` 14 · `body` 14/1.5 · `meta` 12 ·
`ui` 14/1.4 · `search` 14 · `bigstat` 36/1.1 · `card-agent` 13 ·
`card-title` 13 · `card-price` 13 · `card-loc` 12.
Display stack: `"YouTube Sans", Roboto, Inter, …` (we use Roboto only).

### 1.5 Assets

| Asset | Path | Use |
| --- | --- | --- |
| Logo (full) | `apps/web/public/assets/brand/logo.png` (51 KB) | top app bar, splash |
| Logo (cropped) | `apps/web/public/assets/brand/logo-crop.png` (40 KB) | app icon source |
| Favicon | `apps/web/public/favicon.svg` | launcher / in-app |
| **Lottie opening** | **`apps/web/src/assets/lottie/home.json` (142 KB)** | **splash animation** — used by `components/loading/LoadingScreen.tsx:21` |
| OG image | `apps/web/public/og-image.png` | share fallback |
| Empty-state art | `apps/web/public/no_content_illustration_v4.svg` (+ dark variant) | empty states |
| Empty-state art | `apps/web/public/start_searching_dark.svg` | empty state |
| Web manifest | `apps/web/public/site.webmanifest` | reference for app name/colors |

### 1.6 Number / currency / date formats

| Concern | Website behaviour | Reuse in app |
| --- | --- | --- |
| Default currency | **BIF** (Burundian Franc) | same |
| Alternate currency | **USD** | same |
| Fallback rate | `DEFAULT_EXCHANGE_RATE_USD_BIF = 2850` | same |
| Live rate | `GET /api/geo/exchange-rates` | same |
| Persistence key | `immo_currency` | `SharedPreferences` |
| MSISDN format | `79 11 10 01` groups | same (`formatMsisdn`) |
| MSISDN validation | strip `+`/`00`/`257`/`0`, then `^[267]\d{7}$` | same (`isValidBurundiMsisdn`) |
| Date display | `Intl` with **hardcoded `en-GB`** on the site | **route through active locale** (fixes site bug #M3) |
| `timeAgo` | hardcoded **English** on the site | **route through active locale** |
| Number grouping | hardcoded `en-US` on the site | **route through active locale** |

### 1.7 Translations

- File: `apps/web/src/i18n/translations.ts` (111 KB).
- Structure: flat `Record<string, string>` with dotted keys (`'common.currency'`).
- `en` is the **source of truth** (complete); `frOverrides` and `swOverrides` are
  partial overlays merged over `en`. Default language = **`fr`**.
- Supported: **fr, en, sw**. Interpolation uses `{param}` placeholders.
- → Converted to Flutter ARB in Phase 3; all three languages shipped.

---

## 2. Feature checklist — BROWSE (unauthenticated allowed)

- [ ] **B1** Home feed — sections in order: hero, category tiles, Recently added,
      Popular locations, Verified properties. *(Recommended section is gated on
      `isAuthenticated || hasSearchedBefore()` — the app uses
      `immo.searched` equivalent.)*
      API: `GET /properties/recent`, `/properties/featured`, `/properties/verified`,
      `/properties/popular-locations`. Auth: none.
- [ ] **B2** Hero search bar — text field + submit → Search tab with `q`.
- [ ] **B3** Category tiles — 3 hero tiles (`for-you` → Search, `saved` → Saved tab
      or Login, `featured` → Featured) + 7 photo tiles (apartments, houses, villas,
      land, commercial, rentals `?listingType=RENT`, for sale `?listingType=SALE`).
- [ ] **B4** Popular locations grid — 2-up on phone, each → Search filtered by
      province, shows listing count. Background = featured photo or gradient.
- [ ] **B5** Category listing page (`CategoryListingPage` shared shell) with 6 presets:
      | Preset | Fixed query |
      | --- | --- |
      | Buy | `listingType=SALE` |
      | Rent | `listingType=RENT` |
      | Land | `propertyType=LAND` |
      | Commercial | `propertyType=COMMERCIAL` |
      | Featured | `isFeatured=true` |
      | Verified | `verificationStatus=VERIFIED` |
- [ ] **B6** Infinite scroll + pagination in every listing (site paginates; app
      scrolls).
- [ ] **B7** Empty state with illustration + "Reset filters" / "Open search" action.
- [ ] **B8** Error state + retry on every feed.
- [ ] **B9** Pull-to-refresh on every scroll view.
- [ ] **B10** Skeleton shimmer loaders on every feed and grid.

---

## 3. Feature checklist — SEARCH

- [ ] **S1** Full-screen search surface (slides up over current route).
- [ ] **S2** Search field becomes the app bar while searching; back returns.
- [ ] **S3** Recent searches — persisted locally, individually removable,
      "Clear all".
- [ ] **S4** Suggestions while typing (recent + category names).
- [ ] **S5** Results as **compact list cards** (168×94dp leading image).
- [ ] **S6** Filter chips row (property/listing type quick filters).
- [ ] **S7** **Filters bottom sheet**, grouped, sticky Apply/Reset footer, with an
      **active-count badge** on the Filter pill:
      - listing type — `SALE, RENT, LEASE, AUCTION, INVESTMENT` (5)
      - property type — `HOUSE, APARTMENT, VILLA, LAND, SHOP, OFFICE, WAREHOUSE,
        COMMERCIAL, INDUSTRIAL, FARM, HOTEL, GUEST_HOUSE, OTHER` (13)
      - price min / max
      - surface min / max
      - bedrooms min
      - province / commune (cascading, from `/geo`)
      - verification status — `VERIFIED, PARTIAL, NOT_VERIFIED, FULLY_VERIFIED` (4)
      - featured toggle
- [ ] **S8** Sort bottom sheet (radio) — `newest`, `priceAsc`, `priceDesc`, `views`,
      `featured`.
- [ ] **S9** Filter/sort state synced to the URL query string (shareable).
- [ ] **S10** Result count with singular/plural + `aria-live` equivalent.

> **Known website gaps carried over (not invented, not filled):**
> - **No bathroom filter.** — gap, do not add.
> - **No zone/neighbourhood filter.** — gap, do not add.
> - Sort bug: the site sends `sortBy=stats.views` but the API only matches `views`,
>   so "sort by views" silently falls back to date order. **The app sends `views`
>   correctly** — fixing it, not changing scope.

---

## 4. Feature checklist — PROPERTY DETAIL

Mirrors the YouTube watch page, images only.

- [ ] **P1** Full-bleed 16:9 **image gallery** at the top, `PageView`.
- [ ] **P2** **Image-count badge** `3/12` in the image corner (replaces duration
      badge).
- [ ] **P3** Page-indicator pill / dot row.
- [ ] **P4** Tap image → **full-screen viewer**: pinch-to-zoom, swipe-to-dismiss,
      counter, close button.
- [ ] **P5** Primary + localized title (`title`, `titleFr`, `titleEn`, `titleSw`).
- [ ] **P6** **Price line**, currency-aware, BIF ⇄ USD conversion.
- [ ] **P7** Stat/meta line — views · favourites · published `timeAgo`.
- [ ] **P8** Location line — zone / commune / province, with `locationPrecision`
      respected (do **not** expose lat/lng when `HIDDEN`).
- [ ] **P9** **Verification badge** — `VERIFIED` / `FULLY_VERIFIED` / `PARTIAL` /
      `NOT_VERIFIED`, plus the **verification disclaimer** text (version
      `2025-01`, `VERIFICATION_DISCLAIMER`).
- [ ] **P10** **Horizontally scrollable capsule action row**: Save, Share, Report,
      and (auth) Book visit, plus Rent/Buy apply where applicable.
- [ ] **P11** **Agent row** — avatar, name, agency name, stats.
      Contact actions: **call** (`tel:`) + **WhatsApp** (`https://wa.me/`).
      **No follow/subscribe** — the site has none (see Q3).
- [ ] **P12** **Expandable description** (clamped ~2 lines → expand in place).
- [ ] **P13** **Features / amenities** section — `surfaceArea, bedrooms, bathrooms,
      rooms, floors, parkingSpaces, yearBuilt, isNegotiable`.
- [ ] **P14** **Map** section — single property marker. Emitted only when
      `locationPrecision !== 'HIDDEN'`.
- [ ] **P15** **Questions (Q&A)** section — ⚠️ *client-local only on the website*,
      see Q1.
- [ ] **P16** **Related properties** compact-card feed below.
- [ ] **P17** Share — native share sheet + WhatsApp deep link + copy link.
- [ ] **P18** **Report** — bottom sheet, `resourceType='Property'`, reason enum
      (8 reasons) + optional description → `POST /api/reports`.
- [ ] **P19** Error state (noindex equivalent) + retry when the property 404s.
- [ ] **P20** Badges row — `featured`, `isNew`, `isPromoted`.

---

## 5. Feature checklist — SAVED / ACTIVITY (authenticated)

- [ ] **V1** **Save / unfavourite** toggle on card, detail, overflow sheet.
      `POST /api/properties/:id/favorite` (idempotent) — optimistic UI + haptic.
- [ ] **V2** **Favourites list** — `GET /api/favorites`, paginated.
- [ ] **V3** **Recent views** — `GET /api/users/me/recent-views`.
- [ ] **V4** Badge counts (favourites, visits, applications) matching the site's rail.
- [ ] **V5** Remove from favourites with optimistic undo snackbar.

---

## 6. Feature checklist — VISIT BOOKING

- [ ] **BVK1** List **visit sessions** for a property — `GET
      /api/visits/sessions/property/:propertyId` (public). Shows date, start/end
      time, `capacityRemaining`, `isFull`.
- [ ] **BVK2** **Book a session** — number of people (≥1) + notes →
      `POST /api/visits/book` with `visitSessionId`.
- [ ] **BVK3** **Any-time booking** — preferred date, start time, people, notes →
      `POST /api/visits/book` with `propertyId`.
- [ ] **BVK4** Error mapping: `ALREADY_BOOKED` (409), `SESSION_UNAVAILABLE` (409),
      `BOOKING_TARGET_REQUIRED` (400).
- [ ] **BVK5** Success sheet showing **`bookingReference`** (`VIS-BDI-…`).
- [ ] **BVK6** **My bookings** list — `GET /api/visits/bookings/my`, with status
      chips (`PENDING, CONFIRMED, COMPLETED, CANCELLED, NO_SHOW`).
- [ ] **BVK7** **Cancel a booking** — `PATCH /api/visits/bookings/:id/cancel`
      (idempotent).
- [ ] **BVK8** Date + time pickers as bottom sheets.

---

## 7. Feature checklist — ENQUIRY / RENTAL APPLICATION

- [x] **E1** **Send an enquiry** — subject + message →
      `POST /api/enquiries` (`propertyId`, auto-routes to owner/landlord/agent).
- [x] **E2** **My enquiries** — `GET /api/enquiries`, status chips
      (`NEW, OPEN, IN_PROGRESS, RESPONDED, DEAL_AGREED, CLOSED`).
- [x] **E3** **Rental application** (RENT/LEASE only) → `POST
      /api/rental-applications`: full name, phone, email, address,
      totalOccupants, numberOfChildren, occupation, advanceAvailable, moveInDate.
      Rejected client-side with `NOT_A_RENTAL` if the listing isn't a rental.
- [x] **E4** **My applications** — `GET /api/rental-applications/my`, status chips
      (`SUBMITTED, UNDER_REVIEW, SHORTLISTED, ACCEPTED, REJECTED, WITHDRAWN`).
- [x] **E5** **Withdraw** an application (applicant-only transition).

> ⚠️ `enquiriesApi.inbox` and `setStatus` are **agent-side** → excluded.

Notes: the enquiry is a bottom sheet on the property (`property_actions.dart`);
the application is a full screen at `/property/:id/apply` because it is nine
fields. Both list screens live under the **You** tab (`/you/enquiries`,
`/you/applications`). The application button is only rendered for a RENT/LEASE
listing, and a `NOT_A_RENTAL` rejection from the server is surfaced as readable
copy. Name, phone and email are pre-filled from the session but stay editable —
the API wants the applicant's details, not the account holder's.

---

## 8. Feature checklist — PAYMENT LINK (post-agreement)

- [x] **P1** Deep link `immo://pay/<token>` and route `/pay/:token`.
- [x] **P2** **Resolve** the link — `GET /api/payment-links/r/:token`.
      Renders: property (title, id, listing type, thumbnail, price), payee name,
      amount, currency, note, expiry.
- [x] **P3** Status handling for all 6 states — `CREATED`, `SENT`, `OPENED`,
      `PAID`, `CANCELLED`, `EXPIRED`.
- [x] **P4** **Mobile-money provider selection** — `LUMICASH` (Lumitel/Viettel,
      `*226#`), `ECOCASH` (Econet Leo, `*722#`), `IHELA` (iHela CU, `*434#`).
      Brand colors: `#EE0033`, `#FFCC00`, `#0F766E`.
- [x] **P5** **MSISDN input** with live `79 11 10 01` formatting and
      `^[267]\d{7}$` validation.
- [x] **P6** **Pay** — `POST /api/payment-links/r/:token/pay` →
      `paymentReference`, `status`, `paidAt`, `propertyMarkedSold`.
- [x] **P7** Success screen — reference, amount, date. Snackbar + haptic.
- [x] **P8** Failure/expired/cancelled states with a clear next action.
- [x] **P9** Reachable **without authentication** (matches the site).

Notes: `CREATED`, `SENT` and `OPENED` all render the same pay form — they differ
only in who has seen the link, and the payer still has to act on all three.
`PAID`, `CANCELLED` and `EXPIRED` are terminal and never show the form. Operator
chips carry the brand colour and the localized name; the selected operator's
dialling code and network are shown above the number so the payer can match it
against their handset.

---

## 9. Feature checklist — NOTIFICATIONS

- [ ] **N1** **Notification list** — `GET /api/notifications`, newest first,
      unread visually distinct.
- [ ] **N2** **Unread badge** — `GET /api/notifications/unread-count` on the bell.
- [ ] **N3** **Mark one read** — `PATCH /api/notifications/:id/read`.
- [ ] **N4** **Mark all read** — `POST /api/notifications/read-all`.
- [ ] **N5** **Realtime push** — Socket.IO `notification:new` (room `user:<id>`),
      with a **20s polling fallback** like the site.
- [ ] **N6** Render the 20 notification types with the right icon/colour:
      `PROPERTY_APPROVED, PROPERTY_REJECTED, PROPERTY_CORRECTION_REQUIRED,
      VERIFICATION_COMPLETED, PAYMENT_RECEIVED, VISIT_CONFIRMED, VISIT_CANCELLED,
      RENTAL_APPLICATION_UPDATED, PROMOTION_ACTIVATED, NEW_ENQUIRY, NEW_MESSAGE,
      FAVORITE_SOLD, FAVORITE_RENTED, FAVORITE_ARCHIVED, PROPERTY_PUBLISHED,
      NEW_VISIT_BOOKING, NEW_RENTAL_APPLICATION, NEW_PROPERTY_SUBMITTED,
      NEW_VERIFICATION_REQUEST, SYSTEM`.

---

## 10. Feature checklist — AUTH

- [ ] **A1** **Splash** — Lottie `home.json` full-screen on themed background,
      then route by session state. Never blocks longer than the animation.
- [ ] **A2** **Sign in** — `identifier` (phone **or** email) + password →
      `POST /auth/login`. Redirect: `MAIN_ADMIN` → dashboard, else Home.
      Validation: identifier ≥3, password ≥1.
- [ ] **A3** **Sign in with Google** — `POST /auth/google` with an ID token.
      Native Google Sign-In (no webview).
- [ ] **A4** **Sign up** — 2 steps (full name + phone → email + password) →
      `POST /auth/register`. Validation: names 1–80, phone 6–30, password 8–128.
      Role is forced to `CUSTOMER`/`CLIENT` server-side.
- [ ] **A5** **Account setup** (token link) — `GET /auth/setup/:token` then
      `POST /auth/setup/:token` with a new password. Handles
      `SETUP_LINK_INVALID` (400) and `SETUP_LINK_USED` (410). Deep-linked.
- [ ] **A6** **Session bootstrap** — read refresh token → `POST /auth/refresh` →
      `GET /auth/me`. Clears tokens on failure.
- [ ] **A7** **Sign out** — `POST /auth/logout` with the refresh token, then clear
      local state.
- [ ] **A8** **Token refresh interceptor** — on 401, refresh once and retry;
      coalesce concurrent refreshes (the site does this via `refreshPromise`).
- [ ] **A9** Show/hide password toggle on every password field.
- [ ] **A10** Inline validation + button loading states on all auth screens.
- [ ] **A11** Auth error mapping: `INVALID_CREDENTIALS`, `ACCOUNT_SETUP_REQUIRED`,
      `ACCOUNT_INACTIVE`, `PHONE_TAKEN`, `EMAIL_TAKEN`, `AGENT_SELF_REGISTRATION_DISALLOWED`,
      `GOOGLE_NOT_CONFIGURED`, `INVALID_GOOGLE_TOKEN`, `UNVERIFIED_EMAIL`,
      `TOKEN_EXPIRED`, `REFRESH_REVOKED`.

> **Not implemented — no backend support (see Q5):** forgot/reset password,
> email verification, OTP. The site's OTP endpoint is a stub that always returns
> `verified: true`, so it is deliberately **excluded** from the app.

---

## 11. Feature checklist — "YOU" TAB

- [ ] **Y1** Header — avatar (72dp), name, email.
- [ ] **Y2** **Horizontal shortcut row**: Saved, Visits, Applications, Recent views.
- [ ] **Y3** Grouped list — *Account*: Edit profile, Settings, About, Privacy,
      Terms, Cookies, Verification disclaimer, Help/Feedback, Sign out.
- [ ] **Y4** Section badges for unread notifications and pending counts.
- [ ] **Y5** Account menu sheet (from the top-bar avatar) — quick jump to Saved,
      Visits, Applications, Settings, Sign out.

---

## 12. Feature checklist — SETTINGS

YouTube path: **avatar → Settings**, pushed route, grouped list, thin outline
icons (filled when selected), small uppercase group headers.

- [ ] **T1** *Account* → **Edit profile**: firstName, lastName, email, phone,
      preferred language, preferred currency → `PATCH /api/users/:id`.
- [ ] **T2** *Account* → **Change profile picture**: camera or gallery, preview,
      crop, upload → `POST /api/files/upload` then save `photoUrl`.
      Remove → `photoUrl: ''`.
- [ ] **T3** *Account* → **Change password**: requires `currentPassword` for
      self-service; new password 8–128.
- [ ] **T4** *Appearance* → **Theme: Use device theme / Light theme / Dark theme**,
      applied instantly, persisted.
- [ ] **T5** *Language* → **fr / en / sw**, persisted, applied instantly. Synced
      from the user profile when signed in.
- [ ] **T6** *Currency* → **BIF / USD**, persisted, with live conversion.
- [ ] **T7** *Notifications* → screen exists but read-only (no backend prefs — Q4).
- [ ] **T8** *Privacy & legal* → Privacy Policy, Terms, Cookie Policy,
      Verification disclaimer.
- [ ] **T9** *About* → app name, **version**, build number, website link.
- [ ] **T10** *Help* → contact (phone / email / WhatsApp to IMMO BURUNDI).
- [ ] **T11** *Sign out* at the bottom of the last group.
- [ ] **T12** *Clear local cache* (image cache + local search history).

> **Not implemented — no backend support (Q4, Q5):** notification preferences,
> account deletion / deactivation, data & privacy controls, download settings.

---

## 13. Feature checklist — AGENTS

- [ ] **AG1** **Agent directory** — `GET /api/agents`, paginated, search by
      `q` (code / agency / name), filter `province`, `topAgent`.
- [ ] **AG2** **Agent profile / channel** — `GET /api/agents/:id`.
      Tabs: **Listings**, **Sold**, **About**.
- [ ] **AG3** Contact actions — call (`tel:`) + WhatsApp
      (`https://wa.me/<digits>?text=<localised enquiry>`).
- [ ] **AG4** Ratings + transactions section — read-only
      (`rating`, `reviewsCount`, `totalDeals`, `totalSales`, `totalRentals`).
      Copy mirrors the site: "written reviews are coming soon".
- [ ] **AG5** Agent's listings grid — `GET /api/properties?agentId=`.
- [ ] **AG6** Agents are **walled off** from the browse surface — replicate
      `NonAgentRoute` (agents are redirected away from Home/Explore/Search).

---

## 14. Feature checklist — LEGAL & INFO

- [ ] **L1** About
- [ ] **L2** Privacy Policy
- [ ] **L3** Terms & Conditions
- [ ] **L4** Cookie Policy
- [ ] **L5** Verification Disclaimer (`VERIFICATION_DISCLAIMER`, version `2025-01`)
- [ ] **L6** Not-found screen

---

## 15. Feature checklist — GLOBAL UX

- [x] **G1** Skeleton shimmer loaders everywhere
- [x] **G2** Empty states with illustration + one primary action
- [x] **G3** Error states with message + Retry
- [x] **G4** **Offline banner** (connectivity_plus)
- [x] **G5** Snackbars for save / share / book / pay / report
- [x] **G6** Pull-to-refresh everywhere
- [x] **G7** Haptic feedback on save, book, pay
- [x] **G8** Optimistic UI for save/unfavourite
- [x] **G9** Image placeholders + disk/memory cache + progressive loading
- [x] **G10** Accessibility — 48dp tap targets, contrast, font scaling, semantic
      labels. Tap targets are enforced by `AppSpacing.tapTarget` and a large-font
      regression test. Semantics: every `AppButton` and `AppIconButton`, the
      shell tabs, `PropertyCard` (one merged node labelled with title, price,
      location and room counts — the save heart stays reachable on its own) and
      the icon-only `SaveButton` (announced as "Save this property" /
      "Remove from saved" rather than an unnamed button). Two semantics tests in
      `test/features/screens_test.dart` walk the real tree and both fail if the
      labels are removed.
- [x] **G11** Responsive — phone single column; tablet (≥600dp) multi-column
      grid. `Breakpoints.feedColumns` drives `PropertyFeed` (shared by search and
      saved), the search results sliver grid and the Explore category/agent
      grids: 1 column on a phone, 2 at ≥600dp, 3 at ≥840dp. `ResponsiveCenter`
      caps single-column content (forms, settings, profile, row-style lists) at
      640dp so it does not stretch across a tablet. Six tests in the
      `tablet layout` group assert the column count from real card positions at
      390/820/1280dp.
- [x] **G12** Colors only from `ThemeData`/`ColorScheme` — **never hard-coded**
- [x] **G13** Strings only from ARB/l10n — **never hard-coded**
- [x] **G14** API base URL only from config — **never hard-coded**
- [x] **G15** Smooth tab transitions + push/pop page transitions

---

## 16. Feature checklist — IMAGES ONLY (explicit exclusions)

| Website feature | Status |
| --- | --- |
| Hero background video `/assets/videos/vid.mp4` (18 MB) | **excluded (images only)** — replaced by a static hero image |
| Hero background video `the-skyline-penthouse.mp4` (7.5 MB) | **excluded (images only)** |
| YouTube Shorts / vertical feed | **excluded (images only)** — no site equivalent |
| Video player, autoplay, PiP, mini player | **excluded (images only)** — no site equivalent |
| `video_player` / `better_player` / `chewie` packages | **must not appear in `pubspec.yaml`** |
| Video widgets in any `.dart` file | **must not exist** |
| YouTube Playlists | **excluded** — no site equivalent |
| YouTube Downloads | **excluded** — no site equivalent |
| YouTube "Your videos" | **excluded** — agent-side only |

**The only animation asset is the Lottie file** `apps/web/src/assets/lottie/home.json`.

Verified as of 2026-10-01: no `video_player`, `better_player` or `chewie` in
`pubspec.yaml`, and no video widget in any `.dart` file. `lottie` is present and
used for the splash only.

---

## 17. Backend gaps — questions (do **not** guess)

| # | Question |
| --- | --- |
| **Q1** | Property **Questions** are client-local `useState` on the website — nothing persisted, no API, always labelled "You / now". Options: (a) replicate local-only, (b) omit, (c) add a backend endpoint? |
| **Q2** | `messagesApi.listConversations` (`GET /api/messages/conversations`) exists but the website has **no UI** for it. Build a threaded inbox, or omit? |
| **Q3** | Confirm the agent affordance is **only** call + WhatsApp — there is no follow/subscribe anywhere (only dead translation keys). |
| **Q4** | **Notification preferences** — the `NotificationPreference` model exists but is never read by the API. Local-only preferences screen, or omit? |
| **Q5** | Confirm the app ships **only** login / register / Google / account-setup. No password reset, no email verification, no account deletion, and OTP is a backend stub. |
| **Q6** | Province list: the API seeds **15** provinces, the website's SEO layer advertises **18**. Which list should the province filter use? |
| **Q7** | Confirm the final tab set. Proposed: **Home · Explore · Saved · You** (4 tabs, mirroring YouTube minus Shorts). Payment links are reached from a notification or deep link. |
| **Q8** | **Deep link host** for `immo://pay/<token>` — which domain scheme should the app register for App Links / Universal Links (e.g. `immoburundi.bi`)? |
| **Q9** | The website's `ContactActions.tsx` component is **dead code** (never imported) and offers extra actions (message, rental apply, buy request). Should the app use the live behaviour (`PropertyDetailPage` + `ContactAgentModal`) or the dead component's wider action set? |
