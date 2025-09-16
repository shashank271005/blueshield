import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HazardTypeSelectorWidget extends StatefulWidget {
  final String? selectedHazardType;
  final ValueChanged<String> onHazardTypeSelected;

  const HazardTypeSelectorWidget({
    super.key,
    this.selectedHazardType,
    required this.onHazardTypeSelected,
  });

  @override
  State<HazardTypeSelectorWidget> createState() =>
      _HazardTypeSelectorWidgetState();
}

class _HazardTypeSelectorWidgetState extends State<HazardTypeSelectorWidget> {
  final List<Map<String, dynamic>> hazardTypes = [
    {
      'id': 'tsunami',
      'name': 'Tsunami',
      'icon': 'waves',
      'description': 'Large ocean waves caused by underwater disturbances',
      'color': Color(0xFFD32F2F),
    },
    {
      'id': 'storm_surge',
      'name': 'Storm Surge',
      'icon': 'thunderstorm',
      'description': 'Abnormal rise of water during storms',
      'color': Color(0xFFF57C00),
    },
    {
      'id': 'high_waves',
      'name': 'High Waves',
      'icon': 'water',
      'description': 'Unusually large waves that pose danger',
      'color': Color(0xFF1976D2),
    },
  ];

  void _selectHazardType(String hazardType) {
    HapticFeedback.lightImpact();
    widget.onHazardTypeSelected(hazardType);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hazard Type *',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        ...hazardTypes.map((hazard) => _buildHazardTypeCard(hazard)),
      ],
    );
  }

  Widget _buildHazardTypeCard(Map<String, dynamic> hazard) {
    final isSelected = widget.selectedHazardType == hazard['id'];

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectHazardType(hazard['id']),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1)
                  : AppTheme.lightTheme.colorScheme.surface,
              border: Border.all(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.dividerColor,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppTheme.lightTheme.shadowColor,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
            ),
            child: Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: (hazard['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: hazard['icon'],
                      color: hazard['color'],
                      size: 6.w,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hazard['name'],
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        hazard['description'],
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'check',
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        size: 4.w,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
