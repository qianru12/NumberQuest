import 'package:flutter/material.dart';
import '../utils/audio_manager.dart';

class MusicToggleButton extends StatefulWidget {
  final double iconSize;

  MusicToggleButton({this.iconSize = 30});

  @override
  _MusicToggleButtonState createState() => _MusicToggleButtonState();
}

class _MusicToggleButtonState extends State<MusicToggleButton> {
  bool _isMusicMuted = false;

  @override
  void initState() {
    super.initState();
    _isMusicMuted = AudioManager.isMusicMuted();
  }

  void _toggleMusic() {
    AudioManager.toggleMusic();
    setState(() {
      _isMusicMuted = AudioManager.isMusicMuted();
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isMusicMuted ? Icons.music_off : Icons.music_note,
        color: Colors.white,
        size: widget.iconSize,
      ),
      onPressed: () {
        AudioManager.playSoundEffect('sound_effect/Press_button.mp3');
        _toggleMusic();
      },
    );
  }
}