import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  PasswordStrength _getPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.none;

    int score = 0;

    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Character variety checks
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strength = _getPasswordStrength(password);

    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: strength.index >= 1
                              ? strength.color
                              : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(2),
                            bottomLeft: Radius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 1.w),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: strength.index >= 2
                              ? strength.color
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(width: 1.w),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: strength.index >= 3
                              ? strength.color
                              : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(2),
                            bottomRight: Radius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              strength.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: strength.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (strength != PasswordStrength.strong) ...[
          SizedBox(height: 1.h),
          Text(
            _getPasswordRequirements(password),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 10.sp,
            ),
          ),
        ],
      ],
    );
  }

  String _getPasswordRequirements(String password) {
    List<String> missing = [];

    if (password.length < 8) missing.add('8+ characters');
    if (!password.contains(RegExp(r'[a-z]'))) missing.add('lowercase');
    if (!password.contains(RegExp(r'[A-Z]'))) missing.add('uppercase');
    if (!password.contains(RegExp(r'[0-9]'))) missing.add('number');
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')))
      missing.add('special character');

    if (missing.isEmpty) return 'Strong password!';

    return 'Add: ${missing.join(', ')}';
  }
}

enum PasswordStrength {
  none('', Colors.transparent),
  weak('Weak', Colors.red),
  medium('Medium', Colors.orange),
  strong('Strong', Colors.green);

  const PasswordStrength(this.label, this.color);
  final String label;
  final Color color;
}
