/// Right-sized image URLs.
///
/// The API hands back whatever the seed produced: Cloudinary `secure_url`s or
/// Unsplash URLs, often already at 1400px. Rendering one of those into a 180dp
/// thumbnail on a phone is pure waste, and both hosts support transforms, so we
/// rewrite the URL to the size actually about to be painted.
///
/// Unknown hosts are returned unchanged, which keeps the API's own
/// `/uploads/...` files working untouched.
library;

/// Logical widths, chosen per use-site.
abstract final class ImageWidth {
  static const int avatar = 200;
  static const int grid = 400;
  static const int feed = 800;
  static const int detailHero = 1200;
  static const int fullScreen = 1600;
}

const String _cloudinaryMarker = '/image/upload/';

/// A leading path segment that belongs to Cloudinary's pipeline rather than to
/// the asset itself: a `v1234` version, a transformation, or a stray
/// `image`/`upload` from a double-prefixed URL.
final RegExp _cloudinaryNoise = RegExp(r'^(v\d+|image|upload)$');

bool _isNoise(String segment) =>
    _cloudinaryNoise.hasMatch(segment) || segment.contains('_');

/// Splits `…/image/upload/<noise>/<publicId>` and returns the prefix and the
/// public id, with any existing transformations dropped.
({String prefix, String publicId}) _splitCloudinary(String url) {
  final int i = url.indexOf(_cloudinaryMarker);
  final String prefix = url.substring(0, i + _cloudinaryMarker.length);
  final List<String> parts = url
      .substring(i + _cloudinaryMarker.length)
      .split('?')
      .first
      .split('/');
  int start = 0;
  while (start < parts.length && _isNoise(parts[start])) {
    start++;
  }
  return (prefix: prefix, publicId: parts.sublist(start).join('/'));
}

String _cloudinary(String url, int width, int quality) {
  if (!url.contains(_cloudinaryMarker)) return url;
  final ({String prefix, String publicId}) parts = _splitCloudinary(url);
  if (parts.publicId.isEmpty) return url;
  return '${parts.prefix}w_$width,c_fill,g_auto,q_auto$quality,f_auto/'
      '${parts.publicId}';
}

const Set<String> _unsplashTransformKeys = <String>{
  'w',
  'q',
  'auto',
  'fit',
};

String _unsplash(String url, int width, int quality, {bool stripOnly = false}) {
  final Uri uri = Uri.parse(url);
  final Map<String, String> params = <String, String>{
    for (final MapEntry<String, String> e in uri.queryParameters.entries)
      if (!_unsplashTransformKeys.contains(e.key)) e.key: e.value,
  };
  if (!stripOnly) {
    params.addAll(<String, String>{
      'w': '$width',
      'q': '$quality',
      'auto': 'format',
      'fit': 'crop',
    });
  }
  return uri.replace(queryParameters: params).toString();
}

/// Returns a URL that will serve approximately [width] logical pixels at
/// [quality] (an image-quality percentage, not a file-size target).
String sizedImageUrl(
  String url, {
  int width = ImageWidth.feed,
  int quality = 80,
}) {
  if (url.isEmpty || !url.startsWith('http')) return url;
  if (url.contains('res.cloudinary.com')) return _cloudinary(url, width, quality);
  if (url.contains('images.unsplash.com')) return _unsplash(url, width, quality);
  return url;
}

/// Strips the transform parameters again, for the pinch-to-zoom viewer.
String originalImageUrl(String url) {
  if (url.contains('res.cloudinary.com')) {
    if (!url.contains(_cloudinaryMarker)) return url;
    final ({String prefix, String publicId}) parts = _splitCloudinary(url);
    if (parts.publicId.isEmpty) return url;
    return '${parts.prefix}${parts.publicId}';
  }
  if (url.contains('images.unsplash.com')) {
    return _unsplash(url, 0, 0, stripOnly: true);
  }
  return url;
}
