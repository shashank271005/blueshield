import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WordCloudWidget extends StatefulWidget {
  final String selectedRange;
  final Function(String) onWordTap;

  const WordCloudWidget({
    super.key,
    required this.selectedRange,
    required this.onWordTap,
  });

  @override
  State<WordCloudWidget> createState() => _WordCloudWidgetState();
}

class _WordCloudWidgetState extends State<WordCloudWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  String? selectedWord;

  final List<Map<String, dynamic>> wordData = [
    {'word': 'tsunami', 'frequency': 245, 'color': Color(0xFFD32F2F)},
    {'word': 'waves', 'frequency': 189, 'color': Color(0xFF1565C0)},
    {'word': 'storm', 'frequency': 156, 'color': Color(0xFFF57C00)},
    {'word': 'flooding', 'frequency': 134, 'color': Color(0xFF388E3C)},
    {'word': 'warning', 'frequency': 123, 'color': Color(0xFF7B1FA2)},
    {'word': 'evacuation', 'frequency': 98, 'color': Color(0xFF00ACC1)},
    {'word': 'emergency', 'frequency': 87, 'color': Color(0xFFE91E63)},
    {'word': 'coastal', 'frequency': 76, 'color': Color(0xFF795548)},
    {'word': 'surge', 'frequency': 65, 'color': Color(0xFF607D8B)},
    {'word': 'alert', 'frequency': 54, 'color': Color(0xFF9C27B0)},
    {'word': 'safety', 'frequency': 43, 'color': Color(0xFF4CAF50)},
    {'word': 'damage', 'frequency': 38, 'color': Color(0xFFFF5722)},
    {'word': 'rescue', 'frequency': 32, 'color': Color(0xFF2196F3)},
    {'word': 'shelter', 'frequency': 28, 'color': Color(0xFF8BC34A)},
    {'word': 'risk', 'frequency': 25, 'color': Color(0xFFFF9800)},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _getFontSize(int frequency) {
    final maxFreq = wordData.map((e) => e['frequency'] as int).reduce(math.max);
    final minFreq = wordData.map((e) => e['frequency'] as int).reduce(math.min);
    final normalizedFreq = (frequency - minFreq) / (maxFreq - minFreq);
    return 12 + (normalizedFreq * 8);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trending Keywords',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (selectedWord != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedWord = null;
                    });
                  },
                  child: Text(
                    'Clear Filter',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
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
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: wordData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final word = entry.value;
                    final isSelected = selectedWord == word['word'];
                    final animationDelay = index * 0.1;
                    final animation = Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          animationDelay.clamp(0.0, 1.0),
                          (animationDelay + 0.3).clamp(0.0, 1.0),
                          curve: Curves.easeOutBack,
                        ),
                      ),
                    );

                    return Transform.scale(
                      scale: animation.value,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedWord = isSelected ? null : word['word'];
                          });
                          widget.onWordTap(word['word']);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? word['color'].withValues(alpha: 0.2)
                                : word['color'].withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? word['color']
                                  : word['color'].withValues(alpha: 0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                word['word'],
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  fontSize: _getFontSize(word['frequency']).sp,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: word['color'],
                                ),
                              ),
                              SizedBox(width: 1.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 1.5.w,
                                  vertical: 0.2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: word['color'].withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  word['frequency'].toString(),
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: word['color'],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 8.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          if (selectedWord != null) ...[
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'filter_alt',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Filtering by: "$selectedWord"',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
