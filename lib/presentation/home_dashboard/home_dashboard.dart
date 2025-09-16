import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/activity_feed_widget.dart';
import './widgets/location_header_widget.dart';
import './widgets/metrics_card_widget.dart';
import './widgets/quick_action_widget.dart';
import './widgets/recommendations_widget.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isRefreshing = false;
  int _currentBottomIndex = 0;

  // Mock data for dashboard metrics
  final List<Map<String, dynamic>> _metricsData = [
    {
      "title": "Active Reports",
      "value": "247",
      "subtitle": "Last 24 hours",
      "iconName": "report",
      "showTrend": true,
      "isIncreasing": true,
    },
    {
      "title": "Verified Alerts",
      "value": "18",
      "subtitle": "This week",
      "iconName": "verified",
      "showTrend": true,
      "isIncreasing": false,
    },
    {
      "title": "Hotspots Nearby",
      "value": "5",
      "subtitle": "Within 10km",
      "iconName": "location_on",
      "showTrend": false,
      "isIncreasing": true,
    },
    {
      "title": "Response Time",
      "value": "12m",
      "subtitle": "Average",
      "iconName": "timer",
      "showTrend": true,
      "isIncreasing": false,
    },
  ];

  // Mock data for recent activities
  final List<Map<String, dynamic>> _activitiesData = [
    {
      "type": "tsunami",
      "title": "Tsunami Warning - Pacific Coast",
      "location": "Monterey Bay, CA",
      "timeAgo": "2 hours ago",
      "status": "verified",
      "imageUrl":
          "https://images.pexels.com/photos/1001682/pexels-photo-1001682.jpeg?auto=compress&cs=tinysrgb&w=800",
    },
    {
      "type": "storm_surge",
      "title": "High Storm Surge Alert",
      "location": "Miami Beach, FL",
      "timeAgo": "4 hours ago",
      "status": "pending",
      "imageUrl":
          "https://images.pexels.com/photos/1118873/pexels-photo-1118873.jpeg?auto=compress&cs=tinysrgb&w=800",
    },
    {
      "type": "high_waves",
      "title": "Dangerous Wave Conditions",
      "location": "Malibu, CA",
      "timeAgo": "6 hours ago",
      "status": "verified",
      "imageUrl":
          "https://images.pexels.com/photos/1001682/pexels-photo-1001682.jpeg?auto=compress&cs=tinysrgb&w=800",
    },
    {
      "type": "coastal_flooding",
      "title": "Coastal Flooding Report",
      "location": "Virginia Beach, VA",
      "timeAgo": "8 hours ago",
      "status": "rejected",
      "imageUrl":
          "https://images.pexels.com/photos/1118873/pexels-photo-1118873.jpeg?auto=compress&cs=tinysrgb&w=800",
    },
    {
      "type": "rip_current",
      "title": "Strong Rip Current Warning",
      "location": "Outer Banks, NC",
      "timeAgo": "12 hours ago",
      "status": "verified",
      "imageUrl":
          "https://images.pexels.com/photos/1001682/pexels-photo-1001682.jpeg?auto=compress&cs=tinysrgb&w=800",
    },
  ];

  // Mock data for recommendations
  final List<Map<String, dynamic>> _recommendationsData = [
    {
      "type": "Monitoring Station",
      "title": "Pacific Marine Station",
      "description":
          "Real-time wave and weather monitoring with 24/7 data collection and emergency alerts.",
      "distance": "2.3 km away",
      "iconName": "sensors",
      "imageUrl":
          "https://images.pexels.com/photos/1001682/pexels-photo-1001682.jpeg?auto=compress&cs=tinysrgb&w=800",
    },
    {
      "type": "Weather Warning",
      "title": "High Surf Advisory",
      "description":
          "Waves 8-12 feet expected through Thursday. Dangerous conditions for swimming and surfing.",
      "distance": "Your area",
      "iconName": "waves",
      "imageUrl":
          "https://images.pexels.com/photos/1118873/pexels-photo-1118873.jpeg?auto=compress&cs=tinysrgb&w=800",
    },
    {
      "type": "Emergency Contact",
      "title": "Coast Guard Station",
      "description":
          "24/7 emergency response and marine safety services. Direct hotline available.",
      "distance": "5.7 km away",
      "iconName": "local_hospital",
      "imageUrl":
          "https://images.pexels.com/photos/1001682/pexels-photo-1001682.jpeg?auto=compress&cs=tinysrgb&w=800",
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    HapticFeedback.lightImpact();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentBottomIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, '/interactive-map-screen');
        break;
      case 2:
        // Navigate to reports screen (not specified in routes)
        break;
      case 3:
        // Navigate to alerts screen (not specified in routes)
        break;
      case 4:
        // Navigate to profile screen (not specified in routes)
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: theme.colorScheme.primary,
            child: CustomScrollView(
              slivers: [
                // Location Header
                SliverToBoxAdapter(
                  child: LocationHeaderWidget(
                    location: "San Francisco Bay Area",
                    weather: "Partly Cloudy",
                    temperature: "72°F",
                    hasEmergencyAlert: true,
                    alertMessage:
                        "High surf advisory in effect until 6 PM PST. Waves 8-12 feet expected.",
                    notificationCount: 3,
                    onLocationTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushNamed(context, '/interactive-map-screen');
                    },
                    onNotificationTap: () {
                      HapticFeedback.lightImpact();
                      // Show notification drawer
                    },
                  ),
                ),

                // Metrics Cards
                SliverToBoxAdapter(
                  child: Container(
                    height: 25.h,
                    margin: EdgeInsets.symmetric(vertical: 2.h),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      itemCount: _metricsData.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(width: 3.w),
                      itemBuilder: (context, index) {
                        final metric = _metricsData[index];
                        return MetricsCardWidget(
                          title: metric['title'] as String,
                          value: metric['value'] as String,
                          subtitle: metric['subtitle'] as String,
                          iconName: metric['iconName'] as String,
                          showTrend: metric['showTrend'] as bool,
                          isIncreasing: metric['isIncreasing'] as bool,
                        );
                      },
                    ),
                  ),
                ),

                // Quick Actions Grid
                SliverToBoxAdapter(
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 1.h),
                          child: Text(
                            'Quick Actions',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Wrap(
                          spacing: 3.w,
                          runSpacing: 2.h,
                          children: [
                            QuickActionWidget(
                              title: 'View Hotspots',
                              iconName: 'location_on',
                              onTap: () {
                                Navigator.pushNamed(
                                    context, '/interactive-map-screen');
                              },
                            ),
                            QuickActionWidget(
                              title: 'My Reports',
                              iconName: 'assignment',
                              onTap: () {
                                // Navigate to my reports
                              },
                            ),
                            QuickActionWidget(
                              title: 'Analytics',
                              iconName: 'analytics',
                              onTap: () {
                                Navigator.pushNamed(
                                    context, '/analytics-dashboard-screen');
                              },
                            ),
                            QuickActionWidget(
                              title: 'Emergency Contacts',
                              iconName: 'emergency',
                              backgroundColor: theme.colorScheme.error
                                  .withValues(alpha: 0.1),
                              iconColor: theme.colorScheme.error,
                              onTap: () {
                                // Show emergency contacts
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Recommendations
                SliverToBoxAdapter(
                  child: RecommendationsWidget(
                    recommendations: _recommendationsData,
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 2.h)),

                // Recent Activity Feed
                SliverToBoxAdapter(
                  child: ActivityFeedWidget(
                    activities: _activitiesData,
                  ),
                ),

                // Bottom padding for FAB
                SliverToBoxAdapter(child: SizedBox(height: 10.h)),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.pushNamed(context, '/hazard-reporting-screen');
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 8.0,
        icon: CustomIconWidget(
          iconName: 'add_alert',
          color: theme.colorScheme.onPrimary,
          size: 6.w,
        ),
        label: Text(
          'Report Hazard',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        elevation: 8.0,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'home',
              color: _currentBottomIndex == 0
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 6.w,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'map',
              color: _currentBottomIndex == 1
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 6.w,
            ),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'assignment',
              color: _currentBottomIndex == 2
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 6.w,
            ),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'notifications',
              color: _currentBottomIndex == 3
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 6.w,
            ),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              color: _currentBottomIndex == 4
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 6.w,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
