import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HazardMarkerInfo extends StatelessWidget {
  final Map<String, dynamic> hazardData;
  final VoidCallback onClose;
  final VoidCallback? onViewDetails;

  const HazardMarkerInfo({
    super.key,
    required this.hazardData,
    required this.onClose,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildContent(),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final alertLevel = hazardData['alertLevel'] ?? 'medium';
    Color alertColor = AppTheme.warningColor;
    if (alertLevel == 'high')
      alertColor = AppTheme.lightTheme.colorScheme.error;
    if (alertLevel == 'low') alertColor = AppTheme.successColor;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: alertColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: alertColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: _getHazardIcon(hazardData['type'] ?? 'tsunami'),
              size: 20,
              color: alertColor,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hazardData['type'] ?? 'Ocean Hazard',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: alertColor,
                  ),
                ),
                Text(
                  '${alertLevel.toUpperCase()} ALERT',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: alertColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: CustomIconWidget(
              iconName: 'close',
              size: 20,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
              'Location', hazardData['location'] ?? 'Unknown Location'),
          SizedBox(height: 2.h),
          _buildInfoRow('Reported', _formatTimestamp(hazardData['timestamp'])),
          SizedBox(height: 2.h),
          _buildInfoRow(
              'Status', _getStatusText(hazardData['status'] ?? 'pending')),
          if (hazardData['description'] != null) ...[
            SizedBox(height: 2.h),
            Text(
              'Description',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              hazardData['description'],
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (hazardData['imageUrl'] != null) ...[
            SizedBox(height: 2.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomImageWidget(
                imageUrl: hazardData['imageUrl'],
                width: double.infinity,
                height: 20.h,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20.w,
          child: Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
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
            child: OutlinedButton.icon(
              onPressed: () {
                // Share functionality
              },
              icon: CustomIconWidget(
                iconName: 'share',
                size: 16,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              label: Text('Share'),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: onViewDetails,
              icon: CustomIconWidget(
                iconName: 'info',
                size: 16,
                color: AppTheme.lightTheme.colorScheme.onPrimary,
              ),
              label: Text('View Details'),
            ),
          ),
        ],
      ),
    );
  }

  String _getHazardIcon(String type) {
    switch (type.toLowerCase()) {
      case 'tsunami':
        return 'waves';
      case 'storm surge':
        return 'storm';
      case 'high waves':
        return 'water';
      case 'coastal erosion':
        return 'landscape';
      case 'rip current':
        return 'current_exchange';
      default:
        return 'warning';
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';

    DateTime dateTime;
    if (timestamp is String) {
      dateTime = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
      return 'Unknown';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return '✓ Verified';
      case 'pending':
        return '⏳ Pending Review';
      case 'rejected':
        return '✗ Rejected';
      default:
        return status;
    }
  }
}
