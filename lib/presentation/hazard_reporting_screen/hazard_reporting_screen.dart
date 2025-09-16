import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/hazard_type_selector_widget.dart';
import './widgets/location_selector_widget.dart';
import './widgets/media_upload_widget.dart';
import './widgets/severity_selector_widget.dart';
import './widgets/voice_input_widget.dart';

class HazardReportingScreen extends StatefulWidget {
  const HazardReportingScreen({super.key});

  @override
  State<HazardReportingScreen> createState() => _HazardReportingScreenState();
}

class _HazardReportingScreenState extends State<HazardReportingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _affectedAreaController = TextEditingController();
  final _witnessCountController = TextEditingController();
  final _scrollController = ScrollController();

  // Form data
  String? _selectedHazardType;
  String? _selectedSeverity;
  LatLng? _selectedLocation;
  List<XFile> _selectedMedia = [];
  bool _emergencyServicesContacted = false;
  bool _isSubmitting = false;
  double _formProgress = 0.0;

  @override
  void dispose() {
    _descriptionController.dispose();
    _affectedAreaController.dispose();
    _witnessCountController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateFormProgress() {
    double progress = 0.0;
    int totalFields = 3; // Required fields: hazard type, severity, location
    int completedFields = 0;

    if (_selectedHazardType != null) completedFields++;
    if (_selectedSeverity != null) completedFields++;
    if (_selectedLocation != null) completedFields++;

    progress = completedFields / totalFields;

    // Add bonus progress for optional fields
    if (_descriptionController.text.isNotEmpty) progress += 0.1;
    if (_selectedMedia.isNotEmpty) progress += 0.1;

    setState(() {
      _formProgress = progress.clamp(0.0, 1.0);
    });
  }

  bool _isFormValid() {
    return _selectedHazardType != null &&
        _selectedSeverity != null &&
        _selectedLocation != null;
  }

  Future<void> _submitReport() async {
    if (!_isFormValid()) {
      _showValidationError();
      return;
    }

    // Show confirmation dialog
    final shouldSubmit = await _showConfirmationDialog();
    if (!shouldSubmit) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 3));

      // Generate mock report ID
      final reportId =
          'HR${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

      if (mounted) {
        _showSuccessDialog(reportId);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showValidationError() {
    final missingFields = <String>[];
    if (_selectedHazardType == null) missingFields.add('Hazard Type');
    if (_selectedSeverity == null) missingFields.add('Severity Level');
    if (_selectedLocation == null) missingFields.add('Location');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please complete: ${missingFields.join(', ')}'),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Submit Hazard Report',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please review your report details:',
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
                SizedBox(height: 2.h),
                _buildSummaryItem(
                    'Hazard Type', _getHazardTypeName(_selectedHazardType!)),
                _buildSummaryItem(
                    'Severity', _getSeverityName(_selectedSeverity!)),
                _buildSummaryItem('Location',
                    '${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}'),
                if (_selectedMedia.isNotEmpty)
                  _buildSummaryItem(
                      'Media Files', '${_selectedMedia.length} file(s)'),
                if (_descriptionController.text.isNotEmpty)
                  _buildSummaryItem(
                      'Description',
                      _descriptionController.text.length > 50
                          ? '${_descriptionController.text.substring(0, 50)}...'
                          : _descriptionController.text),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Submit Report'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              '$label:',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String reportId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.successColor,
              size: 6.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Report Submitted',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your hazard report has been successfully submitted and is now under review.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Report Tracking Number',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    reportId,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 6.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Submission Failed',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
          ],
        ),
        content: Text(
          'Failed to submit your report. Please check your internet connection and try again.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _submitReport();
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _getHazardTypeName(String id) {
    switch (id) {
      case 'tsunami':
        return 'Tsunami';
      case 'storm_surge':
        return 'Storm Surge';
      case 'high_waves':
        return 'High Waves';
      default:
        return 'Unknown';
    }
  }

  String _getSeverityName(String id) {
    switch (id) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Report Ocean Hazard',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        elevation: 2,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'close',
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            size: 6.w,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(
            height: 1.h,
            child: LinearProgressIndicator(
              value: _formProgress,
              backgroundColor: AppTheme.lightTheme.colorScheme.onPrimary
                  .withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.lightTheme.colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          CustomIconWidget(
                            iconName: 'report_problem',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 12.w,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Help Keep Our Oceans Safe',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Report ocean hazards to help protect coastal communities and marine activities.',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Hazard Type Selection
                    HazardTypeSelectorWidget(
                      selectedHazardType: _selectedHazardType,
                      onHazardTypeSelected: (hazardType) {
                        setState(() {
                          _selectedHazardType = hazardType;
                        });
                        _updateFormProgress();
                      },
                    ),

                    SizedBox(height: 4.h),

                    // Severity Selection
                    SeveritySelectorWidget(
                      selectedSeverity: _selectedSeverity,
                      onSeveritySelected: (severity) {
                        setState(() {
                          _selectedSeverity = severity;
                        });
                        _updateFormProgress();
                      },
                    ),

                    SizedBox(height: 4.h),

                    // Description Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Describe what you observed in detail',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                        SizedBox(height: 2.h),

                        // Voice Input Widget
                        VoiceInputWidget(
                          textController: _descriptionController,
                          onVoiceInputComplete: _updateFormProgress,
                        ),

                        SizedBox(height: 2.h),

                        // Text Input Field
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText:
                                'Describe the hazard conditions, location details, and any immediate dangers...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: EdgeInsets.all(4.w),
                          ),
                          onChanged: (_) => _updateFormProgress(),
                        ),
                      ],
                    ),

                    SizedBox(height: 4.h),

                    // Media Upload
                    MediaUploadWidget(
                      selectedMedia: _selectedMedia,
                      onMediaChanged: (media) {
                        setState(() {
                          _selectedMedia = media;
                        });
                        _updateFormProgress();
                      },
                    ),

                    SizedBox(height: 4.h),

                    // Location Selection
                    LocationSelectorWidget(
                      selectedLocation: _selectedLocation,
                      onLocationSelected: (location) {
                        setState(() {
                          _selectedLocation = location;
                        });
                        _updateFormProgress();
                      },
                    ),

                    SizedBox(height: 4.h),

                    // Additional Details
                    _buildAdditionalDetails(),

                    SizedBox(height: 8.h), // Extra space for submit button
                  ],
                ),
              ),
            ),

            // Submit Button
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.shadowColor,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isSubmitting || !_isFormValid() ? null : _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                      padding: EdgeInsets.symmetric(vertical: 2.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 5.w,
                                height: 5.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Submitting Report...',
                                style: AppTheme.lightTheme.textTheme.labelLarge
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Submit Hazard Report',
                            style: AppTheme.lightTheme.textTheme.labelLarge
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Details',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Optional information to help with assessment',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 2.h),

        // Affected Area
        TextFormField(
          controller: _affectedAreaController,
          decoration: InputDecoration(
            labelText: 'Estimated Affected Area',
            hintText: 'e.g., 500 meters of coastline',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'straighten',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Witness Count
        TextFormField(
          controller: _witnessCountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Number of Witnesses',
            hintText: 'How many people observed this?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'people',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Emergency Services Contacted
        CheckboxListTile(
          value: _emergencyServicesContacted,
          onChanged: (value) {
            setState(() {
              _emergencyServicesContacted = value ?? false;
            });
            HapticFeedback.lightImpact();
          },
          title: Text(
            'Emergency services have been contacted',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          subtitle: Text(
            'Check if you have already notified local authorities',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
