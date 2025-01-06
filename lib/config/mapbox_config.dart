import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapboxConfig {
  static String get accessToken => dotenv.env['MAPBOX_API_KEY'] ?? '';
  
  // France bounds
  static const double swLat = 41.3337;
  static const double swLng = -5.1406;
  static const double neLat = 51.0891;
  static const double neLng = 9.5593;
  
  // Map configuration
  static const String mapStyle = 'mapbox/light-v10';
  static const String tileUrlTemplate = 'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}';
  
  static Map<String, String> get tileLayerOptions => {
    'accessToken': accessToken,
    'id': mapStyle,
  };
}
