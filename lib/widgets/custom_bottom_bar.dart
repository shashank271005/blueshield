import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom Bottom Navigation Bar for ocean hazard reporting application
/// Implements clean, accessible navigation with haptic feedback
class CustomBottomBar extends StatelessWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when item is tapped
  final ValueChanged<int> onTap;

  /// Bottom bar variant for different contexts
  final CustomBottomBarVariant variant;

  /// Whether to show labels (defaults to true)
  final bool showLabels;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom selected item color
  final Color? selectedItemColor;

  /// Custom unselected item color
  final Color? unselectedItemColor;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.variant = CustomBottomBarVariant.standard,
    this.showLabels = true,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  /// Factory constructor for floating variant
  factory CustomBottomBar.floating({
    Key? key,
    required int currentIndex,
    required ValueChanged<int> onTap,
    bool showLabels = false,
  }) {
    return CustomBottomBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      variant: CustomBottomBarVariant.floating,
      showLabels: showLabels,
    );
  }

  /// Factory constructor for minimal variant
  factory CustomBottomBar.minimal({
    Key? key,
    required int currentIndex,
    required ValueChanged<int> onTap,
    bool showLabels = true,
  }) {
    return CustomBottomBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      variant: CustomBottomBarVariant.minimal,
      showLabels: showLabels,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final items = _getNavigationItems(context);

    switch (variant) {
      case CustomBottomBarVariant.standard:
        return _buildStandardBottomBar(context, theme, colorScheme, items);
      case CustomBottomBarVariant.floating:
        return _buildFloatingBottomBar(context, theme, colorScheme, items);
      case CustomBottomBarVariant.minimal:
        return _buildMinimalBottomBar(context, theme, colorScheme, items);
    }
  }

  Widget _buildStandardBottomBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    List<BottomNavigationBarItem> items,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: _handleTap,
          items: items,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: selectedItemColor ?? colorScheme.primary,
          unselectedItemColor: unselectedItemColor ??
              colorScheme.onSurface.withValues(alpha: 0.6),
          showSelectedLabels: showLabels,
          showUnselectedLabels: showLabels,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 24,
        ),
      ),
    );
  }

  Widget _buildFloatingBottomBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    List<BottomNavigationBarItem> items,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: _handleTap,
              items: items,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              selectedItemColor: selectedItemColor ?? colorScheme.primary,
              unselectedItemColor: unselectedItemColor ??
                  colorScheme.onSurface.withValues(alpha: 0.6),
              showSelectedLabels: showLabels,
              showUnselectedLabels: showLabels,
              elevation: 0,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              iconSize: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalBottomBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    List<BottomNavigationBarItem> items,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: _handleTap,
          items: items,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: selectedItemColor ?? colorScheme.primary,
          unselectedItemColor: unselectedItemColor ??
              colorScheme.onSurface.withValues(alpha: 0.6),
          showSelectedLabels: showLabels,
          showUnselectedLabels: showLabels,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 24,
        ),
      ),
    );
  }

  void _handleTap(int index) {
    if (index != currentIndex) {
      HapticFeedback.lightImpact();
      _navigateToScreen(index);
      onTap(index);
    }
  }

  void _navigateToScreen(int index) {
    // Note: This method would typically use a navigation service or state management
    // For now, we'll use basic Navigator.pushNamed
    // In a real app, consider using go_router or similar for better navigation management
  }

  List<BottomNavigationBarItem> _getNavigationItems(BuildContext context) {
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard_rounded),
        label: 'Dashboard',
        tooltip: 'Home Dashboard',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.report_outlined),
        activeIcon: Icon(Icons.report_rounded),
        label: 'Report',
        tooltip: 'Hazard Reporting',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.map_outlined),
        activeIcon: Icon(Icons.map_rounded),
        label: 'Map',
        tooltip: 'Interactive Map',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.analytics_outlined),
        activeIcon: Icon(Icons.analytics_rounded),
        label: 'Analytics',
        tooltip: 'Analytics Dashboard',
      ),
    ];
  }
}

/// Variants for different bottom bar styles
enum CustomBottomBarVariant {
  /// Standard bottom navigation bar with shadow
  standard,

  /// Floating bottom bar with rounded corners
  floating,

  /// Minimal bottom bar with top border only
  minimal,
}

/// Navigation helper widget that manages routing
class CustomBottomBarNavigator extends StatefulWidget {
  /// Initial route index
  final int initialIndex;

  /// Bottom bar variant
  final CustomBottomBarVariant variant;

  /// Whether to show labels
  final bool showLabels;

  const CustomBottomBarNavigator({
    super.key,
    this.initialIndex = 0,
    this.variant = CustomBottomBarVariant.standard,
    this.showLabels = true,
  });

  @override
  State<CustomBottomBarNavigator> createState() =>
      _CustomBottomBarNavigatorState();
}

class _CustomBottomBarNavigatorState extends State<CustomBottomBarNavigator> {
  late int _currentIndex;

  final List<String> _routes = [
    '/home-dashboard',
    '/hazard-reporting-screen',
    '/interactive-map-screen',
    '/analytics-dashboard-screen',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomBar(
      currentIndex: _currentIndex,
      variant: widget.variant,
      showLabels: widget.showLabels,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });

        // Navigate to the corresponding route
        if (index < _routes.length) {
          Navigator.pushNamed(context, _routes[index]);
        }
      },
    );
  }
}
