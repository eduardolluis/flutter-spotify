import 'dart:async';

import 'package:melodix/core/utils.dart';
import 'package:melodix/features/auth/view/theme/auth_palette.dart';
import 'package:melodix/features/auth/view/widgets/auth_brand_mark.dart';
import 'package:melodix/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:melodix/features/auth/view/widgets/auth_text_field.dart';
import 'package:melodix/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:melodix/features/home/view/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_fonts/google_fonts.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  final String email;

  const VerifyEmailPage({super.key, required this.email});

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  final _codeController = TextEditingController();
  bool _isSubmitting = false;
  bool _isResending = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _codeController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 30);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _resendCooldown--);
      if (_resendCooldown <= 0) timer.cancel();
    });
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.length != 6 || _isSubmitting) {
      if (code.length != 6) showSnackBar(context, 'Enter the 6-digit code');
      return;
    }

    setState(() => _isSubmitting = true);
    final res = await ref.read(authViewModelProvider.notifier).verifyEmail(code: code);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (res) {
      case Left(value: final failure):
        showSnackBar(context, failure.message);
      case Right():
        showSnackBar(context, 'Email verified — welcome to Melodix!');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (_) => false,
        );
    }
  }

  Future<void> _resend() async {
    if (_isResending || _resendCooldown > 0) return;
    setState(() => _isResending = true);

    final res = await ref.read(authViewModelProvider.notifier).sendVerificationCode();
    if (!mounted) return;
    setState(() => _isResending = false);

    switch (res) {
      case Left(value: final failure):
        showSnackBar(context, failure.message);
      case Right():
        showSnackBar(context, 'Code resent — check your email');
        _startCooldown();
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AuthBrandMark(),
                  const SizedBox(height: 48),

                  Text(
                    'Verify your email',
                    style: GoogleFonts.fraunces(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      height: 1.05,
                      color: AuthPalette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'SENT TO ${widget.email.toUpperCase()}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      letterSpacing: 1.2,
                      color: AuthPalette.textMuted,
                    ),
                  ),
                  const SizedBox(height: 40),

                  AuthTextField(
                    label: '6-digit code',
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 36),

                  AuthGradientButton(
                    label: _isSubmitting ? 'Verifying...' : 'Verify',
                    onTap: _isSubmitting ? () {} : _verify,
                  ),
                  const SizedBox(height: 28),

                  Center(
                    child: GestureDetector(
                      onTap: _resend,
                      child: Text(
                        _resendCooldown > 0
                            ? 'Resend code (${_resendCooldown}s)'
                            : _isResending
                            ? 'Sending...'
                            : "Didn't get it? Resend code",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: _resendCooldown > 0 ? AuthPalette.textMuted : AuthPalette.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                          (_) => false,
                        );
                      },
                      child: Text(
                        "I'll do this later",
                        style: GoogleFonts.inter(fontSize: 13, color: AuthPalette.textMuted),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

