import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/emergency_alert_overlay.dart';
import './widgets/hazard_marker_info.dart';
import './widgets/map_filter_panel.dart';
import './widgets/map_layer_controls.dart';
import './widgets/map_search_bar.dart';

class InteractiveMapScreen extends StatefulWidget {
  const InteractiveMapScreen({super.key});

  @override
  State<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends State<InteractiveMapScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  bool _isFilterPanelVisible = false;
  bool _isHeatmapEnabled = false;
  bool _isEmergencyMode = false;
  Map<String, dynamic>? _selectedHazard;

  // Map layer states
  Map<String, bool> _layerStates = {
    'citizen_reports': true,
    'official_alerts': true,
    'social_media': false,
    'weather_overlay': false,
    'heatmap': false,
  };

  // Map markers and data
  Set<Marker> _markers = {};
  Set<Circle> _heatmapCircles = {};

  // Mock data for hazards
  final List<Map<String, dynamic>> _hazardData = [
    {
      'id': '1',
      'type': 'Tsunami',
      'location': 'Pacific Coast, CA',
      'coordinates': {'lat': 34.0522, 'lng': -118.2437},
      'alertLevel': 'high',
      'status': 'verified',
      'timestamp': DateTime.now().subtract(Duration(minutes: 15)),
      'description':
          'Large tsunami waves detected approaching the coastline. Immediate evacuation recommended for all coastal areas.',
      'imageUrl':
          'https://images.pexels.com/photos/1001682/pexels-photo-1001682.jpeg?auto=compress&cs=tinysrgb&w=800',
      'reportedBy': 'NOAA Alert System',
      'severity': 9.2,
    },
    {
      'id': '2',
      'type': 'Storm Surge',
      'location': 'Miami Beach, FL',
      'coordinates': {'lat': 25.7617, 'lng': -80.1918},
      'alertLevel': 'medium',
      'status': 'pending',
      'timestamp': DateTime.now().subtract(Duration(hours: 2)),
      'description':
          'Storm surge conditions developing due to approaching hurricane. Water levels rising rapidly.',
      'imageUrl':
          'https://images.pexels.com/photos/1118873/pexels-photo-1118873.jpeg?auto=compress&cs=tinysrgb&w=800',
      'reportedBy': 'Local Resident',
      'severity': 6.8,
    },
    {
      'id': '3',
      'type': 'High Waves',
      'location': 'Galveston Bay, TX',
      'coordinates': {'lat': 29.3013, 'lng': -94.7977},
      'alertLevel': 'low',
      'status': 'verified',
      'timestamp': DateTime.now().subtract(Duration(hours: 6)),
      'description':
          'Unusually high waves observed in the bay area. Boaters advised to exercise caution.',
      'imageUrl':
          'https://images.pexels.com/photos/1001682/pexels-photo-1001682.jpeg?auto=compress&cs=tinysrgb&w=800',
      'reportedBy': 'Coast Guard',
      'severity': 4.2,
    },
    {
      'id': '4',
      'type': 'Rip Current',
      'location': 'Virginia Beach, VA',
      'coordinates': {'lat': 36.8529, 'lng': -75.9780},
      'alertLevel': 'medium',
      'status': 'verified',
      'timestamp': DateTime.now().subtract(Duration(hours: 4)),
      'description':
          'Strong rip currents detected along the beach. Swimming not recommended.',
      'imageUrl':
          'https://images.pexels.com/photos/1001682/pexels-photo-1001682.jpeg?auto=compress&cs=tinysrgb&w=800',
      'reportedBy': 'Lifeguard Station',
      'severity': 5.5,
    },
    {
      'id': '5',
      'type': 'Coastal Erosion',
      'location': 'Outer Banks, NC',
      'coordinates': {'lat': 35.2584, 'lng': -75.5278},
      'alertLevel': 'low',
      'status': 'pending',
      'timestamp': DateTime.now().subtract(Duration(days: 1)),
      'description':
          'Accelerated coastal erosion observed after recent storm activity.',
      'imageUrl':
          'https://images.pexels.com/photos/1001682/pexels-photo-1001682.jpeg?auto=compress&cs=tinysrgb&w=800',
      'reportedBy': 'Environmental Monitor',
      'severity': 3.8,
    },
  ];

  // Emergency alerts
  final List<Map<String, dynamic>> _emergencyAlerts = [
    {
      'id': 'emergency_1',
      'type': 'Tsunami Warning',
      'location': 'Pacific Coast Region',
      'message':
          'TSUNAMI WARNING: Large tsunami waves detected. Evacuate coastal areas immediately. Move to higher ground.',
      'timestamp': DateTime.now().subtract(Duration(minutes: 5)),
      'severity': 'critical',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _checkEmergencyAlerts();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    _createMarkers();
    _createHeatmapCircles();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      if (!kIsWeb) {
        final permission = await Permission.location.request();
        if (!permission.isGranted) {
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _createMarkers() {
    final markers = <Marker>{};

    for (final hazard in _hazardData) {
      if (!_shouldShowHazard(hazard)) continue;

      final coordinates = hazard['coordinates'];
      final alertLevel = hazard['alertLevel'] ?? 'medium';

      Color markerColor = AppTheme.warningColor;
      if (alertLevel == 'high')
        markerColor = AppTheme.lightTheme.colorScheme.error;
      if (alertLevel == 'low') markerColor = AppTheme.successColor;

      markers.add(
        Marker(
          markerId: MarkerId(hazard['id']),
          position: LatLng(coordinates['lat'], coordinates['lng']),
          infoWindow: InfoWindow(
            title: hazard['type'],
            snippet: hazard['location'],
          ),
          onTap: () => _showHazardInfo(hazard),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerHue(alertLevel),
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  void _createHeatmapCircles() {
    final circles = <Circle>{};

    if (_layerStates['heatmap'] == true) {
      for (final hazard in _hazardData) {
        if (!_shouldShowHazard(hazard)) continue;

        final coordinates = hazard['coordinates'];
        final severity = hazard['severity'] ?? 5.0;
        final alertLevel = hazard['alertLevel'] ?? 'medium';

        Color circleColor = AppTheme.warningColor;
        if (alertLevel == 'high')
          circleColor = AppTheme.lightTheme.colorScheme.error;
        if (alertLevel == 'low') circleColor = AppTheme.successColor;

        circles.add(
          Circle(
            circleId: CircleId('heatmap_${hazard['id']}'),
            center: LatLng(coordinates['lat'], coordinates['lng']),
            radius: severity * 1000, // Radius based on severity
            fillColor: circleColor.withValues(alpha: 0.3),
            strokeColor: circleColor,
            strokeWidth: 2,
          ),
        );
      }
    }

    setState(() {
      _heatmapCircles = circles;
    });
  }

  bool _shouldShowHazard(Map<String, dynamic> hazard) {
    // Apply layer filters
    if (!_layerStates['citizen_reports']! &&
        hazard['reportedBy'] != 'NOAA Alert System' &&
        hazard['reportedBy'] != 'Coast Guard') {
      return false;
    }
    if (!_layerStates['official_alerts']! &&
        (hazard['reportedBy'] == 'NOAA Alert System' ||
            hazard['reportedBy'] == 'Coast Guard')) {
      return false;
    }

    return true;
  }

  double _getMarkerHue(String alertLevel) {
    switch (alertLevel) {
      case 'high':
        return BitmapDescriptor.hueRed;
      case 'medium':
        return BitmapDescriptor.hueOrange;
      case 'low':
        return BitmapDescriptor.hueGreen;
      default:
        return BitmapDescriptor.hueOrange;
    }
  }

  void _checkEmergencyAlerts() {
    if (_emergencyAlerts.isNotEmpty) {
      setState(() {
        _isEmergencyMode = true;
      });
    }
  }

  void _showHazardInfo(Map<String, dynamic> hazard) {
    setState(() {
      _selectedHazard = hazard;
    });
  }

  void _hideHazardInfo() {
    setState(() {
      _selectedHazard = null;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      controller.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
      );
    }
  }

  void _onMapLongPress(LatLng position) {
    // Navigate to hazard reporting with pre-filled location
    Navigator.pushNamed(
      context,
      '/hazard-reporting-screen',
      arguments: {
        'latitude': position.latitude,
        'longitude': position.longitude,
      },
    );
  }

  void _onLocationSelected(String location) {
    // Mock location search - in real app would use geocoding
    final mockCoordinates = {
      'Pacific Ocean, California': LatLng(34.0522, -118.2437),
      'Atlantic Ocean, Florida': LatLng(25.7617, -80.1918),
      'Gulf of Mexico, Texas': LatLng(29.3013, -94.7977),
    };

    final coordinates = mockCoordinates[location];
    if (coordinates != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(coordinates, 12.0),
      );
    }
  }

  void _onLayerToggled(String layerKey, bool isEnabled) {
    setState(() {
      _layerStates[layerKey] = isEnabled;
    });

    if (layerKey == 'heatmap') {
      _createHeatmapCircles();
    } else {
      _createMarkers();
    }
  }

  void _onFiltersChanged(Map<String, dynamic> filters) {
    // Apply filters and refresh markers
    _createMarkers();
    _createHeatmapCircles();
  }

  void _toggleFilterPanel() {
    setState(() {
      _isFilterPanelVisible = !_isFilterPanelVisible;
    });
  }

  void _dismissEmergencyAlert() {
    setState(() {
      _isEmergencyMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Interactive Map',
        actions: [
          IconButton(
            onPressed: _toggleFilterPanel,
            icon: CustomIconWidget(
              iconName: 'filter_list',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.onPrimary,
            ),
            tooltip: 'Filter Hazards',
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isHeatmapEnabled = !_isHeatmapEnabled;
                _layerStates['heatmap'] = _isHeatmapEnabled;
              });
              _createHeatmapCircles();
            },
            icon: CustomIconWidget(
              iconName: _isHeatmapEnabled ? 'gradient' : 'scatter_plot',
              size: 24,
              color: _isHeatmapEnabled
                  ? AppTheme.warningColor
                  : AppTheme.lightTheme.colorScheme.onPrimary,
            ),
            tooltip: 'Toggle Heatmap',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentPosition != null
                  ? LatLng(
                      _currentPosition!.latitude, _currentPosition!.longitude)
                  : LatLng(39.8283, -98.5795), // Center of US
              zoom: 6.0,
            ),
            markers: _markers,
            circles: _heatmapCircles,
            onLongPress: _onMapLongPress,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            zoomGesturesEnabled: true,
            mapType: MapType.normal,
          ),

          // Search Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: MapSearchBar(
              onLocationSelected: _onLocationSelected,
              onMyLocationPressed: _getCurrentLocation,
              isLoading: _isLoadingLocation,
            ),
          ),

          // Layer Controls
          MapLayerControls(
            onLayerToggled: _onLayerToggled,
            layerStates: _layerStates,
          ),

          // Filter Panel
          if (_isFilterPanelVisible)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: MapFilterPanel(
                onFiltersChanged: _onFiltersChanged,
                isVisible: _isFilterPanelVisible,
                onClose: () {
                  setState(() {
                    _isFilterPanelVisible = false;
                  });
                },
              ),
            ),

          // Hazard Info Card
          if (_selectedHazard != null)
            Positioned(
              bottom: 12.h,
              left: 0,
              right: 0,
              child: HazardMarkerInfo(
                hazardData: _selectedHazard!,
                onClose: _hideHazardInfo,
                onViewDetails: () {
                  // Navigate to hazard details
                  Navigator.pushNamed(
                    context,
                    '/hazard-details-screen',
                    arguments: _selectedHazard,
                  );
                },
              ),
            ),

          // Emergency Alert Overlay
          if (_isEmergencyMode)
            EmergencyAlertOverlay(
              emergencyAlerts: _emergencyAlerts,
              onDismiss: _dismissEmergencyAlert,
            ),

          // Offline Mode Indicator
          if (!kIsWeb) // Only show on mobile
            Positioned(
              top: 12.h,
              left: 4.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.successColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Online',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 2, // Map tab
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home-dashboard');
              break;
            case 1:
              Navigator.pushNamed(context, '/hazard-reporting-screen');
              break;
            case 2:
              // Already on map screen
              break;
            case 3:
              Navigator.pushNamed(context, '/analytics-dashboard-screen');
              break;
          }
        },
      ),
    );
  }
}
