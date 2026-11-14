import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/admin_auth_cubit.dart';
import '../../bloc/auth/admin_auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  // Cleared default credentials as requested
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _obscurePassword = true;
  String? _tempToken;
  String _maskedPhone = '+91 76749 52516';

  // Resend OTP Countdown Timer
  Timer? _resendTimer;
  int _resendCountdown = 30;
  bool _canResend = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _resendCountdown = 30;
      _canResend = false;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 1) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
        setState(() {
          _resendCountdown = 0;
          _canResend = true;
        });
      }
    });
  }

  void _onLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      _showSnackbar('Please enter your administrative email', isError: true);
      return;
    }
    if (password.isEmpty) {
      _showSnackbar('Please enter your password', isError: true);
      return;
    }

    context.read<AdminAuthCubit>().login(email: email, password: password);
  }

  void _onVerifyOtp() {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length < 4) {
      _showSnackbar('Please enter the 6-digit verification code', isError: true);
      return;
    }
    if (_tempToken == null || _tempToken!.isEmpty) {
      _showSnackbar('Session expired. Please enter credentials again.', isError: true);
      setState(() => _tempToken = null);
      return;
    }

    context.read<AdminAuthCubit>().verifyOtp(tempToken: _tempToken!, otp: otp);
  }

  Future<void> _onResendOtp() async {
    if (!_canResend || _tempToken == null) return;
    _startResendTimer();
    final success = await context.read<AdminAuthCubit>().resendOtp(tempToken: _tempToken!);
    if (mounted) {
      _showSnackbar(
        success
            ? 'Verification code resent to $_maskedPhone'
            : 'Failed to resend code. Please try again.',
        isError: !success,
      );
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark slate canvas
      body: BlocConsumer<AdminAuthCubit, AdminAuthState>(
        listener: (context, state) {
          if (state is AdminAuthAuthenticated) {
            context.go('/dashboard');
          } else if (state is AdminAuthOtpRequired) {
            setState(() {
              _tempToken = state.tempToken;
              _maskedPhone = state.maskedPhone.isNotEmpty ? state.maskedPhone : '+91 76749 52516';
              _otpController.clear();
            });
            _startResendTimer();
            _showSnackbar(state.message);
          } else if (state is AdminAuthError) {
            _showSnackbar(state.message, isError: true);
          }
        },
        builder: (context, state) {
          final isLoading = state is AdminAuthLoading;
          final isOtpStep = _tempToken != null && _tempToken!.isNotEmpty;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                constraints: const BoxConstraints(maxWidth: 460),
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B), // Slate 800
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF334155), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 36,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: isOtpStep ? _buildOtpStep(isLoading) : _buildCredentialsStep(isLoading),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP 1: CREDENTIALS ENTRY (Email & Password)
  // -------------------------------------------------------------
  Widget _buildCredentialsStep(bool isLoading) {
    return Column(
      key: const ValueKey('credentials_step'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Brand Logo
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/app_logo.png',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.shield_rounded, color: AppColors.primary, size: 44),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Brand Badge
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.security, color: Color(0xFF0F172A), size: 22),
                const SizedBox(width: 8),
                Text(
                  'SharingWala',
                  style: AppTextStyles.h2.copyWith(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),

        Text(
          'Admin Control Center',
          style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 22),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Enter administrative credentials to proceed',
          style: AppTextStyles.subtitle.copyWith(color: AppColors.textLightMuted, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),

        // Email Field
        Text(
          'Administrative Email',
          style: AppTextStyles.caption.copyWith(color: Colors.white70, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Enter your admin email',
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
            fillColor: const Color(0xFF0F172A),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            prefixIcon: const Icon(Icons.email_outlined, color: Colors.white54, size: 20),
          ),
          onSubmitted: (_) => _onLogin(),
        ),
        const SizedBox(height: 18),

        // Password Field
        Text(
          'Password',
          style: AppTextStyles.caption.copyWith(color: Colors.white70, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Enter your password',
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
            fillColor: const Color(0xFF0F172A),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white54,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          onSubmitted: (_) => _onLogin(),
        ),
        const SizedBox(height: 28),

        // Sign In Action Button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textDark,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          onPressed: isLoading ? null : _onLogin,
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.textDark),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue with 2FA',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0F172A), size: 18),
                  ],
                ),
        ),

        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield_outlined, color: Colors.white38, size: 14),
            const SizedBox(width: 6),
            Text(
              'Authorized personnel only. Protected by 2FA OTP.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 2: 2FA OTP VERIFICATION (+91 76749 52516)
  // -------------------------------------------------------------
  Widget _buildOtpStep(bool isLoading) {
    return Column(
      key: const ValueKey('otp_step'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Security Icon
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.25),
                  AppColors.primary.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
            ),
            child: const Icon(Icons.phonelink_lock_rounded, color: AppColors.primary, size: 36),
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Two-Factor Authentication',
          style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 20),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTextStyles.subtitle.copyWith(
              color: AppColors.textLightMuted,
              fontSize: 13,
              height: 1.4,
            ),
            children: [
              const TextSpan(text: 'We have sent a 6-digit verification code to\n'),
              TextSpan(
                text: _maskedPhone,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),

        // OTP Code Field
        Text(
          'Enter 6-Digit Verification Code',
          style: AppTextStyles.caption.copyWith(color: Colors.white70, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _otpController,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            letterSpacing: 10,
            fontWeight: FontWeight.w900,
          ),
          decoration: InputDecoration(
            hintText: 'â€¢ â€¢ â€¢ â€¢ â€¢ â€¢',
            hintStyle: const TextStyle(
              color: Colors.white24,
              fontSize: 22,
              letterSpacing: 8,
            ),
            fillColor: const Color(0xFF0F172A),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onSubmitted: (_) => _onVerifyOtp(),
        ),
        const SizedBox(height: 24),

        // Verify Button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textDark,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          onPressed: isLoading ? null : _onVerifyOtp,
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.textDark),
                )
              : Text(
                  'Verify & Access Dashboard',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
        ),
        const SizedBox(height: 16),

        // Resend OTP / Timer Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_canResend) ...[
              const Icon(Icons.timer_outlined, color: Colors.white54, size: 15),
              const SizedBox(width: 6),
              Text(
                'Resend code in ${_resendCountdown}s',
                style: const TextStyle(color: Colors.white54, fontSize: 12.5),
              ),
            ] else ...[
              TextButton.icon(
                onPressed: _onResendOtp,
                icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.primary),
                label: const Text(
                  'Resend Code',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 8),
        // Back to Credentials Button
        TextButton(
          onPressed: () {
            _resendTimer?.cancel();
            setState(() {
              _tempToken = null;
              _otpController.clear();
            });
            context.read<AdminAuthCubit>().cancelOtp();
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back_rounded, size: 15, color: Colors.white60),
              SizedBox(width: 6),
              Text(
                'Back to Login',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
