import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VoiceInputWidget extends StatefulWidget {
  final TextEditingController textController;
  final VoidCallback? onVoiceInputComplete;

  const VoiceInputWidget({
    super.key,
    required this.textController,
    this.onVoiceInputComplete,
  });

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget>
    with TickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _recordingPath;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<bool> _requestMicrophonePermission() async {
    if (kIsWeb) return true;
    return (await Permission.microphone.request()).isGranted;
  }

  Future<void> _startRecording() async {
    if (!await _requestMicrophonePermission()) {
      _showPermissionDialog();
      return;
    }

    try {
      if (await _audioRecorder.hasPermission()) {
        String path;

        if (kIsWeb) {
          path = 'recording.wav';
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.wav),
            path: path,
          );
        } else {
          final dir = await getTemporaryDirectory();
          path =
              '${dir.path}/voice_input_${DateTime.now().millisecondsSinceEpoch}.m4a';
          await _audioRecorder.start(
            const RecordConfig(),
            path: path,
          );
        }

        setState(() {
          _isRecording = true;
          _recordingPath = path;
        });

        _pulseController.repeat(reverse: true);
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      debugPrint('Recording start error: $e');
      _showErrorSnackBar('Failed to start recording');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      _pulseController.stop();
      _pulseController.reset();

      if (path != null) {
        // Simulate voice-to-text processing
        await _processVoiceInput(path);
      }

      setState(() {
        _isProcessing = false;
      });

      HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Recording stop error: $e');
      setState(() {
        _isRecording = false;
        _isProcessing = false;
      });
      _showErrorSnackBar('Failed to stop recording');
    }
  }

  Future<void> _processVoiceInput(String audioPath) async {
    // Simulate processing delay
    await Future.delayed(Duration(seconds: 2));

    // Mock voice-to-text result
    final mockTranscriptions = [
      'I observed high waves approximately 3 meters tall near the shoreline.',
      'There are dangerous storm surge conditions with strong currents.',
      'Tsunami warning signs visible with water receding rapidly.',
      'Large waves breaking over the seawall causing flooding.',
      'Storm surge flooding the coastal road and nearby buildings.',
    ];

    final randomTranscription = mockTranscriptions[
        DateTime.now().millisecond % mockTranscriptions.length];

    // Add transcribed text to the existing text
    final currentText = widget.textController.text;
    final newText = currentText.isEmpty
        ? randomTranscription
        : '$currentText $randomTranscription';

    widget.textController.text = newText;
    widget.onVoiceInputComplete?.call();
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Microphone Permission Required',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        content: Text(
          'Please grant microphone permission to use voice input for hazard descriptions.',
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
              openAppSettings();
            },
            child: Text('Settings'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _isRecording
            ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
            : AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isRecording
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.dividerColor,
          width: _isRecording ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isProcessing
              ? null
              : (_isRecording ? _stopRecording : _startRecording),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isRecording ? _pulseAnimation.value : 1.0,
                      child: Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: _getButtonColor(),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: _isProcessing
                              ? SizedBox(
                                  width: 6.w,
                                  height: 6.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : CustomIconWidget(
                                  iconName: _isRecording ? 'stop' : 'mic',
                                  color: Colors.white,
                                  size: 6.w,
                                ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusText(),
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _isRecording
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        _getDescriptionText(),
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isRecording) ...[
                  SizedBox(width: 2.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 2.w,
                          height: 2.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'REC',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getButtonColor() {
    if (_isProcessing) return AppTheme.lightTheme.colorScheme.primary;
    if (_isRecording) return AppTheme.lightTheme.colorScheme.error;
    return AppTheme.lightTheme.colorScheme.primary;
  }

  String _getStatusText() {
    if (_isProcessing) return 'Processing...';
    if (_isRecording) return 'Recording...';
    return 'Voice Input';
  }

  String _getDescriptionText() {
    if (_isProcessing) return 'Converting speech to text';
    if (_isRecording) return 'Tap to stop recording';
    return 'Tap to start voice description';
  }
}
