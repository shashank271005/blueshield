import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SentimentGaugeWidget extends StatefulWidget {
  final String selectedRange;

  const SentimentGaugeWidget({
    super.key,
    required this.selectedRange,
  });

  @override
  State<SentimentGaugeWidget> createState() => _SentimentGaugeWidgetState();
}

class _SentimentGaugeWidgetState extends State<SentimentGaugeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  double sentimentValue = 72.5;
  String sentimentLevel = 'Moderate';
  Color sentimentColor = Color(0xFFF57C00);

  final Map<String, dynamic> sentimentData = {
    'positive': 45.2,
    'neutral': 32.8,
    'negative': 22.0,
    'overall': 72.5,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: sentimentValue).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
    _updateSentimentLevel();
  }

  void _updateSentimentLevel() {
    if (sentimentValue >= 80) {
      sentimentLevel = 'High Concern';
      sentimentColor = AppTheme.lightTheme.colorScheme.error;
    } else if (sentimentValue >= 50) {
      sentimentLevel = 'Moderate';
      sentimentColor = AppTheme.warningColor;
    } else {
      sentimentLevel = 'Low Concern';
      sentimentColor = AppTheme.successColor;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Public Sentiment Analysis',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 25.h,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return SfRadialGauge(
                        axes: <RadialAxis>[
                          RadialAxis(
                            minimum: 0,
                            maximum: 100,
                            showLabels: false,
                            showTicks: false,
                            axisLineStyle: const AxisLineStyle(
                              thickness: 0.2,
                              cornerStyle: CornerStyle.bothCurve,
                              color: Color.fromARGB(30, 0, 169, 181),
                              thicknessUnit: GaugeSizeUnit.factor,
                            ),
                            pointers: <GaugePointer>[
                              RangePointer(
                                value: _animation.value,
                                cornerStyle: CornerStyle.bothCurve,
                                width: 0.2,
                                sizeUnit: GaugeSizeUnit.factor,
                                gradient: SweepGradient(
                                  colors: <Color>[
                                    AppTheme.successColor,
                                    AppTheme.warningColor,
                                    AppTheme.lightTheme.colorScheme.error,
                                  ],
                                  stops: const <double>[0.0, 0.5, 1.0],
                                ),
                              ),
                              NeedlePointer(
                                value: _animation.value,
                                needleStartWidth: 1,
                                needleEndWidth: 3,
                                needleColor: sentimentColor,
                                knobStyle: KnobStyle(
                                  knobRadius: 0.08,
                                  sizeUnit: GaugeSizeUnit.factor,
                                  color: sentimentColor,
                                ),
                              ),
                            ],
                            annotations: <GaugeAnnotation>[
                              GaugeAnnotation(
                                widget: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${_animation.value.toStringAsFixed(1)}%',
                                      style: AppTheme
                                          .lightTheme.textTheme.headlineMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: sentimentColor,
                                      ),
                                    ),
                                    Text(
                                      sentimentLevel,
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSurface
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                                angle: 90,
                                positionFactor: 0.5,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSentimentIndicator(
                      'Positive',
                      sentimentData['positive'],
                      AppTheme.successColor,
                    ),
                    _buildSentimentIndicator(
                      'Neutral',
                      sentimentData['neutral'],
                      AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                    _buildSentimentIndicator(
                      'Negative',
                      sentimentData['negative'],
                      AppTheme.lightTheme.colorScheme.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentIndicator(String label, double value, Color color) {
    return Column(
      children: [
        Container(
          width: 4.w,
          height: 4.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.7),
          ),
        ),
        Text(
          '${value.toStringAsFixed(1)}%',
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
