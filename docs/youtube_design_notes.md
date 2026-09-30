# YouTube Mobile Design — Research Notes

**Purpose:** a structural specification for the IMMO BURUNDI Flutter app. We adopt
YouTube's *layout, spacing, component behaviour and motion*. We adopt **none** of its
colour. Every colour below is a placeholder for a token that will be filled from the
website's own palette (§7).

**Media rule:** images only. No video player, no video package, no autoplay, no
Shorts-style vertical feed, no mini player. The only animation asset is the website's
existing Lottie file (`apps/web/src/assets/lottie/home.json`).

---

## 1. Sources consulted

| Topic | Source |
| --- | --- |
| Bottom-nav composition & 2026 experiment | Android Authority — *YouTube's latest UI experiment targets how you navigate the app* (2026-05-08) |
| Subscriptions ⇄ You tab swap | Android Authority — *YouTube's latest layout swap is confusing everyone* (2025-11-26) |
| Oct-2025 icon + player redesign | 9to5Google — *YouTube video player redesign & new icons roll out* (2025-10-24); Android Central (2025-10-02) |
| App-wide expressiveness update | Android Authority — *YouTube is starting to roll out major visual changes for everybody* (2025-10-14) |
| June-2026 label-less action row | Android Authority — *YouTube is testing another Android redesign* (2026-06-18) |
| Smart-TV-style player row | Android Police (2024-10-10); Tom's Guide (2024-10-10) |
| Settings → General → Appearance | Google Help — *Watch YouTube in Dark theme* (Android / iOS / Desktop) |
| Material foundation | YouTube Blog — *A new YouTube look that works for you* |

**Currency of the design.** As of 2026 YouTube is mid-experiment. We adopt the
**stable, shipped** layout (the one users actually live in day to day) and take
specific *details* from the newer tests where they are strictly better. Where a
pattern is still in A/B test we note it and do **not** adopt it.

---

## 2. Bottom navigation

**Shipped structure (baseline we copy):** `Home · Shorts · Subscriptions · You`
— 4 tabs, the first and last fixed, the middle two domain-specific.

**Recent movement worth knowing:**
- Nov 2025 — `Subscriptions` and `You` swapped positions. Neither ordering is
  "correct"; users objected to the change itself, not the order.
- May 2026 (experiment) — `Subscriptions` pulled out of the bottom bar entirely and
  turned into a **swipeable top tab** alongside the feed.
- May 2026 (shipped) — users can now **hide Shorts from the Home feed**.

**What we take:**
- 4–5 tabs, thumb-reachable, first tab = Home feed, last tab = the account hub.
- Centre slot for a *primary action* is optional — YouTube uses it for Shorts
  creation. We have no equivalent primary create action for normal users, so we
  will **not** force a centre tab.
- Tab state and scroll position must survive switching.

**What we skip:** the swipeable top-tab feed switcher (still an experiment).

---

## 3. Top app bar

Shipped structure, left → right:

| Slot | Content |
| --- | --- |
| Leading | Brand mark (wordmark; on narrow screens the icon alone) |
| Trailing | Cast/Search magnifier → notifications bell **with unread dot** → profile avatar |
| Row 2 (Home feed only) | Horizontally scrolling filter **chips** |

Details we adopt:
- Bar height ≈ 56dp. Background is the **surface** colour, separated from the feed
  by a hairline border that appears on scroll (not a permanent elevation shadow).
- The avatar is a 32dp circle, tappable → account menu.
- Oct 2025: the **notification bell leads the icon row** and reads first.

---

## 4. Filter chips (Home feed, row under the top bar)

- A single horizontally-scrollable row of **capsule** chips.
- Unselected: transparent fill, 1dp hairline outline, secondary text.
- Selected: filled with the app's primary colour, on-primary text.
- Each chip can carry a leading small icon.
- The row never wraps and never shows a partial "see all" affordance — it just
  scrolls, with edge fades.

---

## 5. Feed card (the "video card")

This is the single most important component. Anatomy, top to bottom:

1. **Cover image** — 16:9, full card width minus 16dp side margins, radius ~12dp,
   no border. Image is the whole card's visual anchor.
2. **Corner badge, bottom-right of the image** — a small rounded pill in a
   translucent black scrim. This is the **duration** slot in YouTube.
3. **Meta row** below the image: 36–40dp circular **channel avatar** on the left.
4. **Two-line title** — 16sp / medium (500), line-height ~20sp, max 2 lines with
   ellipsis. `…2h ago` meta text is appended to line 2 when present.
5. **Meta line** — channel name · view count · age, 12–13sp, muted.
6. **Overflow** — a three-dot icon at the end of the meta row, opening a bottom
   sheet. Not floating on the image.

**Related card variants used by YouTube:**
- **Compact / list variant** — 168×94dp leading image, text to the right. Used in
  search results and "up next" rows.
- **Grid variant** — 2-up on phones. Used in category pages.

**Interaction:** whole card is one tap target → detail page. Long-press → context
sheet. Overflow menu is a separate, smaller target.

---

## 6. Detail / "watch" page

Shipped order (post-Oct-2025 redesign, pre-June-2026 test):

1. **Media area at the very top**, edge-to-edge, full-bleed — no side margin,
   no radius. YouTube's player shape adapts to content; ours is a fixed **16:9
   image gallery** with a page indicator.
2. **Title** — 18–20sp, medium, wraps to 2–3 lines.
3. **Primary stat line** — under the title: views · favourites · published date.
4. **Action row** — a **horizontally scrollable pill-shaped container** holding
   icon + label capsules: like, save, share, and overflow. Oct 2025 made these
   "bolder and more prominent"; the June 2026 test removes the text labels —
   **we keep labels**, because for property actions (Book visit, Apply) the label
   is doing real work and icon-only would hurt comprehension.
5. **Channel / agent row** — avatar + name + subscriber/stat count on the left,
   a **filled capsule Subscribe/Contact button** on the right. Oct 2025 moved the
   avatar up beside the title and replaced channel names with `@handles`.
6. **Expandable description** — clamped to ~2 lines with a "…more" affordance;
   tapping expands in place. Includes the stats line and the listing meta.
7. **Comments preview** — count header, top 3 threads, "view all" link.
8. **Suggested items** — an infinite feed of compact cards below.

**Motion:** page slides in from the right (platform-standard push). The action
row and description do not animate. The action capsule container gets a
translucent fill, not a hard border.

---

## 7. Colour — the substitution rule

**Hard rule: never use YouTube red `#FF0000` or YouTube blue.**

| YouTube element | IMMO BURUNDI token | Value |
| --- | --- | --- |
| Logo / wordmark | `--immo-brand` | `#0057FF` |
| Active bottom-nav icon, active chip fill, active tab underline | `--immo-brand` | `#0057FF` |
| Subscribe button fill | `--immo-brand` | `#0057FF` |
| Primary CTA fill | `--immo-brand` | `#0057FF` |
| Verification / trust accent, "Featured" highlight | `--immo-accent` | `#FFE135` (banana yellow) |
| Light background | `--immo-bg` | `#FFFFFF` |
| Light surface (cards, bars, sheets) | `--immo-surface` | `#FFFFFF` |
| Dark background | `--immo-bg` | `#000000` |
| Dark surface | `--immo-surface` | `#181818` |
| Primary text | `--immo-text` | `#191919` light / `#F0F0F0` dark |
| Secondary / meta text | `--immo-text-2` | `#6B6B6B` / `#A3A3A3` |
| Hairline border, unselected chip outline | `--immo-border` | `#E5E5E5` / `#303030` |
| Input fill | `--immo-field` | `#F7F7F7` / `#1F1F1F` |
| Verified badge | `--immo-verified` | `#16A34A` |
| Partial badge | `--immo-partial` | `#CA8A04` |
| Error / not-verified | `--immo-danger` | `#DC2626` |

Note the website carries `--immo-accent` (`#FFE135`) into **both** modes, and does
**not** redefine `--immo-brand` in dark. We keep that: brand blue stays constant,
yellow stays constant, only the neutrals invert.

---

## 8. Search experience

- **Entry:** tapping the magnifier in the top app bar opens a **full-screen**
  search surface that slides up over the current route — it is not a dialog.
- **States:** idle (recent searches + suggestions, blank query) → typing
  (live suggestions) → submitted (result list).
- **Recent searches** are persisted locally and individually removable; a
  "Clear all" action sits above the list.
- **The search field becomes the app bar** while searching (back arrow returns to
  the previous route).
- **Filters open as bottom sheets**, grouped by section with a sticky
  Apply / Reset footer. Active filter count is shown as a badge on the Filter pill.
- **Sort** is a bottom sheet of radio options.
- Results render as **compact list cards**, not full cards.

---

## 9. Account ("You") tab

- Header: 72dp avatar, name, `@handle`/email beneath.
- A **horizontal row of shortcut circles** directly below (Playlists, Watch Later,
- Your videos, History → ours: Saved, Visits, Applications, Recent views).
- Below that, **grouped list sections** with small grey uppercase section headers:
  - *You* → History, Playlists, Your videos, Watch later
  - *You and Google* → Subscriptions
  - *Data and privacy* → Your data, Download your data
- Rows: 24dp thin-outline icon + 16sp label + optional chevron/trailing value.
- Signing out sits at the bottom of the last section.

---

## 10. Settings

Navigation: **avatar → Settings** (pushed route, not a tab).

Structure — grouped list, small uppercase group headers, 1dp separators between
rows but **not** between groups:

```
General          Appearance        → Device theme / Light theme / Dark theme
                 Notifications      → bell + per-channel toggles
                 Downloads          → quality, wifi-only

Account          Edit profile
                 Phone number / Email / Password
                 Manage your Google Account

Privacy          Privacy settings
                 Location / History / Personalised ads
```

The **Appearance** setting is a three-way choice: *Use device theme* (default),
*Light theme*, *Dark theme*. It applies instantly across the app and persists.

**Icon treatment:** thin **outline** icons everywhere in Settings; the same icons
render **filled** when the row is selected/toggled on.

---

## 11. Material 3 treatment

| Token | Value |
| --- | --- |
| Corner radius — thumbnail / card | **12dp** |
| Corner radius — sheet | top 28dp |
| Corner radius — chip, button, avatar, badge | **pill** (`999`) |
| Corner radius — input field, list tile | 12dp / 0 (full-bleed rows) |
| Spacing base unit | **4dp** (4/8/12/16/24/32) |
| Page side margin | **16dp** |
| Bottom nav height | 56dp + safe-area inset |
| Top app bar height | 56dp |
| Elevation | flat; separation by `surface` tint + hairline, not heavy shadows |

**Components used, verbatim from YouTube:**
- Bottom sheets (drag handle, 28dp top radius, scrim) — for every menu,
  filter panel, and sort picker.
- Snackbars — confirmation of optimistic actions ("Saved to your favourites").
- Skeleton shimmer loaders for every feed and list.
- Pull-to-refresh on all scrolls.
- Empty states with an illustration + one primary action.
- Error states with a message + **Retry** button.
- Haptics on like / save / pay.

**Typography — Roboto, YouTube's exact hierarchy:**

| Role | Size | Weight | Notes |
| --- | --- | --- | --- |
| Page title (H1) | 28 | 700 | matches website `--fs-h1` |
| Section header (H2) | 16 | 500 | matches website `--fs-h2` |
| Card title | 16 | 500 | max 2 lines, ellipsis |
| Body | 14 | 400 | matches website `--fs-body` |
| Nav / buttons / tiles | 14 | 400–500 | matches website `--fs-ui` |
| **Meta / secondary** | **12–13** | **400** | **muted colour** — the "2.3M views · 3 days ago" line |
| Search field | 14 | 400 | |

The website's own scale (`--fs-card-title: 13`, `--fs-card-loc: 12`,
`--fs-card-price: 13`) is slightly denser than YouTube's; we use **16/12** on the
feed card and keep the denser 13px scale inside dense rows (search results,
dashboard lists) where space is tight. Documented as an intentional deviation.

---

## 12. Motion

| Transition | Spec |
| --- | --- |
| Tab switch | Feed **slides up** + cross-fade, ~250ms, `Curves.easeOutCubic`. Shipped Oct-2025 behaviour. |
| Push (list → detail) | Horizontal slide-in from right, ~280ms, `easeOutCubic` |
| Pop | Reverse, ~220ms |
| Full-screen search / image viewer | Slide up from bottom, ~250ms |
| Bottom sheet | Slide up + scrim fade, ~200ms; drag-to-dismiss enabled |
| Skeleton shimmer | 1200ms linear loop |
| Snackbar | Slide up 150ms, hold 3s |
| Like/save | Scale pop 1.0 → 1.12 → 1.0, 180ms + haptic |
| Images | Cross-fade on load, 200ms |

No parallax, no cinematic transitions. YouTube's own philosophy here is restraint:
transitions should "obscure less content".

---

## 13. Accessibility & responsiveness

- Minimum tap target **48×48dp**.
- Body text ≥ 14sp; supports OS font scaling up to 200% without clipping.
- Contrast: meta text on surface must clear **4.5:1**; the website's
  `--immo-text-2` clears it in both modes.
- Semantic labels on every icon-only control (overflow, gallery page indicator,
  like/save state announced as "Saved"/"Save").
- Phones: single-column feed, 2-up grids. Tablets (≥600dp): 2-column feed,
  3-up grids, persistent navigation rail instead of a bottom bar.

---

## 14. Mapping table — YouTube element → IMMO BURUNDI equivalent

| # | YouTube element | IMMO BURUNDI equivalent | Source of truth |
| --- | --- | --- | --- |
| 1 | Launch logo animation | **Lottie `home.json`** full-screen on themed bg → route on session state | `apps/web/src/assets/lottie/home.json` |
| 2 | Bottom nav `Home` | **Home** feed tab | `GET /api/properties/recent` |
| 3 | Bottom nav `Shorts` | **→ Removed.** No vertical video surface exists on the site. | — |
| 4 | Bottom nav `Subscriptions` | **Explore** tab (category tiles + popular locations + verified) | `/properties/featured`, `/popular-locations`, `/verified` |
| 5 | Bottom nav `You` | **You** tab (profile + shortcuts + grouped lists) | `/users/me` |
| 6 | *(added tab)* | **Saved** tab — favorites + recent views | `/favorites`, `/users/me/recent-views` |
| 7 | Top bar logo left | **IMMO BURUNDI** logo left | `apps/web/public/assets/brand/logo.png` |
| 8 | Top bar search icon | **Search** icon → full-screen search | `GET /api/properties?q=` |
| 9 | Top bar notification bell | **Notifications** icon + unread dot | `/notifications/unread-count` |
| 10 | Top bar avatar | **Avatar** → account menu | `/users/me` |
| 11 | Feed filter chips row | **Category chips**: For you / Sale / Rent / Land / Commercial / Verified / Featured | `LISTING_TYPE_OPTIONS`, `PROPERTY_TYPE_OPTIONS`, `/featured`, `/verified` |
| 12 | Video card thumbnail 16:9 | **Property cover image** 16:9, radius 12dp, 16dp side margin | `Property.media[]`, `isPrimary` |
| 13 | **Duration badge** | **Image-count badge** `3/12` + optional listing-type tag | `media.length` |
| 14 | Channel avatar in meta row | **Agent avatar** 36dp | `agent.photoUrl` |
| 15 | Two-line video title | Two-line property title | `title` + i18n variants |
| 16 | "1.2M views · 3 days ago" | "N views · Commune, Province · 2 days ago" | `stats.views`, location, `publishedAt` |
| 17 | Price line | **Price line** `250 000 000 BIF` (currency-aware, BIF ⇄ USD) | `price.amount/currency`, `/geo/exchange-rates` |
| 18 | Three-dot card menu | Three-dot sheet: **Save**, **Share**, **Report**, (auth) **Book visit** | `/favorites`, `/reports`, native share |
| 19 | Watch-page player | **Swipeable image gallery**, full-bleed 16:9, `3/12` pill indicator | `Property.media[]` |
| 20 | Fullscreen player / PiP | **Full-screen image viewer**, pinch-zoom + swipe-dismiss | — |
| 21 | Like / Dislike | **Save to favourites** (single toggle — the site has one) | `POST /properties/:id/favorite` |
| 22 | Save to Watch Later / playlist | **Save** (favourites), inside overflow sheet | `/favorites` |
| 23 | Download | **→ Removed.** The site exposes no image download endpoint. | — |
| 24 | Share | **Share** — native share sheet + WhatsApp deep link | `lib/whatsapp.ts` |
| 25 | Subscribe button | **Contact agent** capsule (only if the site supports it — see gap Q3) | `agents/:id` |
| 26 | Channel row (avatar+name+subs) | **Agent row** — avatar, name, agency, stats | `AgentSummary` |
| 27 | Expandable description | **Expandable description** + listing meta | `description` + variants |
| 28 | Comments section | **Questions** — *client-local only on the site, see gap Q1* | none |
| 29 | Suggested videos | **Related properties** compact-card feed | `/properties/:id/related` |
| 30 | Channel tabs (Home/Listings/About) | **Agent channel** tabs: Listings / Sold / About | `/agents/:id`, `/properties?agentId=` |
| 31 | Channel reviews | **Ratings + transactions**, read-only ("written reviews coming soon") | `AgentSummary.rating`, `totalDeals` |
| 32 | Recent searches | **Recent searches**, local, clear-all | new local persistence |
| 33 | Search suggestions | **Search suggestions** from recent + category names | local + `/properties?q=` |
| 34 | Search filters sheet | **Filters sheet** — listing type, property type, price, surface, bedrooms, province, commune, verification | `PropertySearchQuery` |
| 35 | Sort sheet | **Sort sheet** — Newest, Price ↑, Price ↓, Views, Featured | `SORT_OPTIONS` |
| 36 | Library (History) | **Recent views** | `/users/me/recent-views` |
| 37 | Playlists | **→ Removed.** No playlist model is exposed to users. | — |
| 38 | Watch later | **Favourites** | `/favorites` |
| 39 | Downloads | **→ Removed** (same as #23) | — |
| 40 | Your videos | **→ Removed** (agent-side only; excluded by scope) | — |
| 41 | Notifications inbox | **Notifications** list, mark read / mark all read | `/notifications` |
| 42 | Settings → General → Appearance | **Settings → Appearance** — Device / Light / Dark | `immo_theme` equivalent |
| 43 | Settings → Notifications | **Notifications** section — read-only; *no per-event prefs exist on the site, see gap Q4* | — |
| 44 | Settings → Account | **Account** — edit profile, photo upload, change password, sign out | `PATCH /users/:id`, `/files/upload` |
| 45 | Legal / About | **About**, **Privacy**, **Terms**, **Cookies**, **Verification disclaimer** | `/about`, `/privacy`, `/terms`, `/cookies`, `/verification-disclaimer` |
| 46 | Material snackbar | Snackbar on save / share / book / pay | — |
| 47 | Skeleton loaders | Shimmer skeletons on every feed | — |
| 48 | Pull-to-refresh | Pull-to-refresh on all scrolls | — |
| 49 | Haptics on like | Haptics on save / book / pay | — |
| 50 | Language picker | **Language** — fr / en / sw, reuse website translations | `apps/web/src/i18n/translations.ts` |
| 51 | Currency picker | **Currency** — BIF / USD, live conversion | `CurrencyContext`, `/geo/exchange-rates` |

### Gaps found in Phase 1 (questions for you, not invented)

| # | Question |
| --- | --- |
| Q1 | The website's property **Questions** section is client-local `useState` only — nothing is persisted and there is no comments/QA API. Do you want the app to (a) replicate it as local-only, or (b) omit it, or (c) should a backend endpoint be added? |
| Q2 | `messagesApi.listConversations` exists on the backend but has **zero call sites** in the website — there is no threaded inbox UI. Replicate the screen or omit? |
| Q3 | YouTube's **Subscribe** maps to nothing: there is no follow/agent-subscribe feature (only dead translation strings). The only agent affordances are call + WhatsApp. Confirm the app should offer only those. |
| Q4 | **Notification preferences** have no backend (`NotificationPreference` model exists but is never read). Offer a local-only preferences screen, or omit? |
| Q5 | No **password reset**, no **email verification**, no **account deletion**, and OTP is a backend stub that always returns `verified: true`. The app can only ship login / register / account-setup, matching the website. Confirm. |
| Q6 | The website seeds **15 provinces** in the API but its SEO layer advertises **18**. Which list should the app's province filter ship with? |
| Q7 | **Playlists, Downloads, Your videos** and **Shorts** are removed by design (no site equivalent). Confirm you are happy with a 5-tab shell: Home · Explore · Saved · You (+ payments entry inside Saved). |

---

## 15. Summary of what we deliberately did *not* copy

- YouTube red / blue — replaced entirely by `--immo-brand` `#0057FF` + `--immo-accent` `#FFE135`.
- Shorts / vertical feed, mini player, PiP, playback speed, captions, playback position memory — all video.
- Playlists, Downloads, Your videos — no site equivalent.
- The June-2026 label-less action row — still an experiment and lossy for real-worded actions.
- The May-2026 swipeable top-tab feed switcher — still an experiment.
- Desktop/sidebar patterns, search-as-you-type-on-desktop, keyboard shortcuts.
