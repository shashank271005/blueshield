import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MapFilterPanel extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersChanged;
  final bool isVisible;
  final VoidCallback onClose;

  const MapFilterPanel({
    super.key,
    required this.onFiltersChanged,
    required this.isVisible,
    required this.onClose,
  });

  @override
  State<MapFilterPanel> createState() => _MapFilterPanelState();
}

class _MapFilterPanelState extends State<MapFilterPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  List<String> selectedHazardTypes = [];
  String selectedDateRange = 'All Time';
  String selectedVerificationStatus = 'All';
  String selectedAlertLevel = 'All';

  final List<Map<String, dynamic>> hazardTypes = [
    {'name': 'Tsunami', 'icon': 'waves', 'color': Color(0xFFD32F2F)},
    {'name': 'Storm Surge', 'icon': 'storm', 'color': Color(0xFFF57C00)},
    {'name': 'High Waves', 'icon': 'water', 'color': Color(0xFF1976D2)},
    {
      'name': 'Coastal Erosion',
      'icon': 'landscape',
      'color': Color(0xFF388E3C)
    },
    {
      'name': 'Rip Current',
      'icon': 'current_exchange',
      'color': Color(0xFF7B1FA2)
    },
  ];

  final List<String> dateRanges = [
    'Last Hour',
    'Last 24 Hours',
    'Last Week',
    'Last Month',
    'All Time'
  ];

  final List<String> verificationStatuses = [
    'All',
    'Verified',
    'Pending',
    'Rejected'
  ];

  final List<String> alertLevels = ['All', 'High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _animationController.reverse();
    }
  }

  @override
  void didUpdateWidget(MapFilterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filters = {
      'hazardTypes': selectedHazardTypes,
      'dateRange': selectedDateRange,
      'verificationStatus': selectedVerificationStatus,
      'alertLevel': selectedAlertLevel,
    };
    widget.onFiltersChanged(filters);
    widget.onClose();
  }

  void _clearFilters() {
    setState(() {
      selectedHazardTypes.clear();
      selectedDateRange = 'All Time';
      selectedVerificationStatus = 'All';
      selectedAlertLevel = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100.h),
          child: Container(
            height: 70.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHazardTypeSection(),
                        SizedBox(height: 3.h),
                        _buildDateRangeSection(),
                        SizedBox(height: 3.h),
                        _buildVerificationStatusSection(),
                        SizedBox(height: 3.h),
                        _buildAlertLevelSection(),
                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ),
                _buildActionButtons(),
              ],
            ),
          ),
        );
      },
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
            'Filter Hazards',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
          IconButton(
            onPressed: widget.onClose,
            icon: CustomIconWidget(
              iconName: 'close',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHazardTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hazard Types',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: hazardTypes.map((hazard) {
            final isSelected = selectedHazardTypes.contains(hazard['name']);
            return FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: hazard['icon'],
                    size: 16,
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.onPrimary
                        : hazard['color'],
                  ),
                  SizedBox(width: 1.w),
                  Text(hazard['name']),
                ],
              ),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedHazardTypes.add(hazard['name']);
                  } else {
                    selectedHazardTypes.remove(hazard['name']);
                  }
                });
              },
              selectedColor: AppTheme.lightTheme.colorScheme.primary,
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              side: BorderSide(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.dividerColor,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: dateRanges.map((range) {
            final isSelected = selectedDateRange == range;
            return ChoiceChip(
              selected: isSelected,
              label: Text(range),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    selectedDateRange = range;
                  });
                }
              },
              selectedColor: AppTheme.lightTheme.colorScheme.primary,
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              side: BorderSide(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.dividerColor,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVerificationStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verification Status',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: verificationStatuses.map((status) {
            final isSelected = selectedVerificationStatus == status;
            Color statusColor = AppTheme.lightTheme.colorScheme.onSurface;
            if (status == 'Verified') statusColor = AppTheme.successColor;
            if (status == 'Pending') statusColor = AppTheme.warningColor;
            if (status == 'Rejected')
              statusColor = AppTheme.lightTheme.colorScheme.error;

            return ChoiceChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (status != 'All') ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.onPrimary
                            : statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 1.w),
                  ],
                  Text(status),
                ],
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    selectedVerificationStatus = status;
                  });
                }
              },
              selectedColor: AppTheme.lightTheme.colorScheme.primary,
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              side: BorderSide(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.dividerColor,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAlertLevelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alert Level',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: alertLevels.map((level) {
            final isSelected = selectedAlertLevel == level;
            Color levelColor = AppTheme.lightTheme.colorScheme.onSurface;
            if (level == 'High')
              levelColor = AppTheme.lightTheme.colorScheme.error;
            if (level == 'Medium') levelColor = AppTheme.warningColor;
            if (level == 'Low') levelColor = AppTheme.successColor;

            return ChoiceChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (level != 'All') ...[
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.onPrimary
                            : levelColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 1.w),
                  ],
                  Text(level),
                ],
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    selectedAlertLevel = level;
                  });
                }
              },
              selectedColor: AppTheme.lightTheme.colorScheme.primary,
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              side: BorderSide(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.dividerColor,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.lightTheme.dividerColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _clearFilters,
              child: Text('Clear All'),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
