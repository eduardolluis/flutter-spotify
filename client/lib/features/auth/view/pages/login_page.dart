import 'package:melodix/core/utils.dart';
import 'package:melodix/core/widgets/loader.dart';
import 'package:melodix/features/auth/view/pages/signup_page.dart';
import 'package:melodix/features/auth/view/theme/auth_palette.dart';
import 'package:melodix/features/auth/view/widgets/auth_brand_mark.dart';
import 'package:melodix/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:melodix/features/auth/view/widgets/auth_text_field.dart';
import 'package:melodix/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:melodix/features/home/view/pages/forgot_password_page.dart';
import 'package:melodix/features/home/view/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authViewModelProvider.select((val) => val.isLoading)) == true;

    ref.listen(authViewModelProvider, (_, next) {
      next.when(
        data: (data) {
          if (data != null) {
            showSnackBar(context, "Welcome back!");

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
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AuthBrandMark(),
                          const SizedBox(height: 48),

                          Text(
                            'Log in',
                            style: GoogleFonts.fraunces(
                              fontSize: 40,
                              fontWeight: FontWeight.w600,
                              height: 1.05,
                              color: AuthPalette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'ACCESS YOUR LIBRARY',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              letterSpacing: 1.6,
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
                          const SizedBox(height: 28),
                          AuthTextField(
                            label: 'Password',
                            controller: _passwordController,
                            isObscureText: true,
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ForgotPasswordPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot password?',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AuthPalette.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),

                          AuthGradientButton(
                            label: "Continue",
                            onTap: () async {
                              if (formKey.currentState!.validate()) {
                                await ref
                                    .read(authViewModelProvider.notifier)
                                    .loginUser(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    );
                              } else {
                                showSnackBar(context, "Missing fields!");
                              }
                            },
                          ),
                          const SizedBox(height: 32),

                          Row(
                            children: [
                              const Expanded(
                                child: Divider(color: AuthPalette.hairline, height: 1),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  'OR',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    letterSpacing: 1.4,
                                    color: AuthPalette.textFaint,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: AuthPalette.hairline, height: 1),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AuthPalette.textPrimary,
                                side: const BorderSide(color: AuthPalette.hairlineStrong),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () {
                                ref.read(authViewModelProvider.notifier).loginWithGoogle();
                              },
                              icon: SvgPicture.asset(
                                'assets/images/google-logo.svg',
                                height: 18,
                                width: 18,
                              ),
                              label: Text(
                                "Continue with Google",
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SignupPage()),
                                );
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: "Don't have an account? ",
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AuthPalette.textMuted,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Sign up",
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: AuthPalette.accent,
                                        fontWeight: FontWeight.w600,
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
                ),
              ),
            ),
    );
  }
}
