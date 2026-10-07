import 'package:flutter_test/flutter_test.dart';
import 'package:immoburundi/core/deep_links/deep_link_resolver.dart';

/// A deep link that resolves to nothing lands on the 404 screen, so every
/// spelling the company actually sends has to be covered here: an agent pasting
/// `immo://pay/<token>` into WhatsApp is the single most important case.
void main() {
  group('payment links', () {
    test('resolves the custom scheme an agent sends over SMS', () {
      expect(
        deepLinkLocation(Uri.parse('immo://pay/tok_abc123')),
        '/pay/tok_abc123',
      );
    });

    test('resolves the verified web link', () {
      expect(
        deepLinkLocation(
          Uri.parse('https://www.immoburundi.bi/pay/tok_abc123'),
        ),
        '/pay/tok_abc123',
      );
    });

    test('resolves with the resource in the path instead of the host', () {
      // Some senders build `immo:///pay/<token>`; both spellings must land in
      // the same place or a link works only on the device that produced it.
      expect(
        deepLinkLocation(Uri.parse('immo:///pay/tok_abc123')),
        '/pay/tok_abc123',
      );
    });

    test('is null without a token rather than routing to a broken screen', () {
      expect(deepLinkLocation(Uri.parse('immo://pay')), isNull);
      expect(
        deepLinkLocation(Uri.parse('https://www.immoburundi.bi/pay')),
        isNull,
      );
    });
  });

  group('property and agent links', () {
    test('resolves the custom scheme', () {
      expect(
        deepLinkLocation(Uri.parse('immo://property/p42')),
        '/property/p42',
      );
      expect(deepLinkLocation(Uri.parse('immo://agent/a7')), '/agent/a7');
    });

    test('resolves the verified web link', () {
      expect(
        deepLinkLocation(Uri.parse('https://www.immoburundi.bi/property/p42')),
        '/property/p42',
      );
    });

    test('is null when the id is missing', () {
      expect(deepLinkLocation(Uri.parse('immo://property')), isNull);
    });
  });

  group('website paths the app spells differently', () {
    // The website serves category pages at the same path the app uses. Before
    // `category` was mapped, a shared category link resolved to null and landed
    // on the 404 screen even though /category/<type> exists.
    test('keeps a category path that the app already serves', () {
      expect(
        deepLinkLocation(
          Uri.parse('https://www.immoburundi.bi/category/apartments'),
        ),
        '/category/apartments',
      );
      expect(
        deepLinkLocation(Uri.parse('immo://category/villas')),
        '/category/villas',
      );
    });

    test('a category path with no type is not a route', () {
      expect(
        deepLinkLocation(Uri.parse('https://www.immoburundi.bi/category')),
        isNull,
      );
    });

    test('maps setup-account to the app route', () {
      // The website serves /setup-account/<token>; the app serves
      // /auth/setup/<token>. Passing the website path through unchanged would
      // 404 on a link the API itself emails.
      expect(
        deepLinkLocation(
          Uri.parse('https://www.immoburundi.bi/setup-account/tok_9'),
        ),
        '/auth/setup/tok_9',
      );
    });

    test('maps the website auth paths', () {
      expect(
        deepLinkLocation(Uri.parse('https://www.immoburundi.bi/login')),
        '/auth/sign-in',
      );
      expect(
        deepLinkLocation(Uri.parse('https://www.immoburundi.bi/signup')),
        '/auth/sign-up',
      );
      expect(
        deepLinkLocation(Uri.parse('https://www.immoburundi.bi/register')),
        '/auth/sign-up',
      );
    });

    test('maps the website legal paths, including verification-disclaimer', () {
      expect(
        deepLinkLocation(Uri.parse('https://www.immoburundi.bi/terms')),
        '/legal/terms',
      );
      expect(
        deepLinkLocation(Uri.parse('https://www.immoburundi.bi/privacy')),
        '/legal/privacy',
      );
      expect(
        deepLinkLocation(Uri.parse('https://www.immoburundi.bi/cookies')),
        '/legal/cookies',
      );
      expect(
        deepLinkLocation(
          Uri.parse('https://www.immoburundi.bi/verification-disclaimer'),
        ),
        '/legal/verification',
      );
    });

    test('maps the website location pages into search', () {
      // /immobilier/<slug> has no equivalent category route; search shows the
      // slug rather than a category screen that cannot be filled.
      expect(
        deepLinkLocation(
          Uri.parse('https://www.immoburundi.bi/immobilier/bujumbura'),
        ),
        '/home/search?q=bujumbura',
      );
    });
  });

  group('in-app paths', () {
    test('passes the tab routes straight through', () {
      expect(deepLinkLocation(Uri.parse('immo://home')), '/home');
      expect(deepLinkLocation(Uri.parse('immo://explore')), '/explore');
      expect(deepLinkLocation(Uri.parse('immo://saved')), '/saved');
      expect(deepLinkLocation(Uri.parse('immo://you')), '/you');
      expect(deepLinkLocation(Uri.parse('immo://settings')), '/you/settings');
    });

    test('ignores query and fragment', () {
      // A crafted link must not be able to pre-fill state the user did not
      // choose, so nothing from the query survives the hop.
      expect(
        deepLinkLocation(Uri.parse('immo://pay/tok_abc123?amount=1#steal')),
        '/pay/tok_abc123',
      );
    });
  });

  group('unknown links', () {
    test('are rejected so the caller can show the 404 screen', () {
      expect(deepLinkLocation(Uri.parse('immo://wat')), isNull);
      expect(
        deepLinkLocation(Uri.parse('https://www.immoburundi.bi/nope')),
        isNull,
      );
      expect(deepLinkLocation(Uri.parse('immo://')), isNull);
    });

    test('do not mistake a foreign host for our own', () {
      expect(
        deepLinkLocation(Uri.parse('https://evil.example/pay/tok')),
        isNull,
      );
      expect(isOwnSiteLink(Uri.parse('https://evil.example/pay/tok')), isFalse);
    });
  });

  group('isOwnSiteLink', () {
    test('accepts both the bare and www hosts, case-insensitively', () {
      expect(
        isOwnSiteLink(Uri.parse('https://www.immoburundi.bi/pay/t')),
        isTrue,
      );
      expect(isOwnSiteLink(Uri.parse('https://immoburundi.bi/pay/t')), isTrue);
      expect(
        isOwnSiteLink(Uri.parse('https://WWW.Immoburundi.BI/pay/t')),
        isTrue,
      );
    });

    test('rejects other schemes and hosts', () {
      expect(isOwnSiteLink(Uri.parse('immo://pay/t')), isFalse);
      expect(
        isOwnSiteLink(Uri.parse('https://immoburundi.bi.evil.example/pay/t')),
        isFalse,
      );
    });
  });

  group('paymentLink', () {
    test('round-trips through the resolver', () {
      expect(deepLinkLocation(paymentLink('tok_abc123')), '/pay/tok_abc123');
    });
  });
}
