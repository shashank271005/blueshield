import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MediaUploadWidget extends StatefulWidget {
  final List<XFile> selectedMedia;
  final ValueChanged<List<XFile>> onMediaChanged;

  const MediaUploadWidget({
    super.key,
    required this.selectedMedia,
    required this.onMediaChanged,
  });

  @override
  State<MediaUploadWidget> createState() => _MediaUploadWidgetState();
}

class _MediaUploadWidgetState extends State<MediaUploadWidget> {
  final ImagePicker _picker = ImagePicker();
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _showCamera = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        final camera = kIsWeb
            ? _cameras.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.front,
                orElse: () => _cameras.first)
            : _cameras.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.back,
                orElse: () => _cameras.first);

        _cameraController = CameraController(
            camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);

        await _cameraController!.initialize();
        await _applySettings();

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (e) {
      debugPrint('Focus mode error: $e');
    }

    if (!kIsWeb) {
      try {
        await _cameraController!.setFlashMode(FlashMode.auto);
      } catch (e) {
        debugPrint('Flash mode error: $e');
      }
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    try {
      final XFile photo = await _cameraController!.takePicture();
      final updatedMedia = List<XFile>.from(widget.selectedMedia)..add(photo);
      widget.onMediaChanged(updatedMedia);

      setState(() {
        _showCamera = false;
      });

      HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Photo capture error: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        final updatedMedia = List<XFile>.from(widget.selectedMedia)
          ..addAll(images);
        widget.onMediaChanged(updatedMedia);
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      debugPrint('Gallery picker error: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        final updatedMedia = List<XFile>.from(widget.selectedMedia)..add(video);
        widget.onMediaChanged(updatedMedia);
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      debugPrint('Video picker error: $e');
    }
  }

  void _removeMedia(int index) {
    final updatedMedia = List<XFile>.from(widget.selectedMedia)
      ..removeAt(index);
    widget.onMediaChanged(updatedMedia);
    HapticFeedback.lightImpact();
  }

  void _toggleCamera() async {
    if (!_isCameraInitialized) {
      await _initializeCamera();
    }

    if (await _requestCameraPermission()) {
      setState(() {
        _showCamera = !_showCamera;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Media Upload',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Add photos or videos to support your report',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 2.h),
        if (_showCamera && _isCameraInitialized) _buildCameraPreview(),
        if (!_showCamera) _buildMediaOptions(),
        if (widget.selectedMedia.isNotEmpty) ...[
          SizedBox(height: 2.h),
          _buildMediaPreview(),
        ],
      ],
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      height: 40.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.lightTheme.colorScheme.surface,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (_cameraController != null &&
                _cameraController!.value.isInitialized)
              CameraPreview(_cameraController!)
            else
              Center(
                child: CircularProgressIndicator(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            Positioned(
              bottom: 4.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCameraButton(
                    icon: 'close',
                    onTap: () => setState(() => _showCamera = false),
                  ),
                  _buildCameraButton(
                    icon: 'camera_alt',
                    onTap: _capturePhoto,
                    isPrimary: true,
                  ),
                  _buildCameraButton(
                    icon: 'flip_camera_ios',
                    onTap: _switchCamera,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraButton({
    required String icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 14.w,
        height: 14.w,
        decoration: BoxDecoration(
          color: isPrimary
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.shadowColor,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            color: isPrimary
                ? AppTheme.lightTheme.colorScheme.onPrimary
                : AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
      ),
    );
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    final currentCamera = _cameraController!.description;
    final newCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection != currentCamera.lensDirection,
      orElse: () => _cameras.first,
    );

    await _cameraController!.dispose();
    _cameraController = CameraController(
      newCamera,
      kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
    );

    await _cameraController!.initialize();
    await _applySettings();

    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildMediaOptions() {
    return Row(
      children: [
        Expanded(
          child: _buildOptionButton(
            icon: 'camera_alt',
            label: 'Camera',
            onTap: _toggleCamera,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildOptionButton(
            icon: 'photo_library',
            label: 'Gallery',
            onTap: _pickFromGallery,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildOptionButton(
            icon: 'videocam',
            label: 'Video',
            onTap: _pickVideo,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 2.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            border: Border.all(
              color: AppTheme.lightTheme.dividerColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              CustomIconWidget(
                iconName: icon,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 8.w,
              ),
              SizedBox(height: 1.h),
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Media (${widget.selectedMedia.length})',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        SizedBox(
          height: 20.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.selectedMedia.length,
            itemBuilder: (context, index) {
              final media = widget.selectedMedia[index];
              return Container(
                margin: EdgeInsets.only(right: 2.w),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 30.w,
                        height: 20.h,
                        color: AppTheme.lightTheme.colorScheme.surface,
                        child: kIsWeb
                            ? FutureBuilder<Uint8List>(
                                future: media.readAsBytes(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                    );
                                  }
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                    ),
                                  );
                                },
                              )
                            : Image.file(
                                File(media.path),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Positioned(
                      top: 1.h,
                      right: 1.w,
                      child: GestureDetector(
                        onTap: () => _removeMedia(index),
                        child: Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'close',
                              color: AppTheme.lightTheme.colorScheme.onError,
                              size: 4.w,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
