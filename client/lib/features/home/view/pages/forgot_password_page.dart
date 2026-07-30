import 'package:melodix/core/utils.dart';
import 'package:melodix/features/auth/view/theme/auth_palette.dart';
import 'package:melodix/features/auth/view/widgets/auth_brand_mark.dart';
import 'package:melodix/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:melodix/features/auth/view/widgets/auth_text_field.dart';
import 'package:melodix/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:melodix/features/home/view/pages/reset_password_page.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    final email = _emailController.text.trim();
    setState(() => _isSubmitting = true);

    final res = await ref.read(authViewModelProvider.notifier).forgotPassword(email: email);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (res) {
      case Left(value: final failure):
        showSnackBar(context, failure.message);
      case Right():
        showSnackBar(context, 'Check your email for a reset code');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResetPasswordPage(email: email)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthPalette.ink,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AuthBrandMark(),
                    const SizedBox(height: 48),

                    Text(
                      'Reset password',
                      style: GoogleFonts.fraunces(
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        height: 1.05,
                        color: AuthPalette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "We'll email you a code to reset it",
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        letterSpacing: 1.0,
                        color: AuthPalette.textMuted,
                      ),
                    ),
                    const SizedBox(height: 40),

                    AuthTextField(
                      label: 'Email',
                      controller: _emailController,
                      isEmail: true,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 36),

                    AuthGradientButton(
                      label: _isSubmitting ? 'Sending...' : 'Send reset code',
                      onTap: _isSubmitting ? () {} : _sendCode,
                    ),
                    const SizedBox(height: 28),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Back to log in',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AuthPalette.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
