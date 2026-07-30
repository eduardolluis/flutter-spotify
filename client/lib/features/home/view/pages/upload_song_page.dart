import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melodix/core/constants/genres.dart';
import 'package:melodix/core/providers/current_user_notifier.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/core/utils.dart';
import 'package:melodix/core/widgets/custom_field.dart';
import 'package:melodix/core/widgets/loader.dart';
import 'package:melodix/features/home/view/pages/home_page.dart';
import 'package:melodix/features/home/view/widgets/audio_wave.dart';
import 'package:melodix/features/home/viewmodel/home_viewmodel.dart';

class UploadSongPage extends ConsumerStatefulWidget {
  const UploadSongPage({super.key});

  @override
  ConsumerState<UploadSongPage> createState() => _UploadSongPageState();
}

class _UploadSongPageState extends ConsumerState<UploadSongPage> {
  final songNameController = TextEditingController();
  final artistController = TextEditingController();
  Color selectedColor = Pallete.cardColor;
  File? selectedImage;
  File? selectedAudio;
  Genre? selectedGenre;
  final formKey = GlobalKey<FormState>();

  void selectAudio() async {
    final pickedAudio = await pickAudio();
    if (pickedAudio != null && mounted) {
      setState(() {
        selectedAudio = pickedAudio;
      });
    }
  }

  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null && mounted) {
      setState(() {
        selectedImage = pickedImage;
      });
    }
  }

  void clearAudio() {
    setState(() {
      selectedAudio = null;
    });
  }

  void clearImage() {
    setState(() {
      selectedImage = null;
    });
  }

  @override
  void dispose() {
    songNameController.dispose();
    artistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(homeViewModelProvider, (previous, next) {
      if (next is AsyncError) {
        showSnackBar(context, next.error.toString());
      } else if (next is AsyncData && next.value != null) {
        showSnackBar(context, "Song uploaded successfully!");
        Navigator.of(context).pop();
      }
    });

    final homeState = ref.watch(homeViewModelProvider);
    final isLoading = homeState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Song"),
        leading: IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
              );
            }
          },
          icon: const Icon(Icons.close),
        ),
        actions: [
          isLoading
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate() &&
                        selectedAudio != null &&
                        selectedImage != null &&
                        selectedGenre != null) {
                      ref
                          .read(homeViewModelProvider.notifier)
                          .uploadSong(
                            selectedAudio: selectedAudio!,
                            selectedThumbnail: selectedImage!,
                            songName: songNameController.text.trim(),
                            artist: artistController.text.trim(),
                            color: selectedColor,
                            genre: selectedGenre!.label,
                          );
                    } else if (selectedGenre == null) {
                      showSnackBar(context, "Pick a genre for your song");
                    } else {
                      showSnackBar(context, "Missing Fields");
                    }
                  },
                  icon: const Icon(Icons.check),
                ),
        ],
      ),
      body: isLoading
          ? const Loader()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: selectImage,
                        child: selectedImage != null
                            ? Stack(
                                children: [
                                  SizedBox(
                                    height: 150,
                                    width: double.infinity,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(selectedImage!, fit: BoxFit.contain),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: clearImage,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : DottedBorder(
                                options: RoundedRectDottedBorderOptions(
                                  color: Pallete.borderColor,
                                  radius: const Radius.circular(10),
                                  strokeWidth: 1,
                                  strokeCap: StrokeCap.round,
                                  dashPattern: const [10, 4],
                                  padding: EdgeInsets.zero,
                                ),
                                child: const SizedBox(
                                  height: 150,
                                  width: double.infinity,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.folder_open, size: 40),
                                      SizedBox(height: 15),
                                      Text("Select thumbnail", style: TextStyle(fontSize: 15)),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 40),
                      selectedAudio != null
                          ? Column(
                              children: [
                                AudioWave(path: selectedAudio!.path),
                                const SizedBox(height: 10),
                                TextButton.icon(
                                  onPressed: clearAudio,
                                  icon: const Icon(Icons.close, color: Pallete.errorColor),
                                  label: const Text(
                                    "Cancel / Change Song",
                                    style: TextStyle(color: Pallete.errorColor),
                                  ),
                                ),
                              ],
                            )
                          : CustomField(
                              hintText: "Pick Song",
                              controller: null,
                              readOnly: true,
                              ontTap: selectAudio,
                            ),
                      const SizedBox(height: 20),
                      CustomField(hintText: "Artist", controller: artistController),
                      const SizedBox(height: 20),
                      CustomField(hintText: "Song Name", controller: songNameController),
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Genre",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "So people can find your song from Search",
                          style: TextStyle(fontSize: 12, color: Pallete.subtitleText),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: kGenres.map((genre) {
                          final isSelected = selectedGenre?.label == genre.label;
                          return GestureDetector(
                            onTap: () => setState(() => selectedGenre = genre),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? genre.color.withValues(alpha: 0.24)
                                    : Pallete.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? genre.color : Pallete.borderColor,
                                  width: isSelected ? 1.4 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    genre.icon,
                                    size: 16,
                                    color: isSelected ? genre.color : Pallete.subtitleText,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    genre.label,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Pallete.whiteColor : Pallete.subtitleText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      ColorPicker(
                        pickersEnabled: const {ColorPickerType.wheel: true},
                        color: selectedColor,
                        onColorChanged: (Color color) {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
