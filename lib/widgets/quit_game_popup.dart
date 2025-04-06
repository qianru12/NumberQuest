// quit_game_popup.dart
import 'package:flutter/material.dart';
import '../utils/audio_manager.dart'; // Custom audio manager

class QuitGamePopup extends StatelessWidget {
  final VoidCallback onQuit; // Callback for quitting the game
  final VoidCallback onCancel; // Callback for canceling the action

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
        // No Button
        TextButton(
          onPressed: () {
            // Play sound effect
            AudioManager.playSoundEffect('sound_effect/Press_button.mp3');
            // Trigger the onCancel callback
            onCancel();
          },
          child: Text('No'),
        ),
        // Yes Button
        TextButton(
          onPressed: () {
            // Play sound effect
            AudioManager.playSoundEffect('sound_effect/Press_button.mp3');
            // Trigger the onQuit callback
            onQuit();
          },
          child: Text('Yes'),
        ),
      ],
    );
  }
}