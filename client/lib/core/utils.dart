import 'dart:io';

import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

String rgbToHex(Color color) {
  return '${color.red.toRadixString(16).padLeft(2, '0')}${color.green.toRadixString(16).padLeft(2, '0')}${color.blue.toRadixString(16).padLeft(2, '0')}';
}

Color hexToColor(String hex) {
  // Defensivo: limpia espacios u otros separadores por si el valor viene
  // de datos guardados antes de corregir rgbToHex (ej. "af 4f 4f").
  final cleanHex = hex.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
  return Color(int.parse(cleanHex, radix: 16) + 0xFF000000);
}

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(content)));
}

Future<File?> pickImage() async {
  try {
    final filePickerRes = await FilePicker.pickFiles(type: FileType.image);

    if (filePickerRes != null) {
      return File(filePickerRes.files.first.xFile.path);
    }
    return null;
  } catch (e) {
    return null;
  }
}

Future<File?> pickAudio() async {
  try {
    // En iOS, FileType.audio abre el selector nativo de Apple Music
    // (solo canciones compradas/sincronizadas). Usamos FileType.custom
    // con extensiones concretas para que abra la app Archivos normal.
    final filePickerRes = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'flac', 'ogg'],
    );

    if (filePickerRes != null) {
      return File(filePickerRes.files.first.xFile.path);
    }
    return null;
  } catch (e) {
    return null;
  }
}

/// Pide confirmación y borra una canción. Vive aquí (no en un widget en
/// particular) para poder reusarla desde cualquier lista de canciones
/// (Library, Search, etc.) sin duplicar el diálogo.
Future<void> confirmDeleteSong(BuildContext context, WidgetRef ref, String songId) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Pallete.cardColor,
        title: const Text('Eliminar canción'),
        content: const Text('Esta acción no se puede deshacer. ¿Seguro que quieres eliminarla?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Pallete.errorColor)),
          ),
        ],
      );
    },
  );

  if (confirmed != true) return;

  final res = await ref.read(homeViewModelProvider.notifier).deleteSong(songId);
  if (!context.mounted) return;

  switch (res) {
    case Left(value: final failure):
      showSnackBar(context, failure.message);
    case Right():
      showSnackBar(context, 'Canción eliminada');
  }
}
