import { env } from './env.js';

/**
 * Keep-warm engine for Render's free plan.
 *
 * Render suspends a free web service after roughly 15 minutes without an
 * incoming request, and the next visitor then waits ~1 minute for the instance
 * to boot. The only lever a free plan exposes is traffic, so this sends a
 * cheap request to /api/health on a timer.
 *
 * ── The one detail that decides whether this works at all ──
 * The request has to go to the PUBLIC origin, not to http://localhost:PORT.
 * Render's idle timer lives in the router in front of the container: a request
 * that never leaves the process is invisible to it, so a localhost ping loops
 * forever without ever resetting the clock. A loopback target is therefore
 * detected and refused rather than silently doing nothing.
 *
 * Note that "free" has a price: Render meters 750 instance-hours per month, and
 * an instance that never sleeps bills the full month (~744h). This trades that
 * for never paying cold-start latency. A deploy still suspends the service, and
 * the first ping after one can fail while the new instance routes.
 */

const LOG = '[keep-warm]';
const DEFAULT_PATH = '/api/health';
const REQUEST_TIMEOUT_MS = 10_000;
/** Give up on pinging every 20s and spread them out, but stay well inside the
 *  ~15 minute idle window so a suspended instance is still noticed in time. */
const MAX_BACKOFF_MULTIPLIER = 4;

const LOOPBACK_HOSTS = new Set(['localhost', '127.0.0.1', '::1', '0.0.0.0', '[::1]']);

export interface KeepWarmHandle {
  stop: () => void;
}

/** KEEP_WARM_URL wins; otherwise fall back to PUBLIC_BASE_URL. */
function rawTarget(): string {
  return env.KEEP_WARM_URL?.trim() || (env.PUBLIC_BASE_URL ? `${env.PUBLIC_BASE_URL}${DEFAULT_PATH}` : '');
}

type Target = { url: URL } | { missing: true } | { invalid: string };

function resolveTarget(): Target {
  const raw = rawTarget();
  if (!raw) return { missing: true };
  try {
    return { url: new URL(raw) };
  } catch {
    return { invalid: raw };
  }
}

/**
 * Starts the loop. Returns null when keep-warm is off or unusable — never
 * throws, because a missing warm-up setting must not be able to take the API
 * down.
 */
export function startKeepWarm(): KeepWarmHandle | null {
  if (!env.KEEP_WARM_ENABLED) return null;

  const target = resolveTarget();

  if ('missing' in target) {
    console.warn(
      `${LOG} enabled but there is no URL to ping. Set KEEP_WARM_URL to this service's public origin ` +
        `followed by ${DEFAULT_PATH} (or set PUBLIC_BASE_URL). Staying idle.`,
    );
    return null;
  }

  if ('invalid' in target) {
    console.warn(`${LOG} KEEP_WARM_URL is not a valid URL: "${target.invalid}". Staying idle.`);
    return null;
  }

  const { url } = target;

  if (LOOPBACK_HOSTS.has(url.hostname.toLowerCase())) {
    console.warn(
      `${LOG} target ${url.origin} is a loopback address. Render only resets the idle timer for ` +
        'requests that reach its router, so a localhost ping would spin forever without keeping the ' +
        'instance awake. Set KEEP_WARM_URL to the public https origin.',
    );
    return null;
  }

  let stopped = false;
  let timer: NodeJS.Timeout | null = null;
  let inFlight = false;
  let consecutiveFailures = 0;

  const ping = async (): Promise<void> => {
    if (inFlight) return;
    inFlight = true;
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);

    try {
      const res = await fetch(url, {
        method: 'GET',
        redirect: 'follow',
        signal: controller.signal,
        headers: { 'x-keep-warm': '1', accept: 'application/json' },
      });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      // Drain the body so the underlying socket can be reused by the next ping.
      await res.text();
      if (consecutiveFailures > 0) {
        console.log(`${LOG} recovered after ${consecutiveFailures} failed ping(s)`);
      }
      consecutiveFailures = 0;
    } catch (err) {
      consecutiveFailures += 1;
      // Only log the first failure and then every tenth, so a suspend does not
      // bury the deploy log in noise.
      if (consecutiveFailures === 1 || consecutiveFailures % 10 === 0) {
        const reason = err instanceof Error ? err.message : String(err);
        console.warn(`${LOG} ping failed (${consecutiveFailures} in a row): ${reason}`);
      }
    } finally {
      clearTimeout(timeout);
      inFlight = false;
    }
  };

  /**
   * setTimeout chained off the end of each request rather than setInterval: a
   * hung request must not stack up a second and third concurrent ping.
   */
  const schedule = (): void => {
    if (stopped) return;
    const multiplier = Math.min(MAX_BACKOFF_MULTIPLIER, 2 ** Math.min(consecutiveFailures, 2));
    timer = setTimeout(() => {
      void ping().finally(schedule);
    }, env.KEEP_WARM_INTERVAL_MS * multiplier);
  };

  console.log(`${LOG} pinging ${url.href} every ${env.KEEP_WARM_INTERVAL_MS / 1000}s`);
  schedule();

  return {
    stop: () => {
      stopped = true;
      if (timer) clearTimeout(timer);
      timer = null;
    },
  };
}
