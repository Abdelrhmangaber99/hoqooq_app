class CourtPlaceEnrichment {
  const CourtPlaceEnrichment({
    required this.placeId,
    required this.displayName,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    required this.mapsUri,
  });

  final String placeId;
  final String displayName;
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final Uri mapsUri;

  factory CourtPlaceEnrichment.fromNominatimJson(Map<String, dynamic> json) {
    final namedetails = json['namedetails'] as Map?;
    final displayName =
        namedetails?['name'] as String? ??
        namedetails?['name:en'] as String? ??
        (json['display_name'] as String? ?? '').split(',').first.trim();
    final latitude = double.tryParse(json['lat']?.toString() ?? '') ?? 0;
    final longitude = double.tryParse(json['lon']?.toString() ?? '') ?? 0;
    final osmType = json['osm_type']?.toString() ?? 'node';
    final osmId = json['osm_id']?.toString() ?? '$latitude,$longitude';
    return CourtPlaceEnrichment(
      placeId: 'osm:$osmType:$osmId',
      displayName: displayName,
      formattedAddress: json['display_name'] as String? ?? '',
      latitude: latitude,
      longitude: longitude,
      mapsUri: Uri.parse(
        'https://www.openstreetmap.org/?mlat=$latitude&mlon=$longitude#map=16/$latitude/$longitude',
      ),
    );
  }

  factory CourtPlaceEnrichment.fromOverpassJson(
    Map<String, dynamic> json, {
    required String languageCode,
  }) {
    final tags = json['tags'] is Map
        ? Map<String, dynamic>.from(json['tags'] as Map)
        : const <String, dynamic>{};
    final center = json['center'] is Map
        ? Map<String, dynamic>.from(json['center'] as Map)
        : const <String, dynamic>{};
    final latitude = ((json['lat'] ?? center['lat']) as num?)?.toDouble() ?? 0;
    final longitude = ((json['lon'] ?? center['lon']) as num?)?.toDouble() ?? 0;
    final localizedName = languageCode == 'ar'
        ? tags['name:ar'] ?? tags['name'] ?? tags['name:en']
        : tags['name:en'] ?? tags['name'] ?? tags['name:ar'];
    final addressParts = [
      tags['addr:housenumber'],
      tags['addr:street'],
      tags['addr:city'],
      tags['addr:governorate'],
    ].where((value) => value?.toString().trim().isNotEmpty == true);
    final osmType = json['type']?.toString() ?? 'node';
    final osmId = json['id']?.toString() ?? '$latitude,$longitude';
    return CourtPlaceEnrichment(
      placeId: 'osm:$osmType:$osmId',
      displayName: localizedName?.toString().trim() ?? '',
      formattedAddress: addressParts.join(', '),
      latitude: latitude,
      longitude: longitude,
      mapsUri: Uri.parse(
        'https://www.openstreetmap.org/?mlat=$latitude&mlon=$longitude#map=16/$latitude/$longitude',
      ),
    );
  }

  factory CourtPlaceEnrichment.fromCacheJson(Map<String, dynamic> json) =>
      CourtPlaceEnrichment(
        placeId: json['placeId'] as String,
        displayName: json['displayName'] as String,
        formattedAddress: json['formattedAddress'] as String? ?? '',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
        mapsUri: Uri.parse(json['mapsUri'] as String),
      );

  factory CourtPlaceEnrichment.bundled(String name) => CourtPlaceEnrichment(
    placeId: 'bundled:${name.toLowerCase().replaceAll(' ', '-')}',
    displayName: name,
    formattedAddress: 'Egypt',
    latitude: 0,
    longitude: 0,
    mapsUri: Uri.parse(
      'https://www.openstreetmap.org/search?query=${Uri.encodeQueryComponent('$name, Egypt')}',
    ),
  );

  Map<String, dynamic> toCacheJson() => {
    'placeId': placeId,
    'displayName': displayName,
    'formattedAddress': formattedAddress,
    'latitude': latitude,
    'longitude': longitude,
    'mapsUri': mapsUri.toString(),
  };
}
