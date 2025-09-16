import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class HeatmapWidget extends StatefulWidget {
  final String selectedRange;

  const HeatmapWidget({
    super.key,
    required this.selectedRange,
  });

  @override
  State<HeatmapWidget> createState() => _HeatmapWidgetState();
}

class _HeatmapWidgetState extends State<HeatmapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  final List<Map<String, dynamic>> hotspotData = [
    {
      'id': 'hotspot_1',
      'location': LatLng(40.7128, -74.0060), // New York 'intensity': 0.8,
      'reportCount': 45,
      'title': 'New York Harbor',
    },
    {
      'id': 'hotspot_2',
      'location': LatLng(34.0522, -118.2437), // Los Angeles 'intensity': 0.6,
      'reportCount': 32,
      'title': 'Santa Monica Bay',
    },
    {
      'id': 'hotspot_3',
      'location': LatLng(25.7617, -80.1918), // Miami 'intensity': 0.9,
      'reportCount': 58,
      'title': 'Miami Beach',
    },
    {
      'id': 'hotspot_4',
      'location': LatLng(37.7749, -122.4194), // San Francisco 'intensity': 0.7,
      'reportCount': 38,
      'title': 'San Francisco Bay',
    },
    {
      'id': 'hotspot_5',
      'location': LatLng(47.6062, -122.3321), // Seattle 'intensity': 0.5,
      'reportCount': 24,
      'title': 'Puget Sound',
    },
  ];

  @override
  void initState() {
    super.initState();
    _createMarkersAndCircles();
  }

  void _createMarkersAndCircles() {
    Set<Marker> markers = {};
    Set<Circle> circles = {};

    for (var hotspot in hotspotData) {
      final intensity = hotspot['intensity'] as double;
      final reportCount = hotspot['reportCount'] as int;

      // Create circle for heatmap visualization
      circles.add(
        Circle(
          circleId: CircleId('circle_${hotspot['id']}'),
          center: hotspot['location'],
          radius: 15000 * intensity, // Radius based on intensity
          fillColor: _getIntensityColor(intensity).withValues(alpha: 0.3),
          strokeColor: _getIntensityColor(intensity),
          strokeWidth: 2,
        ),
      );

      // Create marker for hotspot
      markers.add(
        Marker(
          markerId: MarkerId(hotspot['id']),
          position: hotspot['location'],
          infoWindow: InfoWindow(
            title: hotspot['title'],
            snippet:
                '$reportCount reports • ${(intensity * 100).toInt()}% intensity',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerHue(intensity),
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
      _circles = circles;
    });
  }

  Color _getIntensityColor(double intensity) {
    if (intensity >= 0.8) {
      return AppTheme.lightTheme.colorScheme.error;
    } else if (intensity >= 0.6) {
      return AppTheme.warningColor;
    } else if (intensity >= 0.4) {
      return AppTheme.lightTheme.primaryColor;
    } else {
      return AppTheme.successColor;
    }
  }

  double _getMarkerHue(double intensity) {
    if (intensity >= 0.8) {
      return BitmapDescriptor.hueRed;
    } else if (intensity >= 0.6) {
      return BitmapDescriptor.hueOrange;
    } else if (intensity >= 0.4) {
      return BitmapDescriptor.hueBlue;
    } else {
      return BitmapDescriptor.hueGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Geographic Hotspots',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            height: 35.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                initialCameraPosition: const CameraPosition(
                  target: LatLng(39.8283, -98.5795), // Center of US
                  zoom: 4.0,
                ),
                markers: _markers,
                circles: _circles,
                mapType: MapType.normal,
                zoomControlsEnabled: true,
                myLocationButtonEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Intensity Legend',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem('High',
                        AppTheme.lightTheme.colorScheme.error, '80-100%'),
                    _buildLegendItem('Medium', AppTheme.warningColor, '60-79%'),
                    _buildLegendItem(
                        'Low', AppTheme.lightTheme.primaryColor, '40-59%'),
                    _buildLegendItem('Minimal', AppTheme.successColor, '0-39%'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String range) {
    return Column(
      children: [
        Container(
          width: 4.w,
          height: 4.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          range,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.6),
            fontSize: 8.sp,
          ),
        ),
      ],
    );
  }
}
