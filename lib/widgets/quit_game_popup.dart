import 'package:flutter/material.dart';
import '../utils/audio_manager.dart';

class QuitGamePopup extends StatelessWidget {
  final VoidCallback onQuit;
  final VoidCallback onCancel; 

  const QuitGamePopup({
    required this.onQuit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Quit Game?'),
      content: Text('Are you sure you want to quit?'),
      actions: [
        TextButton(
          onPressed: () {
            AudioManager.playSoundEffect('sound_effect/Press_button.mp3');
            onCancel();
          },
          child: Text('No'),
        ),
        TextButton(
          onPressed: () {
            AudioManager.playSoundEffect('sound_effect/Press_button.mp3');
            onQuit();
          },
          child: Text('Yes'),
        ),
      ],
    );
  }
}