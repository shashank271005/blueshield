import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/date_range_selector_widget.dart';
import './widgets/export_options_widget.dart';
import './widgets/heatmap_widget.dart';
import './widgets/sentiment_gauge_widget.dart';
import './widgets/statistics_cards_widget.dart';
import './widgets/trend_charts_widget.dart';
import './widgets/word_cloud_widget.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with TickerProviderStateMixin {
  String selectedDateRange = '30d';
  bool isFilterPanelOpen = false;
  String? selectedKeywordFilter;
  late AnimationController _filterAnimationController;
  late Animation<double> _filterAnimation;

  @override
  void initState() {
    super.initState();
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _filterAnimationController.dispose();
    super.dispose();
  }

  void _toggleFilterPanel() {
    setState(() {
      isFilterPanelOpen = !isFilterPanelOpen;
    });
    
    if (isFilterPanelOpen) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
    }
  }

  void _onDateRangeSelected(String range) {
    setState(() {
      selectedDateRange = range;
    });
  }

  void _onWordTap(String word) {
    setState(() {
      selectedKeywordFilter = word;
    });
  }

  void _clearFilters() {
    setState(() {
      selectedKeywordFilter = null;
      selectedDateRange = '30d';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Analytics Dashboard',
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 24,
            ),
            onPressed: _toggleFilterPanel,
            tooltip: 'Filters',
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 24,
            ),
            onPressed: () {
              // Refresh data
              setState(() {});
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Range Selector
                DateRangeSelectorWidget(
                  selectedRange: selectedDateRange,
                  onRangeSelected: _onDateRangeSelected,
                ),
                
                SizedBox(height: 2.h),
                
                // Statistics Cards
                StatisticsCardsWidget(
                  selectedRange: selectedDateRange,
                ),
                
                SizedBox(height: 3.h),
                
                // Trend Charts
                TrendChartsWidget(
                  selectedRange: selectedDateRange,
                ),
                
                SizedBox(height: 3.h),
                
                // Heatmap Visualization
                HeatmapWidget(
                  selectedRange: selectedDateRange,
                ),
                
                SizedBox(height: 3.h),
                
                // Sentiment Analysis Gauge
                SentimentGaugeWidget(
                  selectedRange: selectedDateRange,
                ),
                
                SizedBox(height: 3.h),
                
                // Word Cloud
                WordCloudWidget(
                  selectedRange: selectedDateRange,
                  onWordTap: _onWordTap,
                ),
                
                SizedBox(height: 3.h),
                
                // Export Options
                ExportOptionsWidget(
                  selectedRange: selectedDateRange,
                ),
                
                SizedBox(height: 10.h), // Bottom padding for navigation
              ],
            ),
          ),
          
          // Filter Panel Overlay
          AnimatedBuilder(
            animation: _filterAnimation,
            builder: (context, child) {
              return isFilterPanelOpen
                  ? GestureDetector(
                      onTap: _toggleFilterPanel,
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.5 * _filterAnimation.value),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Transform.translate(
                            offset: Offset(0, (1 - _filterAnimation.value) * 300),
                            child: Container(
                              width: double.infinity,
                              constraints: BoxConstraints(maxHeight: 50.h),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.surface,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.lightTheme.shadowColor.withValues(alpha: 0.2),
                                    blurRadius: 16,
                                    offset: const Offset(0, -4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 12.w,
                                    height: 0.5.h,
                                    margin: EdgeInsets.symmetric(vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: AppTheme.lightTheme.colorScheme.outline,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Filters',
                                          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: _clearFilters,
                                          child: Text(
                                            'Clear All',
                                            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                                              color: AppTheme.lightTheme.primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    child: SingleChildScrollView(
                                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (selectedKeywordFilter != null) ...[
                                            Text(
                                              'Active Filters',
                                              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(height: 1.h),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 3.w,
                                                vertical: 1.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Keyword: $selectedKeywordFilter',
                                                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                                      color: AppTheme.lightTheme.primaryColor,
                                                    ),
                                                  ),
                                                  SizedBox(width: 2.w),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedKeywordFilter = null;
                                                      });
                                                    },
                                                    child: CustomIconWidget(
                                                      iconName: 'close',
                                                      color: AppTheme.lightTheme.primaryColor,
                                                      size: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 2.h),
                                          ],
                                          Text(
                                            'Date Range',
                                            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: 1.h),
                                          Text(
                                            'Currently showing data for: ${_getDateRangeLabel(selectedDateRange)}',
                                            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                              color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.7),
                                            ),
                                          ),
                                          SizedBox(height: 3.h),
                                          Text(
                                            'Data Sources',
                                            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: 1.h),
                                          _buildDataSourceItem('Citizen Reports', true),
                                          _buildDataSourceItem('Social Media', true),
                                          _buildDataSourceItem('Official Alerts', true),
                                          _buildDataSourceItem('Weather Data', false),
                                          SizedBox(height: 2.h),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 3, // Analytics tab
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home-dashboard');
              break;
            case 1:
              Navigator.pushNamed(context, '/hazard-reporting-screen');
              break;
            case 2:
              Navigator.pushNamed(context, '/interactive-map-screen');
              break;
            case 3:
              // Already on analytics dashboard
              break;
          }
        },
      ),
    );
  }

  String _getDateRangeLabel(String range) {
    switch (range) {
      case '7d':
        return 'Last 7 days';
      case '30d':
        return 'Last 30 days';
      case '3m':
        return 'Last 3 months';
      case '1y':
        return 'Last year';
      default:
        return 'Custom range';
    }
  }

  Widget _buildDataSourceItem(String title, bool isEnabled) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              // Handle data source toggle
            },
            activeColor: AppTheme.lightTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}