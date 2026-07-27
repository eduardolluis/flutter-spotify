import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/auth/view/pages/signup_page.dart';
import 'package:client/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:client/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:client/features/home/view/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/welcome-background.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: isLoading
            ? const Loader()
            : Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Login",
                            style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Welcome back, we missed you.",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 36),

                          CustomField(hintText: "Email", controller: _emailController),
                          const SizedBox(height: 18),

                          CustomField(
                            hintText: "Password",
                            controller: _passwordController,
                            isObscureText: true,
                          ),
                          const SizedBox(height: 28),

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
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.24))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  "or",
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.24))),
                            ],
                          ),
                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.white.withValues(alpha: 0.24)),
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                                shape: const StadiumBorder(),
                              ),
                              onPressed: () {
                                ref.read(authViewModelProvider.notifier).loginWithGoogle();
                              },
                              icon: SvgPicture.asset(
                                'assets/images/google-logo.svg',
                                height: 22,
                                width: 22,
                              ),
                              label: const Text(
                                "Continue with Google",
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

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
                                  style: Theme.of(context).textTheme.titleMedium,
                                  children: const [
                                    TextSpan(
                                      text: "Sign Up",
                                      style: TextStyle(
                                        color: Pallete.whiteColor,
                                        fontWeight: FontWeight.bold,
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
