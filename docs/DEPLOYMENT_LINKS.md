# Deep links, signing and App/Universal Links

This is everything that has to be true **outside the app** for a tapped link to
open IMMO BURUNDI instead of a browser. The in-app half (the resolver, the
routes, the redirect guard) is covered by `mobile/test/core/deep_link_resolver_test.dart`.

## 1. Android release signing

`flutter build apk --release` signs with the keystore described by
`mobile/android/key.properties`, which is **not in version control** — neither
that file nor the `.jks` beside it is, and `mobile/android/.gitignore` enforces
that.

To set it up on a machine that does not have it yet:

```sh
cd mobile/android

keytool -genkeypair \
  -keystore app/immo-release.jks \
  -storetype JKS \
  -alias immo-release \
  -keyalg RSA -keysize 4096 -validity 10950 \
  -dname 'CN=IMMO BURUNDI, OU=Mobile, O=IMMO BURUNDI, L=Bujumbura, C=BI'
```

Then write `key.properties` next to `android/` (i.e. `mobile/android/key.properties`):

```properties
storePassword=<store password>
keyPassword=<key password>
keyAlias=immo-release
storeFile=immo-release.jks
sha256=<SHA-256 of the signing certificate, colons removed>
```

Get the fingerprint with:

```sh
keytool -list -v -keystore app/immo-release.jks -alias immo-release
# "SHA256:" line, uppercase hex, strip the colons
```

`build.gradle.kts` reads this file and creates a `release` signing config. If the
file is absent the build still succeeds using the debug key and prints a warning —
a fresh clone can therefore run `flutter build apk`, but the output must not be
shipped.

> **Keep the keystore and its passwords somewhere durable and private.** If they
> are lost, no new build can be installed over an existing install: Android
> refuses a signature change, so every tester has to uninstall first. If the
> keystore leaks, revoke it and move to a new upload key via Play App Signing —
> that is why it must never be committed.

## 2. `assetlinks.json` (Android App Links)

Android verifies an `https://immoburundi.bi/...` link by fetching
`/.well-known/assetlinks.json` and comparing the certificate fingerprint in it
against the certificate the APK was signed with. The file lives at:

- `apps/web/public/.well-known/assetlinks.json`

Vite serves everything in `public/` from the site root, so it becomes
`https://immoburundi.bi/.well-known/assetlinks.json` on deploy.

**It must be served on both hosts.** The app resolves both `immoburundi.bi` and
`www.immoburundi.bi`, and verification is per-host. Whichever host actually
answers needs the file; serve it from both if they are separate deployments.

Requirements that are easy to get wrong:

- `Content-Type: application/json`
- **No redirect.** A 301/302 to another host fails verification.
- Exact casing of the keys, and one statement per line rather than minified —
  minified JSON is valid and works, but it is unreviewable in a diff.
- The fingerprint has **no colons and no lowercase** in the common
  copy-paste form; Android compares it case-insensitively but tooling that
  regenerates the file often gets this wrong.

After changing the signing key, this file must be updated in the same deploy.
A stale fingerprint is the single most common reason App Links silently stop
working while the `immo://` scheme keeps working.

## 3. `apple-app-site-association` (iOS Universal Links)

iOS is stricter than Android:

- The file is at the **root**, with **no extension**:
  `https://immoburundi.bi/.apple-app-site-association`
- `Content-Type: application/json`
- **No `.json` extension, no redirect.**
- Served over HTTPS with a certificate iOS trusts.

The file is `apps/web/public/.apple-app-site-association`, and the entitlement
is already in `mobile/ios/Runner/Runner.entitlements` for both hosts.

`appIDs` must be `<TeamID>.bi.immoburundi.immoburundi`. The placeholder is the
bare bundle id; fill in the real Apple Developer **Team ID** before shipping
iOS. `apps` is empty for the modern format — a non-empty `apps` array makes iOS
use the legacy format and ignore `details`.

Only the components listed are claimed. Anything else on the site falls through
to Safari, which is the desired behaviour for pages that have no app
equivalent.

## 4. Custom scheme

`immo://` needs nothing from the server — it works from the moment the app is
installed, signed with any key. It is the fallback and the one to use in manual
QA when the site is down. It is declared in:

- `mobile/android/app/src/main/AndroidManifest.xml` (intent filter)
- `mobile/ios/Runner/Info.plist` (`CFBundleURLTypes`)

The custom scheme has a real weakness: any other app can register `immo://` too,
and the user then gets a disambiguation dialog. App/Universal Links over `https`
are what avoid that, which is why the two files above matter.

## 5. Host allow-list

Only `immoburundi.bi` and `www.immoburundi.bi` are treated as ours; any other
`http`/`https` inbound link is ignored rather than navigated to
(`isOwnSiteLink`). Without that check a hostile page could hand the app an
arbitrary URI and drive it to a screen of the attacker's choosing.

## 6. Verifying a link on a device

```sh
# Install (the release build is signed with the keystore above)
adb install -r build/app/outputs/flutter-apk/app-release.apk

# Custom scheme — needs no server
adb shell am start -a android.intent.action.VIEW \
  -d "immo://pay/tok_123" bi.immoburundi.immoburundi

# App Link — needs assetlinks.json live and matching
adb shell am start -a android.intent.action.VIEW \
  -d "https://www.immoburundi.bi/pay/tok_123"

# Did the system resolve it to the app, or to a browser?
adb shell pm get-app-links bi.immoburundi.immoburundi
```

`pm get-app-links` is the definitive check: `verifiedAppLinkLinks: null` means
verification failed, and the most common causes are a fingerprint that does not
match, a redirect, or the wrong content type.