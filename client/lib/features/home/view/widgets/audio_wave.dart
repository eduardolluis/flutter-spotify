import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AudioWave extends StatefulWidget {
  final String path;
  const AudioWave({super.key, required this.path});

  @override
  State<AudioWave> createState() => _AudioWaveState();
}

class _AudioWaveState extends State<AudioWave> {
  final PlayerController playerController = PlayerController();
  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }

  @override
  void dispose() {
    playerController.dispose();
    super.dispose();
  }

  void initAudioPlayer() async {
    try {
      await playerController.preparePlayer(path: widget.path);
    } catch (e) {
      debugPrint('AudioWave: could not prepare player for ${widget.path}: $e');
    }
  }

  Future<void> playAndPause() async {
    try {
      if (!playerController.playerState.isPlaying) {
        await playerController.startPlayer();
      } else if (!playerController.playerState.isPaused) {
        await playerController.pausePlayer();
      }
    } catch (e) {
      debugPrint('AudioWave: could not play/pause: $e');
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: playAndPause,
          icon: Icon(
            playerController.playerState.isPlaying
                ? CupertinoIcons.pause_solid
                : CupertinoIcons.play_arrow_solid,
          ),
        ),
        Expanded(
          child: AudioFileWaveforms(
            size: const Size(double.infinity, 100),
            playerController: playerController,
            playerWaveStyle: const PlayerWaveStyle(
              fixedWaveColor: Pallete.borderColor,
              liveWaveColor: Pallete.gradient2,
              spacing: 7,
              showSeekLine: false,
            ),
            waveformType: WaveformType.fitWidth,
          ),
        ),
      ],
    );
  }
}
