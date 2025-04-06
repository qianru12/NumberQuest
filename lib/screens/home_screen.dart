import 'setting_screen.dart';
import 'compare_number_screen.dart';
import 'compose_number_screen.dart';
import 'order_numbers_screen.dart';
import 'package:flutter/material.dart';
import '../utils/audio_manager.dart';
import '../widgets/music_toggle_button.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Make sure the audio is playing when the screen comes into focus
    if (AudioManager.getCurrentScreen() == 'home' &&
        !AudioManager.isMusicMuted()) {
      AudioManager.changeScreen('home');
    }
  }

  @override
  void initState() {
    super.initState();
    // Set current screen and play appropriate music
    AudioManager.changeScreen('home');
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _navigateToGame(String gameName) {
    // Play button click sound effect
    AudioManager.playSoundEffect('sound_effect/Press_button.mp3');

    // Navigate to the selected game screen
    switch (gameName) {
      case 'Compare Numbers':
        AudioManager.changeScreen('compare');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CompareNumbersScreen()),
        ).then((_) {
          // When returning from the game screen, change back to home music
          AudioManager.changeScreen('home');
        });
        break;
      case 'Order Numbers':
        AudioManager.changeScreen('order');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OrderNumbersScreen()),
        ).then((_) {
          // When returning from the game screen, change back to home music
          AudioManager.changeScreen('home');
        });
        break;
      case 'Compose Numbers':
        AudioManager.changeScreen('compose');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ComposeNumberScreen()),
        ).then((_) {
          // When returning from the game screen, change back to home music
          AudioManager.changeScreen('home');
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Dark Overlay
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background/home.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo (bigger size)
                Image.asset('assets/logo.png', width: 200, height: 200),
                SizedBox(height: 20),

                // Big Buttons (same width)
                SizedBox(
                  width: 250,
                  child: _buildGameButton('Compare Numbers'),
                ),
                SizedBox(height: 10),
                SizedBox(width: 250, child: _buildGameButton('Order Numbers')),
                SizedBox(height: 10),
                SizedBox(
                  width: 250,
                  child: _buildGameButton('Compose Numbers'),
                ),
              ],
            ),
          ),

          // Top Right: Settings Icon
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.settings, color: Colors.white, size: 30),
              onPressed: () {
                AudioManager.playSoundEffect('sound_effect/Press_button.mp3');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                ).then((_) {
                  // Ensure we're still on the home screen when returning from settings
                  AudioManager.changeScreen('home');
                });
              },
            ),
          ),

          // Top Left: Music Icon
          Positioned(top: 20, left: 20, child: MusicToggleButton()),
        ],
      ),
    );
  }

  // Helper method to build game buttons
  Widget _buildGameButton(String gameName) {
    return ElevatedButton(
      onPressed: () => _navigateToGame(gameName),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        gameName,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}