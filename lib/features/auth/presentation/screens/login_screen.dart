import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gmmx_buttons.dart';
import '../../../../core/config.dart';
import '../../../../core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      _showFeedback('Please enter both identifier and password', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = ref.read(dioClientProvider);

      // Attempting Login
      // Note: baseUrl is 'http://10.0.2.2:8080'
      final response = await dio.post('/api/auth/login', data: {
        'identifier': identifier,
        'password': password,
      });

      if (response.statusCode == 200) {
        _showFeedback('Login Successful! Welcome back.', isError: false);
        // TODO: Navigate to dashboard after small delay
      }
    } on DioException catch (e) {
      String errorMessage = 'Something went wrong';

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        errorMessage =
            'Backend server is unreachable. Check if your DB/Core is running.';
      } else if (e.response?.statusCode == 401) {
        errorMessage = 'Invalid credentials. Please try again.';
      } else if (e.response?.statusCode == 500) {
        errorMessage = 'Server error. Database might not be connected.';
      } else if (e.response?.data != null &&
          e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }

      _showFeedback(errorMessage, isError: true);
    } catch (e) {
      _showFeedback('Unexpected error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showFeedback(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _launchRegisterUrl() async {
    final Uri url = Uri.parse('https://gmmx.app');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleLoading) return;

    setState(() => _isGoogleLoading = true);
    try {
      final serverClientId = AppConfig.googleServerClientId;
      final googleSignIn = GoogleSignIn(
        scopes: const ['email', 'openid', 'profile'],
        serverClientId: serverClientId.isNotEmpty ? serverClientId : null,
      );

      final account = await googleSignIn.signIn();
      if (account == null) {
        _showFeedback('Google sign-in was cancelled.', isError: false);
        return;
      }

      final authentication = await account.authentication;
      if (authentication.idToken == null &&
          authentication.accessToken == null) {
        _showFeedback(
          'Google sign-in did not return tokens. Check your client ID setup.',
          isError: true,
        );
        return;
      }

      _showFeedback(
        'Google account accepted. Connecting to backend...',
        isError: false,
      );

      final dio = ref.read(dioClientProvider);
      await dio.post(
        '/api/auth/google',
        data: {
          'tenantSlug': AppConfig.tenantSlug,
          'email': account.email,
          'displayName': account.displayName,
          'idToken': authentication.idToken,
          'accessToken': authentication.accessToken,
        },
      );

      _showFeedback(
        'Signed in with Google as ${account.email}.',
        isError: false,
      );

      if (mounted) {
        context.go('/dashboard');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        _showFeedback(
          'Backend server is unreachable. Check if your DB/Core is running.',
          isError: true,
        );
      } else if (e.response?.statusCode == 401) {
        _showFeedback('Invalid credentials. Please try again.', isError: true);
      } else if (e.response?.statusCode == 500) {
        _showFeedback('Server error. Database might not be connected.',
            isError: true);
      } else if (e.response?.statusCode == 404) {
        _showFeedback(
          'Google login endpoint is missing on the backend. Add /api/auth/google and verify it returns 200.',
          isError: true,
        );
      } else {
        _showFeedback('Google sign-in failed: ${e.message}', isError: true);
      }
    } catch (e) {
      final errorText = e.toString();
      if (errorText.contains('ApiException: 10')) {
        _showFeedback(
          'Google sign-in is not configured correctly for Android. Add SHA-1 and SHA-256 to the Android OAuth client, and make sure the app package name matches the Google Cloud configuration.',
          isError: true,
        );
      } else {
        _showFeedback('Google sign-in failed: $errorText', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textMain, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textMain,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your credentials to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 48),

              // Email or Mobile Field
              const Text(
                'Email or Mobile Number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _identifierController,
                decoration: InputDecoration(
                  hintText: 'e.g. hello@gmmx.app',
                  prefixIcon:
                      const Icon(Icons.person_outline_rounded, size: 22),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade100),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Password Field
              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 22),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade100),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              GmmxPrimaryButton(
                text: 'Sign In',
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Row(
                  children: [
                    Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "OR",
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(thickness: 1)),
                  ],
                ),
              ),

              GoogleSignInButton(
                onPressed: _handleGoogleSignIn,
              ),

              if (_isGoogleLoading) ...[
                const SizedBox(height: 12),
                const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              Center(
                child: TextButton(
                  onPressed: _launchRegisterUrl,
                  child: Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: const TextStyle(color: AppColors.textMuted),
                      children: [
                        TextSpan(
                          text: 'Sign up',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
