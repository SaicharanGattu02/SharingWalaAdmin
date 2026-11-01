import 'package:flutter/material.dart';
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
  final _emailController = TextEditingController(text: 'admin@share2go.com');
  final _passwordController = TextEditingController(text: 'Admin@123');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return;
    context.read<AdminAuthCubit>().login(email: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark modern background
      body: BlocConsumer<AdminAuthCubit, AdminAuthState>(
        listener: (context, state) {
          if (state is AdminAuthAuthenticated) {
            context.go('/dashboard');
          } else if (state is AdminAuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AdminAuthLoading;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 440),
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B), // Slate 800
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF334155)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
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
                          errorBuilder: (context, error, stackTrace) => const SizedBox(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Brand Badge
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
                            const Icon(Icons.security, color: Color(0xFF0F172A), size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'SharingWala',
                              style: AppTextStyles.h2.copyWith(
                                color: const Color(0xFF0F172A),
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Admin Control Center',
                      style: AppTextStyles.h2.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in with authorized administrative credentials',
                      style: AppTextStyles.subtitle.copyWith(color: AppColors.textLightMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Email Field
                    Text(
                      'Administrative Email',
                      style: AppTextStyles.caption.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'admin@share2go.com',
                        hintStyle: TextStyle(color: Colors.white38),
                        fillColor: Color(0xFF0F172A),
                        prefixIcon: Icon(Icons.email_outlined, color: Colors.white54),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    Text(
                      'Password',
                      style: AppTextStyles.caption.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: const TextStyle(color: Colors.white38),
                        fillColor: const Color(0xFF0F172A),
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white54,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Login Action Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textDark,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: isLoading ? null : _onLogin,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textDark),
                            )
                          : Text(
                              'Sign In to Dashboard',
                              style: AppTextStyles.button.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                    ),
                    const SizedBox(height: 20),

                    // Demo Helper Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Default: admin@share2go.com / Admin@123',
                              style: AppTextStyles.caption.copyWith(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

