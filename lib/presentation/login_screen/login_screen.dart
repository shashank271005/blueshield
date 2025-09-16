import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/alternative_auth_widget.dart';
import './widgets/emergency_banner_widget.dart';
import './widgets/language_selector_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/wave_header_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  // Mock credentials for different roles
  final Map<String, Map<String, String>> _mockCredentials = {
    'Citizen': {'email': 'citizen@blueshield.com', 'password': 'citizen123'},
    'Verifier': {'email': 'verifier@blueshield.com', 'password': 'verifier123'},
    'Official': {'email': 'official@blueshield.com', 'password': 'official123'},
    'Analyst': {'email': 'analyst@blueshield.com', 'password': 'analyst123'},
    'Admin': {'email': 'admin@blueshield.com', 'password': 'admin123'},
  };

  Future<void> _handleLogin(String email, String password, String role) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Check credentials
    final roleCredentials = _mockCredentials[role];
    if (roleCredentials != null &&
        roleCredentials['email'] == email &&
        roleCredentials['password'] == password) {
      // Successful login
      HapticFeedback.heavyImpact();

      setState(() {
        _isLoading = false;
      });

      // Navigate to appropriate dashboard based on role
      String route = '/home-dashboard';
      switch (role) {
        case 'Analyst':
          route = '/analytics-dashboard-screen';
          break;
        case 'Official':
        case 'Verifier':
        case 'Admin':
          route = '/interactive-map-screen';
          break;
        default:
          route = '/home-dashboard';
      }

      Navigator.pushReplacementNamed(context, route);
    } else {
      // Failed login
      HapticFeedback.lightImpact();

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Invalid credentials for $role role. Please check your email and password.';
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Wave Header with Logo
                  const WaveHeaderWidget(),

                  // Emergency Banner
                  const EmergencyBannerWidget(),

                  // Login Form Container
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 6.w),
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Text
                        Text(
                          'Welcome Back',
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Sign in to continue ocean hazard monitoring',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                        SizedBox(height: 4.h),

                        // Login Form
                        LoginFormWidget(
                          onLogin: _handleLogin,
                          isLoading: _isLoading,
                        ),

                        SizedBox(height: 4.h),

                        // Alternative Authentication Options
                        AlternativeAuthWidget(
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Mock Credentials Info
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 6.w),
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.tertiary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.tertiary
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'info',
                              color: AppTheme.lightTheme.colorScheme.tertiary,
                              size: 5.w,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Demo Credentials',
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.lightTheme.colorScheme.tertiary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        ..._mockCredentials.entries.map((entry) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 1.h),
                            child: Text(
                              '${entry.key}: ${entry.value['email']} / ${entry.value['password']}',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                fontFamily: 'monospace',
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.8),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Language Selector
          const LanguageSelectorWidget(),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
