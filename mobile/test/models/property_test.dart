import 'package:flutter_test/flutter_test.dart';
import 'package:immoburundi/core/models/enums.dart';
import 'package:immoburundi/core/models/property.dart';

/// A card is mostly nested DTOs — `price`, `location`, `features`, `media` —
/// and the API's shaper omits whatever is not set. These tests pin the values
/// down, because a reader that quietly falls back shows a `0 BIF` price and a
/// property with no photo, which is not an error anyone would notice in review.
void main() {
  group('PropertySummary', () {
    final PropertySummary summary = PropertySummary.fromJson(<String, dynamic>{
      '_id': 'p1',
      'title': 'Terrain a Gitega',
      'propertyType': 'LAND',
      'listingType': 'SALE',
      'status': 'PUBLISHED',
      'price': <String, dynamic>{'amount': 45000000, 'currency': 'BIF'},
      'location': <String, dynamic>{
        'province': <String, dynamic>{'code': 'BTG', 'name': 'Bujumbura Rural'},
        'commune': <String, dynamic>{'code': 'ISARE', 'name': 'Isale'},
        'zone': <String, dynamic>{'code': 'Z1', 'name': 'Zone 1'},
        'address': 'Gitega, centre',
        'latitude': -3.4268,
        'longitude': 29.9246,
        'locationPrecision': 'EXACT',
      },
      'features': <String, dynamic>{
        'surfaceArea': 500,
        'bedrooms': 3,
        'bathrooms': 2,
        'rooms': 5,
        'floors': 1,
        'parkingSpaces': 2,
        'yearBuilt': 2021,
        'isNegotiable': true,
      },
      'media': <Object?>[
        <String, dynamic>{
          'id': 'm1',
          'url': 'https://res.cloudinary.com/demo/image/upload/prop1.jpg',
          'thumbUrl':
              'https://res.cloudinary.com/demo/image/upload/w_400/prop1.jpg',
          'caption': 'Facade',
          'isPrimary': true,
          'mediaType': 'IMAGE',
          'sortOrder': 0,
        },
      ],
      'stats': <String, dynamic>{'views': 12, 'favorites': 3, 'shares': 1},
      'badges': <String, dynamic>{
        'featured': true,
        'isNew': false,
        'isPromoted': true,
      },
      'isFavorite': true,
    });

    test('reads identity and the card headline', () {
      expect(summary.id, 'p1');
      expect(summary.title, 'Terrain a Gitega');
      expect(summary.listingType, ListingType.sale);
      expect(summary.propertyType, PropertyType.land);
      expect(summary.isFavorite, isTrue);
    });

    test('keeps the real price instead of the zero fallback', () {
      expect(summary.price.amount, 45000000);
      expect(summary.price.currency, 'BIF');
    });

    test('reads the nested location, including the optional zone', () {
      expect(summary.location.province.name, 'Bujumbura Rural');
      expect(summary.location.commune.code, 'ISARE');
      expect(summary.location.zone?.name, 'Zone 1');
      expect(summary.location.address, 'Gitega, centre');
      expect(summary.location.latitude, -3.4268);
      expect(summary.location.longitude, 29.9246);
    });

    test('reads the feature numbers', () {
      expect(summary.features.surfaceArea, 500);
      expect(summary.features.bedrooms, 3);
      expect(summary.features.bathrooms, 2);
      expect(summary.features.rooms, 5);
      expect(summary.features.floors, 1);
      expect(summary.features.parkingSpaces, 2);
      expect(summary.features.yearBuilt, 2021);
      expect(summary.features.isNegotiable, isTrue);
    });

    test('reads the photo, which is what makes the card usable', () {
      expect(summary.media, hasLength(1));
      expect(summary.media.first.url, contains('prop1.jpg'));
      expect(summary.media.first.thumbUrl, contains('w_400'));
      expect(summary.media.first.caption, 'Facade');
      expect(summary.media.first.isPrimary, isTrue);
      expect(summary.media.first.isImage, isTrue);
    });

    test('reads stats and badges', () {
      expect(summary.stats.views, 12);
      expect(summary.stats.favorites, 3);
      expect(summary.stats.shares, 1);
      expect(summary.badges.featured, isTrue);
      expect(summary.badges.isNew, isFalse);
      expect(summary.badges.isPromoted, isTrue);
    });
  });

  group('PropertySummary, sparse payload', () {
    test('falls back without throwing when everything is omitted', () {
      final PropertySummary summary = PropertySummary.fromJson(
        <String, dynamic>{'_id': 'p2'},
      );

      expect(summary.id, 'p2');
      expect(summary.price.amount, 0);
      expect(summary.price.currency, 'BIF');
      expect(summary.media, isEmpty);
      expect(summary.location.zone, isNull, reason: 'zone is optional');
      expect(summary.location.address, isNull);
      expect(summary.features.bedrooms, isNull);
      expect(summary.badges.isNew, isTrue, reason: 'new by default');
    });

    test('survives a null payload', () {
      final PropertySummary summary = PropertySummary.fromJson(null);

      expect(summary.id, '');
      expect(summary.title, '');
    });

    test('a media entry with no url is not treated as an image', () {
      final PropertySummary summary = PropertySummary.fromJson(
        <String, dynamic>{
          '_id': 'p3',
          'media': <Object?>[
            <String, dynamic>{'id': 'm1'},
          ],
        },
      );

      expect(summary.media.first.url, isEmpty);
      expect(summary.media.first.isImage, isFalse);
    });
  });
}
