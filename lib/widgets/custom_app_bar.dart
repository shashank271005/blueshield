import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom AppBar widget for ocean hazard reporting application
/// Implements Purposeful Maritime Minimalism design with clean, professional appearance
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title to display in the app bar
  final String title;

  /// Whether to show the back button (defaults to true if Navigator can pop)
  final bool? showBackButton;

  /// Custom leading widget (overrides back button if provided)
  final Widget? leading;

  /// List of action widgets to display on the right
  final List<Widget>? actions;

  /// Whether to center the title (defaults to true)
  final bool centerTitle;

  /// Custom background color (defaults to theme primary color)
  final Color? backgroundColor;

  /// Custom foreground color for text and icons
  final Color? foregroundColor;

  /// Elevation of the app bar (defaults to 2.0 for subtle depth)
  final double elevation;

  /// Whether to show a bottom border for additional definition
  final bool showBottomBorder;

  /// App bar variant for different contexts
  final CustomAppBarVariant variant;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 2.0,
    this.showBottomBorder = false,
    this.variant = CustomAppBarVariant.primary,
  });

  /// Factory constructor for emergency/critical contexts
  factory CustomAppBar.emergency({
    Key? key,
    required String title,
    List<Widget>? actions,
    bool centerTitle = true,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      actions: actions,
      centerTitle: centerTitle,
      variant: CustomAppBarVariant.emergency,
      elevation: 4.0,
    );
  }

  /// Factory constructor for transparent overlay on maps
  factory CustomAppBar.transparent({
    Key? key,
    required String title,
    List<Widget>? actions,
    bool centerTitle = true,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      actions: actions,
      centerTitle: centerTitle,
      variant: CustomAppBarVariant.transparent,
      elevation: 0.0,
    );
  }

  /// Factory constructor for minimal contexts
  factory CustomAppBar.minimal({
    Key? key,
    required String title,
    List<Widget>? actions,
    bool centerTitle = true,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      actions: actions,
      centerTitle: centerTitle,
      variant: CustomAppBarVariant.minimal,
      elevation: 0.0,
      showBottomBorder: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine colors based on variant
    Color? appBarBackgroundColor;
    Color? appBarForegroundColor;
    SystemUiOverlayStyle? systemOverlayStyle;

    switch (variant) {
      case CustomAppBarVariant.primary:
        appBarBackgroundColor = backgroundColor ?? colorScheme.primary;
        appBarForegroundColor = foregroundColor ?? colorScheme.onPrimary;
        systemOverlayStyle = SystemUiOverlayStyle.light;
        break;
      case CustomAppBarVariant.surface:
        appBarBackgroundColor = backgroundColor ?? colorScheme.surface;
        appBarForegroundColor = foregroundColor ?? colorScheme.onSurface;
        systemOverlayStyle = theme.brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light;
        break;
      case CustomAppBarVariant.transparent:
        appBarBackgroundColor = backgroundColor ?? Colors.transparent;
        appBarForegroundColor = foregroundColor ?? colorScheme.onSurface;
        systemOverlayStyle = SystemUiOverlayStyle.light;
        break;
      case CustomAppBarVariant.emergency:
        appBarBackgroundColor = backgroundColor ?? colorScheme.error;
        appBarForegroundColor = foregroundColor ?? colorScheme.onError;
        systemOverlayStyle = SystemUiOverlayStyle.light;
        break;
      case CustomAppBarVariant.minimal:
        appBarBackgroundColor = backgroundColor ?? colorScheme.surface;
        appBarForegroundColor = foregroundColor ?? colorScheme.onSurface;
        systemOverlayStyle = theme.brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light;
        break;
    }

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: appBarForegroundColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: appBarBackgroundColor,
      foregroundColor: appBarForegroundColor,
      elevation: elevation,
      shadowColor: theme.shadowColor.withValues(alpha: 0.1),
      systemOverlayStyle: systemOverlayStyle,
      leading: _buildLeading(context, appBarForegroundColor),
      actions: _buildActions(context, appBarForegroundColor),
      bottom: showBottomBorder
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(
                height: 1.0,
                color: theme.dividerColor.withValues(alpha: 0.2),
              ),
            )
          : null,
      shape: variant == CustomAppBarVariant.transparent
          ? null
          : const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
    );
  }

  Widget? _buildLeading(BuildContext context, Color? foregroundColor) {
    if (leading != null) return leading;

    final canPop = Navigator.of(context).canPop();
    final shouldShowBack = showBackButton ?? canPop;

    if (!shouldShowBack) return null;

    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: foregroundColor,
        size: 20,
      ),
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
      },
      tooltip: 'Back',
      splashRadius: 20,
    );
  }

  List<Widget>? _buildActions(BuildContext context, Color? foregroundColor) {
    if (actions == null) return null;

    return actions!.map((action) {
      if (action is IconButton) {
        return IconButton(
          icon: action.icon,
          onPressed: () {
            HapticFeedback.lightImpact();
            action.onPressed?.call();
          },
          color: foregroundColor,
          tooltip: action.tooltip,
          splashRadius: 20,
        );
      }
      return action;
    }).toList();
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (showBottomBorder ? 1.0 : 0.0));
}

/// Variants for different app bar contexts
enum CustomAppBarVariant {
  /// Primary brand color background (default)
  primary,

  /// Surface color background for secondary screens
  surface,

  /// Transparent background for overlays
  transparent,

  /// Error color background for critical alerts
  emergency,

  /// Minimal styling with bottom border
  minimal,
}
