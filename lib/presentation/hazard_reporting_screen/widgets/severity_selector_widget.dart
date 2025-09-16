import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SeveritySelectorWidget extends StatefulWidget {
  final String? selectedSeverity;
  final ValueChanged<String> onSeveritySelected;

  const SeveritySelectorWidget({
    super.key,
    this.selectedSeverity,
    required this.onSeveritySelected,
  });

  @override
  State<SeveritySelectorWidget> createState() => _SeveritySelectorWidgetState();
}

class _SeveritySelectorWidgetState extends State<SeveritySelectorWidget> {
  final List<Map<String, dynamic>> severityLevels = [
    {
      'id': 'low',
      'name': 'Low',
      'description': 'Minor hazard with limited impact',
      'color': Color(0xFFFDD835), // Yellow 'icon': 'info',
    },
    {
      'id': 'medium',
      'name': 'Medium',
      'description': 'Moderate hazard requiring attention',
      'color': Color(0xFFF57C00), // Orange 'icon': 'warning',
    },
    {
      'id': 'high',
      'name': 'High',
      'description': 'Severe hazard requiring immediate action',
      'color': Color(0xFFD32F2F), // Red 'icon': 'dangerous',
    },
  ];

  void _selectSeverity(String severity) {
    HapticFeedback.lightImpact();
    widget.onSeveritySelected(severity);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Severity Level *',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Select the severity level based on the potential impact',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: severityLevels.map((severity) {
            final isSelected = widget.selectedSeverity == severity['id'];
            final index = severityLevels.indexOf(severity);

            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: index < severityLevels.length - 1 ? 2.w : 0,
                ),
                child: _buildSeverityCard(severity, isSelected),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSeverityCard(Map<String, dynamic> severity, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectSeverity(severity['id']),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 2.w),
          decoration: BoxDecoration(
            color: isSelected
                ? (severity['color'] as Color).withValues(alpha: 0.1)
                : AppTheme.lightTheme.colorScheme.surface,
            border: Border.all(
              color: isSelected
                  ? severity['color']
                  : AppTheme.lightTheme.dividerColor,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color:
                          (severity['color'] as Color).withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppTheme.lightTheme.shadowColor,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
          ),
          child: Column(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: (severity['color'] as Color)
                      .withValues(alpha: isSelected ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: severity['icon'],
                    color: severity['color'],
                    size: 6.w,
                  ),
                ),
              ),
              SizedBox(height: 1.5.h),
              Text(
                severity['name'],
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? severity['color']
                      : AppTheme.lightTheme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 0.5.h),
              Text(
                severity['description'],
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                  fontSize: 10.sp,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isSelected) ...[
                SizedBox(height: 1.h),
                Container(
                  width: 5.w,
                  height: 5.w,
                  decoration: BoxDecoration(
                    color: severity['color'],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'check',
                      color: Colors.white,
                      size: 3.w,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
