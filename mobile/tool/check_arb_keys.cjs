// Dev utility: report ARB keys that collide when compared case-insensitively.
// gen-l10n accepts `propertyWhatsApp` and `propertyWhatsapp` as two distinct
// keys, and Dart happily generates two getters that differ only in case. That
// is a trap for callers, so this flags them.
const fs = require('fs');
const path = require('path');

const dir = path.join(__dirname, '..', 'lib', 'l10n');
let found = 0;
for (const file of fs.readdirSync(dir).filter((f) => f.endsWith('.arb'))) {
  const text = fs.readFileSync(path.join(dir, file), 'utf8');
  const seen = new Map();
  for (const m of text.matchAll(/^ {2}"([A-Za-z0-9_]+)":/gm)) {
    const key = m[1];
    const lower = key.toLowerCase();
    if (seen.has(lower)) {
      console.log(`${file}: case-collision -> ${seen.get(lower)} vs ${key}`);
      found++;
    } else {
      seen.set(lower, key);
    }
  }
}
console.log(found === 0 ? 'no case-insensitive key collisions' : `${found} collision(s)`);
