import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../../core/app_export.dart';

class ExportOptionsWidget extends StatefulWidget {
  final String selectedRange;

  const ExportOptionsWidget({
    super.key,
    required this.selectedRange,
  });

  @override
  State<ExportOptionsWidget> createState() => _ExportOptionsWidgetState();
}

class _ExportOptionsWidgetState extends State<ExportOptionsWidget> {
  bool _isExporting = false;

  final List<Map<String, dynamic>> exportOptions = [
    {
      'title': 'Export as CSV',
      'subtitle': 'Spreadsheet format for data analysis',
      'icon': 'table_chart',
      'format': 'csv',
      'color': Color(0xFF388E3C),
    },
    {
      'title': 'Export as PDF',
      'subtitle': 'Formatted report with charts',
      'icon': 'picture_as_pdf',
      'format': 'pdf',
      'color': Color(0xFFD32F2F),
    },
    {
      'title': 'Export Raw Data',
      'subtitle': 'JSON format for developers',
      'icon': 'code',
      'format': 'json',
      'color': Color(0xFF1565C0),
    },
  ];

  Future<void> _exportData(String format) async {
    setState(() {
      _isExporting = true;
    });

    try {
      String content;
      String filename;

      switch (format) {
        case 'csv':
          content = _generateCSVContent();
          filename = 'analytics_report_${widget.selectedRange}.csv';
          break;
        case 'pdf':
          content = _generatePDFContent();
          filename = 'analytics_report_${widget.selectedRange}.pdf';
          break;
        case 'json':
          content = _generateJSONContent();
          filename = 'analytics_data_${widget.selectedRange}.json';
          break;
        default:
          content = _generateCSVContent();
          filename = 'analytics_report_${widget.selectedRange}.csv';
      }

      await _downloadFile(content, filename);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export completed successfully'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed. Please try again.'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _downloadFile(String content, String filename) async {
    if (kIsWeb) {
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);
    }
  }

  String _generateCSVContent() {
    final buffer = StringBuffer();
    buffer.writeln('Date,Report Type,Count,Verification Rate,Response Time');
    buffer.writeln('2025-09-09,Tsunami,45,94.2,24');
    buffer.writeln('2025-09-10,Storm Surge,52,89.5,18');
    buffer.writeln('2025-09-11,High Waves,38,96.1,22');
    buffer.writeln('2025-09-12,Tsunami,67,91.8,26');
    buffer.writeln('2025-09-13,Storm Surge,73,93.4,20');
    buffer.writeln('2025-09-14,High Waves,58,88.7,28');
    buffer.writeln('2025-09-15,Tsunami,82,95.2,19');
    return buffer.toString();
  }

  String _generatePDFContent() {
    return '''
OCEAN HAZARD ANALYTICS REPORT
Generated: ${DateTime.now().toString()}
Date Range: ${widget.selectedRange}

SUMMARY STATISTICS:
- Total Reports: 2,847
- Average Response Time: 24 minutes
- Verification Accuracy: 94.2%
- Active Hotspots: 18

TREND ANALYSIS:
Report frequency has increased by 12.5% compared to previous period.
Verification rates remain consistently high at 94.2%.
Response times have improved by 8.2% on average.

GEOGRAPHIC HOTSPOTS:
1. Miami Beach - 58 reports (90% intensity)
2. New York Harbor - 45 reports (80% intensity)
3. San Francisco Bay - 38 reports (70% intensity)
4. Los Angeles Coast - 32 reports (60% intensity)
5. Seattle Waterfront - 24 reports (50% intensity)

SENTIMENT ANALYSIS:
Overall public concern level: 72.5% (Moderate)
- Positive sentiment: 45.2%
- Neutral sentiment: 32.8%
- Negative sentiment: 22.0%

TOP TRENDING KEYWORDS:
1. tsunami (245 mentions)
2. waves (189 mentions)
3. storm (156 mentions)
4. flooding (134 mentions)
5. warning (123 mentions)
    ''';
  }

  String _generateJSONContent() {
    final data = {
      'report_metadata': {
        'generated_at': DateTime.now().toIso8601String(),
        'date_range': widget.selectedRange,
        'version': '1.0',
      },
      'statistics': {
        'total_reports': 2847,
        'average_response_time_minutes': 24,
        'verification_accuracy_percent': 94.2,
        'active_hotspots': 18,
      },
      'trends': {
        'report_frequency': [
          {'date': '2025-09-09', 'count': 45},
          {'date': '2025-09-10', 'count': 52},
          {'date': '2025-09-11', 'count': 38},
          {'date': '2025-09-12', 'count': 67},
          {'date': '2025-09-13', 'count': 73},
          {'date': '2025-09-14', 'count': 58},
          {'date': '2025-09-15', 'count': 82},
        ],
        'verification_rates': [85, 78, 92, 88, 95, 82, 90],
      },
      'hotspots': [
        {'name': 'Miami Beach', 'reports': 58, 'intensity': 0.9},
        {'name': 'New York Harbor', 'reports': 45, 'intensity': 0.8},
        {'name': 'San Francisco Bay', 'reports': 38, 'intensity': 0.7},
        {'name': 'Los Angeles Coast', 'reports': 32, 'intensity': 0.6},
        {'name': 'Seattle Waterfront', 'reports': 24, 'intensity': 0.5},
      ],
      'sentiment': {
        'overall_score': 72.5,
        'positive_percent': 45.2,
        'neutral_percent': 32.8,
        'negative_percent': 22.0,
      },
      'keywords': [
        {'word': 'tsunami', 'frequency': 245},
        {'word': 'waves', 'frequency': 189},
        {'word': 'storm', 'frequency': 156},
        {'word': 'flooding', 'frequency': 134},
        {'word': 'warning', 'frequency': 123},
      ],
    };
    return jsonEncode(data);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export Data',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exportOptions.length,
            itemBuilder: (context, index) {
              final option = exportOptions[index];
              return Container(
                margin: EdgeInsets.only(bottom: 2.h),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isExporting
                        ? null
                        : () => _exportData(option['format']),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.lightTheme.shadowColor
                                .withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: option['color'].withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CustomIconWidget(
                              iconName: option['icon'],
                              color: option['color'],
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option['title'],
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  option['subtitle'],
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isExporting)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  option['color'],
                                ),
                              ),
                            )
                          else
                            CustomIconWidget(
                              iconName: 'download',
                              color: option['color'],
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
