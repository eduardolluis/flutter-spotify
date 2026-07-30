import 'package:melodix/core/utils.dart';
import 'package:melodix/core/widgets/loader.dart';
import 'package:melodix/features/auth/view/theme/auth_palette.dart';
import 'package:melodix/features/auth/view/widgets/auth_brand_mark.dart';
import 'package:melodix/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:melodix/features/auth/view/widgets/auth_text_field.dart';
import 'package:melodix/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:melodix/features/home/view/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  final String email;

  const ResetPasswordPage({super.key, required this.email});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authViewModelProvider.select((val) => val.isLoading)) == true;

    ref.listen(authViewModelProvider, (_, next) {
      next.when(
        data: (data) {
          if (data != null) {
            showSnackBar(context, 'Password updated — welcome back!');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (_) => false,
            );
          }
        },
        error: (error, stackTrace) {
          showSnackBar(context, error.toString());
        },
        loading: () {},
      );
    });

    return Scaffold(
      backgroundColor: AuthPalette.ink,
      body: isLoading
          ? const Loader()
          : SafeArea(
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
                            'Enter code',
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
                          const SizedBox(height: 28),
                          AuthTextField(
                            label: 'New password',
                            controller: _newPasswordController,
                            isObscureText: true,
                            isNewPassword: true,
                          ),
                          const SizedBox(height: 36),

                          AuthGradientButton(
                            label: 'Reset password',
                            onTap: () async {
                              if (!_formKey.currentState!.validate()) {
                                showSnackBar(context, 'Missing fields!');
                                return;
                              }
                              await ref
                                  .read(authViewModelProvider.notifier)
                                  .resetPassword(
                                    email: widget.email,
                                    code: _codeController.text.trim(),
                                    newPassword: _newPasswordController.text.trim(),
                                  );
                            },
                          ),
                          const SizedBox(height: 28),

                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                'Use a different email',
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
