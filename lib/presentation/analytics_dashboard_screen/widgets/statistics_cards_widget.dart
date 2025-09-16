import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StatisticsCardsWidget extends StatefulWidget {
  final String selectedRange;

  const StatisticsCardsWidget({
    super.key,
    required this.selectedRange,
  });

  @override
  State<StatisticsCardsWidget> createState() => _StatisticsCardsWidgetState();
}

class _StatisticsCardsWidgetState extends State<StatisticsCardsWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  final List<Map<String, dynamic>> statisticsData = [
    {
      'title': 'Total Reports',
      'value': 2847,
      'icon': 'report',
      'color': Color(0xFF1565C0),
      'change': '+12.5%',
      'isPositive': true,
    },
    {
      'title': 'Avg Response Time',
      'value': 24,
      'unit': 'min',
      'icon': 'schedule',
      'color': Color(0xFF388E3C),
      'change': '-8.2%',
      'isPositive': true,
    },
    {
      'title': 'Verification Accuracy',
      'value': 94.2,
      'unit': '%',
      'icon': 'verified',
      'color': Color(0xFFF57C00),
      'change': '+2.1%',
      'isPositive': true,
    },
    {
      'title': 'Active Hotspots',
      'value': 18,
      'icon': 'location_on',
      'color': Color(0xFFD32F2F),
      'change': '+3',
      'isPositive': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      statisticsData.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 1500 + (index * 200)),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
      );
    }).toList();

    _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
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
            'Key Metrics',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 1.4,
            ),
            itemCount: statisticsData.length,
            itemBuilder: (context, index) {
              final stat = statisticsData[index];
              return AnimatedBuilder(
                animation: _animations[index],
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animations[index].value,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.lightTheme.shadowColor
                                .withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: stat['color'].withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: CustomIconWidget(
                                  iconName: stat['icon'],
                                  color: stat['color'],
                                  size: 20,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: stat['isPositive']
                                      ? AppTheme.successColor
                                          .withValues(alpha: 0.1)
                                      : AppTheme.warningColor
                                          .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  stat['change'],
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: stat['isPositive']
                                        ? AppTheme.successColor
                                        : AppTheme.warningColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  stat['title'],
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 0.5.h),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: AnimatedBuilder(
                                        animation: _animations[index],
                                        builder: (context, child) {
                                          final animatedValue = (stat['value'] *
                                              _animations[index].value);
                                          return Text(
                                            stat['unit'] != null
                                                ? '${animatedValue.toStringAsFixed(1)}${stat['unit']}'
                                                : animatedValue
                                                    .toInt()
                                                    .toString(),
                                            style: AppTheme.lightTheme.textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: stat['color'],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
