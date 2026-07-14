import 'dart:io';

import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:client/features/home/repositories/home_repository.dart';
import 'package:client/features/home/view/widgets/audio_wave.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  bool isUploading = false;

  Future<void> uploadSong() async {
    final user = ref.read(currentUserProvider);
    if (selectedAudio == null || selectedImage == null) {
      showSnackBar(context, 'Select a song and thumbnail');
      return;
    }
    if (artistController.text.trim().isEmpty ||
        songNameController.text.trim().isEmpty) {
      showSnackBar(context, 'Enter the artist and song name');
      return;
    }
    if (user == null || user.token.trim().isEmpty) {
      showSnackBar(context, 'Log in before uploading a song');
      return;
    }

    setState(() => isUploading = true);
    try {
      await HomeRepository().uploadSong(
        song: selectedAudio!,
        thumbnail: selectedImage!,
        artist: artistController.text.trim(),
        songName: songNameController.text.trim(),
        hexCode:
            '#${selectedColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
        token: user.token,
      );
      if (!mounted) return;
      showSnackBar(context, 'Song uploaded successfully');
      songNameController.clear();
      artistController.clear();
      setState(() {
        selectedAudio = null;
        selectedImage = null;
      });
    } catch (e) {
      if (mounted) {
        showSnackBar(context, e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => isUploading = false);
      }
    }
  }

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

  @override
  void dispose() {
    songNameController.dispose();
    artistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Song"),
        actions: [
          isUploading
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  onPressed: uploadSong,
                  icon: const Icon(Icons.check),
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: selectImage,
                child: selectedImage != null
                    ? SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(selectedImage!, fit: BoxFit.cover),
                        ),
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
                              Text(
                                "Select thumbnail",
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 40),
              selectedAudio != null
                  ? AudioWave(path: selectedAudio!.path)
                  : CustomField(
                      hintText: "Pick Song",
                      controller: null,
                      readOnly: true,
                      ontTap: selectAudio,
                    ),
              const SizedBox(height: 20),
              CustomField(hintText: "Artist", controller: artistController),
              const SizedBox(height: 20),
              CustomField(
                hintText: "Song Name",
                controller: songNameController,
              ),
              const SizedBox(height: 20),
              ColorPicker(
                pickersEnabled: {ColorPickerType.wheel: true},
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
    );
  }
}
