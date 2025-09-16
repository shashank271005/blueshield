import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/country_picker_field.dart';
import './widgets/location_permission_card.dart';
import './widgets/password_strength_indicator.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/role_selection_card.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Form state
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isTermsAccepted = false;
  bool _isPrivacyAccepted = false;
  bool _isLocationPermissionGranted = false;
  bool _isLoading = false;

  // Country picker state
  String _selectedCountryCode = '+1';
  String _selectedCountryFlag = '🇺🇸';

  // Role selection state
  String _selectedRole = 'Citizen';

  // Mock country data
  final List<Map<String, dynamic>> _countries = [
    {'code': '+1', 'flag': '🇺🇸', 'name': 'United States'},
    {'code': '+44', 'flag': '🇬🇧', 'name': 'United Kingdom'},
    {'code': '+91', 'flag': '🇮🇳', 'name': 'India'},
    {'code': '+86', 'flag': '🇨🇳', 'name': 'China'},
    {'code': '+81', 'flag': '🇯🇵', 'name': 'Japan'},
    {'code': '+49', 'flag': '🇩🇪', 'name': 'Germany'},
    {'code': '+33', 'flag': '🇫🇷', 'name': 'France'},
    {'code': '+39', 'flag': '🇮🇹', 'name': 'Italy'},
    {'code': '+34', 'flag': '🇪🇸', 'name': 'Spain'},
    {'code': '+61', 'flag': '🇦🇺', 'name': 'Australia'},
  ];

  // Role data
  final List<Map<String, dynamic>> _roles = [
    {
      'title': 'Citizen',
      'description': 'Report ocean hazards and receive alerts in your area',
      'icon': 'person',
    },
    {
      'title': 'Verifier',
      'description': 'Verify and validate citizen reports for accuracy',
      'icon': 'verified',
    },
    {
      'title': 'Official',
      'description': 'Manage emergency responses and coordinate actions',
      'icon': 'badge',
    },
    {
      'title': 'Analyst',
      'description': 'Analyze trends and generate insights from data',
      'icon': 'analytics',
    },
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _formKey.currentState?.validate() == true &&
        _isTermsAccepted &&
        _isPrivacyAccepted &&
        _passwordController.text == _confirmPasswordController.text &&
        _passwordController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator header
            const ProgressIndicatorWidget(
              currentStep: 1,
              totalSteps: 2,
            ),

            // Scrollable form content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),

                      // Header text
                      Text(
                        'Create Your Account',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Join the ocean safety community and help protect coastal areas',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      // Full Name field
                      _buildTextField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        prefixIcon: 'person',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Full name is required';
                          }
                          if (value.trim().length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 3.h),

                      // Email field
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'Enter your email address',
                        prefixIcon: 'email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 3.h),

                      // Phone number field with country picker
                      Text(
                        'Phone Number',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          CountryPickerField(
                            selectedCountryCode: _selectedCountryCode,
                            selectedCountryFlag: _selectedCountryFlag,
                            onTap: _showCountryPicker,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: _buildTextField(
                              controller: _phoneController,
                              hint: 'Phone number',
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Phone number is required';
                                }
                                if (value.trim().length < 10) {
                                  return 'Please enter a valid phone number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 3.h),

                      // Password field
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Create a strong password',
                        prefixIcon: 'lock',
                        obscureText: !_isPasswordVisible,
                        suffixIcon: IconButton(
                          icon: CustomIconWidget(
                            iconName: _isPasswordVisible
                                ? 'visibility_off'
                                : 'visibility',
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),

                      // Password strength indicator
                      PasswordStrengthIndicator(
                          password: _passwordController.text),

                      SizedBox(height: 3.h),

                      // Confirm Password field
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        hint: 'Re-enter your password',
                        prefixIcon: 'lock',
                        obscureText: !_isConfirmPasswordVisible,
                        suffixIcon: IconButton(
                          icon: CustomIconWidget(
                            iconName: _isConfirmPasswordVisible
                                ? 'visibility_off'
                                : 'visibility',
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),

                      SizedBox(height: 4.h),

                      // Role selection
                      Text(
                        'Select Your Role',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Choose the role that best describes your involvement with ocean safety',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      SizedBox(height: 2.h),

                      SizedBox(
                        height: 16.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _roles.length,
                          itemBuilder: (context, index) {
                            final role = _roles[index];
                            return RoleSelectionCard(
                              title: role['title'] as String,
                              description: role['description'] as String,
                              iconName: role['icon'] as String,
                              isSelected: _selectedRole == role['title'],
                              onTap: () {
                                setState(() {
                                  _selectedRole = role['title'] as String;
                                });
                                HapticFeedback.lightImpact();
                              },
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 4.h),

                      // Location permission card
                      LocationPermissionCard(
                        isPermissionGranted: _isLocationPermissionGranted,
                        onRequestPermission: _requestLocationPermission,
                      ),

                      SizedBox(height: 3.h),

                      // Terms and Privacy checkboxes
                      _buildCheckboxTile(
                        value: _isTermsAccepted,
                        onChanged: (value) {
                          setState(() {
                            _isTermsAccepted = value ?? false;
                          });
                        },
                        title: 'I agree to the Terms of Service',
                        onTitleTap: () {
                          // Show terms of service
                          _showTermsDialog();
                        },
                      ),

                      SizedBox(height: 1.h),

                      _buildCheckboxTile(
                        value: _isPrivacyAccepted,
                        onChanged: (value) {
                          setState(() {
                            _isPrivacyAccepted = value ?? false;
                          });
                        },
                        title: 'I agree to the Privacy Policy',
                        onTitleTap: () {
                          // Show privacy policy
                          _showPrivacyDialog();
                        },
                      ),

                      SizedBox(height: 4.h),

                      // Create Account button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isFormValid && !_isLoading
                              ? _handleRegistration
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFormValid
                                ? AppTheme.lightTheme.colorScheme.primary
                                : theme.colorScheme.outline
                                    .withValues(alpha: 0.3),
                            padding: EdgeInsets.symmetric(vertical: 3.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: _isFormValid ? 2 : 0,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Create Account',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // Login link
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login-screen');
                          },
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign In',
                                  style: TextStyle(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? label,
    required String hint,
    String? prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: prefixIcon,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  )
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 3.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxTile({
    required bool value,
    required void Function(bool?) onChanged,
    required String title,
    VoidCallback? onTitleTap,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.lightTheme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onTitleTap,
            child: Padding(
              padding: EdgeInsets.only(top: 2.5.w),
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: onTitleTap != null
                      ? AppTheme.lightTheme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  decoration:
                      onTitleTap != null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          height: 50.h,
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              Text(
                'Select Country',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: ListView.builder(
                  itemCount: _countries.length,
                  itemBuilder: (context, index) {
                    final country = _countries[index];
                    return ListTile(
                      leading: Text(
                        country['flag'] as String,
                        style: TextStyle(fontSize: 20.sp),
                      ),
                      title: Text(country['name'] as String),
                      trailing: Text(
                        country['code'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCountryCode = country['code'] as String;
                          _selectedCountryFlag = country['flag'] as String;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _requestLocationPermission() {
    // Simulate location permission request
    setState(() {
      _isLocationPermissionGranted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Location permission granted'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: SingleChildScrollView(
          child: Text(
            'By using BlueShield Ocean Hazard, you agree to:\n\n'
            '1. Provide accurate information when reporting hazards\n'
            '2. Use the app responsibly and not for malicious purposes\n'
            '3. Respect other users and maintain community standards\n'
            '4. Allow location access for hazard reporting features\n'
            '5. Understand that this app is for informational purposes\n\n'
            'For complete terms, visit our website.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Text(
            'BlueShield Ocean Hazard respects your privacy:\n\n'
            '• Location data is used only for hazard reporting\n'
            '• Personal information is encrypted and secure\n'
            '• We do not sell your data to third parties\n'
            '• You can delete your account and data anytime\n'
            '• Cookies are used to improve app experience\n\n'
            'For detailed privacy policy, visit our website.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegistration() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate registration API call
      await Future.delayed(const Duration(seconds: 2));

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Account created successfully! Please verify your email.'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate to home dashboard or OTP verification
        Navigator.pushNamed(context, '/home-dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
