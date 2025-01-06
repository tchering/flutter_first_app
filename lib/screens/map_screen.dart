import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import '../config/mapbox_config.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController();
  Location location = Location();
  final bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;
  List<Task> _inProgressTasks = [];
  List<Task> _completedTasks = [];
  bool _showInProgress = true;
  bool _showCompleted = true;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _departmentsGeoJson;
  Map<String, dynamic>? _userData;

  // France bounds
  static const LatLng franceCenter = LatLng(46.2276, 2.2137);
  static const double minZoom = 5.0;
  static const double maxZoom = 12.0;
  static const double defaultZoom = 5.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load user data
      _userData = await AuthService.getUserData();

      // Load departments GeoJSON
      final departmentsResponse = await ApiService.fetchDepartmentsGeoJson();
      print('Loaded departments GeoJSON');

      // Load tasks
      final inProgressTasks = await ApiService.fetchTasksByStatus('in_progress');
      print('Loaded ${inProgressTasks.length} in-progress tasks');
      
      final completedTasks = await ApiService.fetchTasksByStatus('completed');
      print('Loaded ${completedTasks.length} completed tasks');

      if (mounted) {
        setState(() {
          _departmentsGeoJson = departmentsResponse;
          _inProgressTasks = inProgressTasks;
          _completedTasks = completedTasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading map data: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to load map data. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildMarkerIcon(Task task, bool isInProgress) {
    final isContractor = ApiService.isContractor(_userData);
    final companyName = isContractor 
        ? task.contractorName
        : task.contractor['company_name'] ?? 'N/A';
    
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isInProgress ? Colors.orange : Colors.green,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          isInProgress ? Icons.work : Icons.check_circle,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];
    
    if (_showInProgress) {
      markers.addAll(_inProgressTasks.where((task) => task.latitude != null && task.longitude != null).map(
        (task) => Marker(
          point: LatLng(task.latitude!, task.longitude!),
          width: 30.0,
          height: 30.0,
          child: GestureDetector(
            onTap: () => _showTaskDetails(task),
            child: _buildMarkerIcon(task, true),
          ),
        ),
      ));
    }

    if (_showCompleted) {
      markers.addAll(_completedTasks.where((task) => task.latitude != null && task.longitude != null).map(
        (task) => Marker(
          point: LatLng(task.latitude!, task.longitude!),
          width: 30.0,
          height: 30.0,
          child: GestureDetector(
            onTap: () => _showTaskDetails(task),
            child: _buildMarkerIcon(task, false),
          ),
        ),
      ));
    }

    return markers;
  }

  void _showTaskDetails(Task task) {
    final isContractor = ApiService.isContractor(_userData);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.siteName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.business, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        isContractor ? task.contractorName : task.contractor['company_name'] ?? 'N/A',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow(Icons.location_on, '${task.street}, ${task.city}'),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.euro,
                    task.proposedPrice != null 
                        ? '€${task.proposedPrice}'
                        : 'Price not set',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.calendar_today,
                    '${DateFormat('MMM dd, yyyy').format(task.startDate)} - ${DateFormat('MMM dd, yyyy').format(task.endDate)}',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.info_outline,
                    task.status.toUpperCase(),
                    color: task.status == 'in_progress' ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to task details
                      },
                      child: Text('view_details'.tr()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: color != null ? FontWeight.bold : null,
          ),
        ),
      ],
    );
  }

  List<Polygon> _buildDepartmentPolygons() {
    if (_departmentsGeoJson == null) return [];

    List<Polygon> polygons = [];
    try {
      for (var feature in _departmentsGeoJson!['features']) {
        var geometry = feature['geometry'];
        if (geometry['type'] == 'Polygon') {
          var coordinates = geometry['coordinates'][0] as List;
          var points = coordinates.map((coord) {
            if (coord is List && coord.length >= 2) {
              return LatLng(
                (coord[1] is num) ? (coord[1] as num).toDouble() : 0.0,
                (coord[0] is num) ? (coord[0] as num).toDouble() : 0.0,
              );
            }
            return null;
          }).whereType<LatLng>().toList();

          if (points.isNotEmpty) {
            polygons.add(
              Polygon(
                points: points,
                color: Colors.blue.withOpacity(0.1),
                borderStrokeWidth: 1,
                borderColor: Colors.blue,
              ),
            );
          }
        } else if (geometry['type'] == 'MultiPolygon') {
          var multiCoordinates = geometry['coordinates'] as List;
          for (var coordinates in multiCoordinates) {
            if (coordinates is List && coordinates.isNotEmpty) {
              var outerRing = coordinates[0] as List;
              var points = outerRing.map((coord) {
                if (coord is List && coord.length >= 2) {
                  return LatLng(
                    (coord[1] is num) ? (coord[1] as num).toDouble() : 0.0,
                    (coord[0] is num) ? (coord[0] as num).toDouble() : 0.0,
                  );
                }
                return null;
              }).whereType<LatLng>().toList();

              if (points.isNotEmpty) {
                polygons.add(
                  Polygon(
                    points: points,
                    color: Colors.blue.withOpacity(0.1),
                    borderStrokeWidth: 1,
                    borderColor: Colors.blue,
                  ),
                );
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error building department polygons: $e');
    }
    return polygons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: franceCenter,
              zoom: defaultZoom,
              minZoom: minZoom,
              maxZoom: maxZoom,
              keepAlive: true,
              interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              bounds: LatLngBounds(
                const LatLng(MapboxConfig.swLat, MapboxConfig.swLng),
                const LatLng(MapboxConfig.neLat, MapboxConfig.neLng),
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: MapboxConfig.tileUrlTemplate,
                additionalOptions: MapboxConfig.tileLayerOptions,
              ),
              if (!_isLoading && _departmentsGeoJson != null)
                PolygonLayer(
                  polygons: _buildDepartmentPolygons(),
                ),
              if (!_isLoading)
                MarkerLayer(
                  markers: _buildMarkers(),
                ),
            ],
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_error != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                FilterChip(
                  label: Row(
                    children: [
                      Icon(
                        Icons.work,
                        color: _showInProgress ? Colors.white : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'In Progress',
                        style: TextStyle(
                          color: _showInProgress ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  selected: _showInProgress,
                  selectedColor: Colors.orange,
                  onSelected: (bool value) {
                    setState(() {
                      _showInProgress = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                FilterChip(
                  label: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: _showCompleted ? Colors.white : Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: TextStyle(
                          color: _showCompleted ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  selected: _showCompleted,
                  selectedColor: Colors.green,
                  onSelected: (bool value) {
                    setState(() {
                      _showCompleted = value;
                    });
                  },
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
