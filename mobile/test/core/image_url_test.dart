import 'package:flutter_test/flutter_test.dart';
import 'package:immoburundi/core/utils/image_url.dart';

/// The API hands back 1400px Cloudinary and Unsplash URLs. Rewriting them to the
/// size actually about to be painted is the difference between a 200 KB avatar
/// and a 20 KB one, and the transformation syntax is easy to get subtly wrong.
void main() {
  group('ImageUrl.resolve', () {
    test(
      'is null for a missing or blank URL, so callers get the placeholder',
      () {
        expect(ImageUrl.resolve(null), isNull);
        expect(ImageUrl.resolve(''), isNull);
        expect(ImageUrl.resolve('   '), isNull);
      },
    );
  });

  group('sizedImageUrl', () {
    test('leaves a non-HTTP URL untouched', () {
      // Relative `/uploads/...` paths are the API's own files.
      expect(sizedImageUrl('/uploads/abc.jpg'), '/uploads/abc.jpg');
      expect(sizedImageUrl(''), '');
    });

    test('injects a Cloudinary transformation', () {
      expect(
        sizedImageUrl(
          'https://res.cloudinary.com/demo/image/upload/v1699999999/abc.jpg',
          width: 400,
        ),
        contains('w_400,c_fill,g_auto,q_auto80,f_auto/abc.jpg'),
      );
    });

    test(
      'replaces an existing Cloudinary transformation rather than stacking',
      () {
        final String sized = sizedImageUrl(
          'https://res.cloudinary.com/demo/image/upload/w_50,q_10/abc.jpg',
          width: 800,
        );
        expect(sized, contains('w_800'));
        expect(sized, isNot(contains('w_50')));
        expect('/image/upload/'.allMatches(sized).length, 1);
      },
    );

    test('skips Cloudinary noise segments so the public id stays reachable', () {
      expect(
        sizedImageUrl(
          'https://res.cloudinary.com/demo/image/upload/v1/w_100/folder/abc.jpg',
          width: 200,
        ),
        endsWith('w_200,c_fill,g_auto,q_auto80,f_auto/folder/abc.jpg'),
      );
    });

    test('sets Unsplash size parameters and keeps the rest of the query', () {
      final Uri sized = Uri.parse(
        sizedImageUrl(
          'https://images.unsplash.com/photo-1?ixlib=rb-4.0&q=90',
          width: 400,
          quality: 80,
        ),
      );
      expect(sized.queryParameters['w'], '400');
      expect(sized.queryParameters['q'], '80');
      expect(sized.queryParameters['fit'], 'crop');
      expect(sized.queryParameters['auto'], 'format');
      expect(
        sized.queryParameters['ixlib'],
        'rb-4.0',
        reason: 'signed URLs keep their token',
      );
    });

    test('leaves an unknown host exactly as it is', () {
      expect(
        sizedImageUrl('https://cdn.example.com/a.jpg', width: 400),
        'https://cdn.example.com/a.jpg',
      );
    });
  });

  group('originalImageUrl', () {
    test('strips the Cloudinary transformation for the zoom viewer', () {
      expect(
        originalImageUrl(
          'https://res.cloudinary.com/demo/image/upload/w_1200,c_fill/abc.jpg',
        ),
        'https://res.cloudinary.com/demo/image/upload/abc.jpg',
      );
    });

    test('keeps the Unsplash signature and only drops the size keys', () {
      final Uri original = Uri.parse(
        originalImageUrl(
          'https://images.unsplash.com/photo-1?ixlib=rb-4.0&w=1600&q=80&auto=format&fit=crop',
        ),
      );
      expect(original.queryParameters.containsKey('w'), isFalse);
      expect(original.queryParameters.containsKey('fit'), isFalse);
      expect(original.queryParameters['ixlib'], 'rb-4.0');
    });

    test('leaves an unknown host alone', () {
      expect(
        originalImageUrl('https://cdn.example.com/a.jpg'),
        'https://cdn.example.com/a.jpg',
      );
    });
  });
}
