import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MapLayerControls extends StatefulWidget {
  final Function(String, bool) onLayerToggled;
  final Map<String, bool> layerStates;

  const MapLayerControls({
    super.key,
    required this.onLayerToggled,
    required this.layerStates,
  });

  @override
  State<MapLayerControls> createState() => _MapLayerControlsState();
}

class _MapLayerControlsState extends State<MapLayerControls>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  final List<Map<String, dynamic>> _layers = [
    {
      'key': 'citizen_reports',
      'name': 'Citizen Reports',
      'icon': 'report',
      'color': Color(0xFF1976D2),
      'description': 'User-submitted hazard reports',
    },
    {
      'key': 'official_alerts',
      'name': 'Official Alerts',
      'icon': 'warning',
      'color': Color(0xFFD32F2F),
      'description': 'Government verified alerts',
    },
    {
      'key': 'social_media',
      'name': 'Social Media',
      'icon': 'share',
      'color': Color(0xFF7B1FA2),
      'description': 'Social media mentions',
    },
    {
      'key': 'weather_overlay',
      'name': 'Weather Data',
      'icon': 'cloud',
      'color': Color(0xFF388E3C),
      'description': 'Current weather conditions',
    },
    {
      'key': 'heatmap',
      'name': 'Heatmap',
      'icon': 'gradient',
      'color': Color(0xFFF57C00),
      'description': 'Hazard density visualization',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 15.h,
      right: 4.w,
      child: Column(
        children: [
          _buildToggleButton(),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              margin: EdgeInsets.only(top: 1.h),
              constraints: BoxConstraints(
                maxWidth: 70.w,
                maxHeight: 50.h,
              ),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                      itemCount: _layers.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: AppTheme.lightTheme.dividerColor
                            .withValues(alpha: 0.3),
                      ),
                      itemBuilder: (context, index) {
                        final layer = _layers[index];
                        final isEnabled =
                            widget.layerStates[layer['key']] ?? false;
                        return _buildLayerItem(layer, isEnabled);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleExpansion,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(3.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'layers',
                  size: 24,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                if (_isExpanded) ...[
                  SizedBox(width: 2.w),
                  Text(
                    'Layers',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                SizedBox(width: 1.w),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: CustomIconWidget(
                    iconName: 'expand_more',
                    size: 20,
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightTheme.dividerColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Map Layers',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
          Text(
            '${_layers.where((layer) => widget.layerStates[layer['key']] ?? false).length}/${_layers.length}',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerItem(Map<String, dynamic> layer, bool isEnabled) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onLayerToggled(layer['key'], !isEnabled),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: isEnabled
                      ? layer['color'].withValues(alpha: 0.2)
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: layer['icon'],
                  size: 16,
                  color: isEnabled
                      ? layer['color']
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.5),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      layer['name'],
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isEnabled
                            ? AppTheme.lightTheme.colorScheme.onSurface
                            : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      layer['description'],
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: (value) =>
                    widget.onLayerToggled(layer['key'], value),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
