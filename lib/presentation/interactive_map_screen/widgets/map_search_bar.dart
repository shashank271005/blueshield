import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MapSearchBar extends StatefulWidget {
  final Function(String) onLocationSelected;
  final VoidCallback onMyLocationPressed;
  final bool isLoading;

  const MapSearchBar({
    super.key,
    required this.onLocationSelected,
    required this.onMyLocationPressed,
    this.isLoading = false,
  });

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;
  List<Map<String, dynamic>> _suggestions = [];

  final List<Map<String, dynamic>> _mockSuggestions = [
    {
      'name': 'Pacific Ocean, California',
      'description': 'Coastal area near Los Angeles',
      'coordinates': {'lat': 34.0522, 'lng': -118.2437},
    },
    {
      'name': 'Atlantic Ocean, Florida',
      'description': 'Miami Beach coastline',
      'coordinates': {'lat': 25.7617, 'lng': -80.1918},
    },
    {
      'name': 'Gulf of Mexico, Texas',
      'description': 'Galveston Bay area',
      'coordinates': {'lat': 29.3013, 'lng': -94.7977},
    },
    {
      'name': 'Chesapeake Bay, Maryland',
      'description': 'Baltimore harbor region',
      'coordinates': {'lat': 39.2904, 'lng': -76.6122},
    },
    {
      'name': 'San Francisco Bay, California',
      'description': 'Golden Gate area',
      'coordinates': {'lat': 37.7749, 'lng': -122.4194},
    },
    {
      'name': 'Puget Sound, Washington',
      'description': 'Seattle waterfront',
      'coordinates': {'lat': 47.6062, 'lng': -122.3321},
    },
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _suggestions.isNotEmpty) {
      setState(() {
        _suggestions.clear();
        _isSearching = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _suggestions.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _suggestions = _mockSuggestions
          .where((suggestion) =>
              suggestion['name'].toLowerCase().contains(query.toLowerCase()) ||
              suggestion['description']
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .take(5)
          .toList();
    });
  }

  void _selectSuggestion(Map<String, dynamic> suggestion) {
    _searchController.text = suggestion['name'];
    setState(() {
      _suggestions.clear();
      _isSearching = false;
    });
    _focusNode.unfocus();
    widget.onLocationSelected(suggestion['name']);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _suggestions.clear();
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search locations...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'search',
                        size: 20,
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: _clearSearch,
                            icon: CustomIconWidget(
                              iconName: 'clear',
                              size: 20,
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 6.h,
                color: AppTheme.lightTheme.dividerColor.withValues(alpha: 0.3),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isLoading ? null : widget.onMyLocationPressed,
                  borderRadius:
                      BorderRadius.horizontal(right: Radius.circular(12)),
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    child: widget.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.lightTheme.colorScheme.primary,
                              ),
                            ),
                          )
                        : CustomIconWidget(
                            iconName: 'my_location',
                            size: 24,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_suggestions.isNotEmpty) _buildSuggestionsList(),
      ],
    );
  }

  Widget _buildSuggestionsList() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
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
        children: _suggestions.map((suggestion) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _selectSuggestion(suggestion),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'location_on',
                        size: 16,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suggestion['name'],
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            suggestion['description'],
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    CustomIconWidget(
                      iconName: 'north_west',
                      size: 16,
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
