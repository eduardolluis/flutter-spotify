import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fpdart/fpdart.dart';
import 'package:melodix/core/providers/current_user_notifier.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/core/utils.dart';
import 'package:melodix/core/widgets/custom_field.dart';
import 'package:melodix/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:melodix/features/home/view/widgets/vinyl_avatar.dart';

final _pickingAvatarProvider = StateProvider<bool>((ref) => false);

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final nameController = TextEditingController(text: ref.read(currentUserProvider)?.name);
  late final emailController = TextEditingController(text: ref.read(currentUserProvider)?.email);
  late String _savedName = nameController.text;
  late String _savedEmail = emailController.text;

  bool get _isDirty =>
      nameController.text.trim() != _savedName || emailController.text.trim() != _savedEmail;

  @override
  void initState() {
    super.initState();
    nameController.addListener(() => setState(() {}));
    emailController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    if (ref.read(_pickingAvatarProvider)) return;
    ref.read(_pickingAvatarProvider.notifier).state = true;

    try {
      final image = await pickImage();
      if (image == null) return;
      if (!mounted) return;

      final res = await ref.read(authViewModelProvider.notifier).updateAvatar(image);
      if (!mounted) return;

      switch (res) {
        case Left(value: final failure):
          showSnackBar(context, failure.message);
        case Right():
          showSnackBar(context, 'Profile picture updated');
      }
    } finally {
      if (mounted) ref.read(_pickingAvatarProvider.notifier).state = false;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = nameController.text.trim();
    final email = emailController.text.trim();

    final res = await ref
        .read(authViewModelProvider.notifier)
        .updateProfile(name: name, email: email);
    if (!mounted) return;

    switch (res) {
      case Left(value: final failure):
        showSnackBar(context, failure.message);
      case Right():
        setState(() {
          _savedName = name;
          _savedEmail = email;
        });
        showSnackBar(context, 'Profile updated');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isSaving = ref.watch(authViewModelProvider).isLoading;
    final isPickingAvatar = ref.watch(_pickingAvatarProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: (_isDirty && !isSaving) ? _save : null,
              child: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Save',
                      style: TextStyle(
                        color: _isDirty ? Pallete.gradient2 : Pallete.subtitleText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: isPickingAvatar ? null : _pickAndUploadAvatar,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VinylAvatar(avatarUrl: user?.avatar_url, size: 108),
                      if (isPickingAvatar)
                        Container(
                          width: 108,
                          height: 108,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.45),
                          ),
                          child: const CircularProgressIndicator(color: Pallete.whiteColor),
                        )
                      else
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: const BoxDecoration(
                              color: Pallete.gradient2,
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(
                                BorderSide(color: Pallete.cardColor, width: 2),
                              ),
                            ),
                            child: const Icon(
                              CupertinoIcons.camera_fill,
                              size: 15,
                              color: Pallete.backgroundColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: isPickingAvatar ? null : _pickAndUploadAvatar,
                child: const Text('Change photo', style: TextStyle(color: Pallete.gradient2)),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Name', style: TextStyle(fontSize: 13, color: Pallete.subtitleText)),
              ),
              const SizedBox(height: 8),
              CustomField(hintText: 'Name', controller: nameController),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Email', style: TextStyle(fontSize: 13, color: Pallete.subtitleText)),
              ),
              const SizedBox(height: 8),
              CustomField(hintText: 'Email', controller: emailController),
            ],
          ),
        ),
      ),
    );
  }
}
