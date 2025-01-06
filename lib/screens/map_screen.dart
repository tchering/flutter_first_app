import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../config/mapbox_config.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController();
  Location location = Location();
  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  // France bounds
  static const LatLng franceCenter = LatLng(46.2276, 2.2137);
  static const double minZoom = 5.0;
  static const double maxZoom = 12.0;
  static const double defaultZoom = 5.0;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: franceCenter,
                zoom: defaultZoom,
                minZoom: minZoom,
                maxZoom: maxZoom,
                keepAlive: true,
                interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                bounds: LatLngBounds(
                  LatLng(MapboxConfig.swLat, MapboxConfig.swLng),
                  LatLng(MapboxConfig.neLat, MapboxConfig.neLng),
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: MapboxConfig.tileUrlTemplate,
                  additionalOptions: MapboxConfig.tileLayerOptions,
                ),
                // Add GeoJSON layer for French departments
                PolygonLayer(
                  polygons: [], // We'll add department polygons here
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          mapController.move(franceCenter, defaultZoom);
        },
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
}
