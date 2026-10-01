// Dev utility: guards on the shape of the ARB set.
//
// Three failure modes, all of which produce a silently wrong build rather than
// an error, which is why they are worth a script:
//
//  1. Case collisions inside one file. gen-l10n accepts `propertyWhatsApp` and
//     `propertyWhatsapp` as two distinct keys and generates two getters that
//     differ only in case. That is a trap for callers.
//  2. Exact duplicates inside one file. JSON.parse keeps the last occurrence,
//     so the earlier value is dead and the author never finds out.
//  3. Key sets that differ across locales. `app_en.arb` is the template, so a
//     key present only in `fr`/`sw` is never generated at all and the app
//     silently falls back to English - which is exactly what happened to
//     `propertyEnquire` before it was caught.
const fs = require('fs');
const path = require('path');

const l10nDir = path.join(__dirname, '..', 'lib', 'l10n');
const overridesDir = path.join(__dirname);
let found = 0;

// `_`-prefixed keys are metadata (`_comment`) and are stripped by the exporter,
// so they are not part of any key set.
const keysOf = (text) =>
  [...text.matchAll(/^ {2}"([A-Za-z0-9_]+)":/gm)]
    .map((m) => m[1])
    .filter((k) => !k.startsWith('_'));

function report(file, message) {
  console.log(`${file}: ${message}`);
  found++;
}

function checkText(file, text) {
  const keys = keysOf(text);
  const byLower = new Map();

  for (const key of keys) {
    const lower = key.toLowerCase();
    if (byLower.has(lower)) {
      const first = byLower.get(lower);
      if (first === key) {
        report(file, `duplicate key -> "${key}" appears more than once (the first value is dead)`);
      } else {
        report(file, `case-collision -> ${first} vs ${key}`);
      }
    } else {
      byLower.set(lower, key);
    }
  }

  return new Set(keys);
}

const arbFiles = fs.readdirSync(l10nDir).filter((f) => f.endsWith('.arb'));
const arbSets = new Map();
for (const file of arbFiles) {
  arbSets.set(file, checkText(path.relative(path.join(__dirname, '..'), path.join(l10nDir, file)), fs.readFileSync(path.join(l10nDir, file), 'utf8')));
}

const overrideFiles = fs
  .readdirSync(overridesDir)
  .filter((f) => /^app_overrides\.[a-z]{2}\.json$/.test(f));
const overrideSets = new Map();
for (const file of overrideFiles) {
  overrideSets.set(
    file,
    checkText(file, fs.readFileSync(path.join(overridesDir, file), 'utf8')),
  );
}

// The template locale is the one gen-l10n reads; anything the others have that
// it lacks can never become a getter.
const template = arbFiles.find((f) => f.startsWith('app_en.'));
if (template) {
  const templateKeys = arbSets.get(template);
  for (const [file, keys] of [...arbSets, ...overrideSets]) {
    if (file === template) continue;
    const missing = [...keys].filter((k) => !templateKeys.has(k));
    if (missing.length > 0) {
      report(file, `${missing.length} key(s) absent from ${template} -> ${missing.slice(0, 8).join(', ')}${missing.length > 8 ? ', ...' : ''}`);
    }
  }
}

console.log(
  found === 0
    ? `no duplicate, case-colliding or template-missing keys across ${arbFiles.length} ARB + ${overrideFiles.length} override file(s)`
    : `${found} problem(s)`,
);
process.exit(found === 0 ? 0 : 1);