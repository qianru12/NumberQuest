// setting_screen.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../utils/audio_manager.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _mainVolume = 1.0;
  double _bgMusicVolume = 1.0;
  double _soundEffectVolume = 1.0;

  bool _isMainMuted = false;
  bool _isBgMusicMuted = false;
  bool _isSoundEffectMuted = false;

  @override
  void initState() {
    super.initState();
    // Initialize volumes from AudioManager (if needed)
    _mainVolume = AudioManager.getMainVolume();
    _bgMusicVolume = AudioManager.getBgMusicVolume();
    _soundEffectVolume = AudioManager.getSoundEffectVolume();
  }

  void _updateMainVolume(double value) {
    setState(() {
      _mainVolume = value;
      _isMainMuted = value == 0.0; // Mute if volume is 0
    });
    AudioManager.setMainVolume(value);
  }

  void _updateBgMusicVolume(double value) {
    setState(() {
      _bgMusicVolume = value;
      _isBgMusicMuted = value == 0.0; 
    });
    AudioManager.setBgMusicVolume(value);
  }

  void _updateSoundEffectVolume(double value) {
    setState(() {
      _soundEffectVolume = value;
      _isSoundEffectMuted = value == 0.0;
    });
    AudioManager.setSoundEffectVolume(value);
  }

  void _toggleMute(String type) {
    AudioManager.playSoundEffect('sound_effect/Press_button.mp3');
    
    switch (type) {
      case 'main':
        setState(() {
          _isMainMuted = !_isMainMuted;
          _mainVolume = _isMainMuted ? 0.0 : 1.0;
        });
        AudioManager.setMainVolume(_mainVolume);
        break;
      case 'bgMusic':
        setState(() {
          _isBgMusicMuted = !_isBgMusicMuted;
          _bgMusicVolume = _isBgMusicMuted ? 0.0 : 1.0;
        });
        AudioManager.setBgMusicVolume(_bgMusicVolume);
        break;
      case 'soundEffect':
        setState(() {
          _isSoundEffectMuted = !_isSoundEffectMuted;
          _soundEffectVolume = _isSoundEffectMuted ? 0.0 : 1.0;
        });
        AudioManager.setSoundEffectVolume(_soundEffectVolume);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        AudioManager.playSoundEffect('sound_effect/Press_button.mp3');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          backgroundColor: Colors.black.withOpacity(0.2),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              AudioManager.playSoundEffect('sound_effect/Press_button.mp3');
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background/setting.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  _buildVolumeSlider(
                    title: 'Main Volume',
                    value: _mainVolume,
                    isMuted: _isMainMuted,
                    onChanged: _updateMainVolume,
                    onMute: () => _toggleMute('main'),
                    onChangeEnd: (value) {
                      AudioManager.playSoundEffect('sound_effect/Press_button.mp3');
                    },
                  ),
                  SizedBox(height: 20),
                  _buildVolumeSlider(
                    title: 'Background Music',
                    value: _bgMusicVolume,
                    isMuted: _isBgMusicMuted,
                    onChanged: _updateBgMusicVolume,
                    onMute: () => _toggleMute('bgMusic'),
                    onChangeEnd: (value) {
                      AudioManager.playSoundEffect('sound_effect/Press_button.mp3');
                    },
                  ),
                  SizedBox(height: 20),
                  _buildVolumeSlider(
                    title: 'Sound Effects',
                    value: _soundEffectVolume,
                    isMuted: _isSoundEffectMuted,
                    onChanged: _updateSoundEffectVolume,
                    onMute: () => _toggleMute('soundEffect'),
                    onChangeEnd: (value) {
                      AudioManager.playSoundEffect('sound_effect/Press_button.mp3');
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    Text(
                      'NumberQuest v1.0.0',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '© 2025 NumberQuest. All Rights Reserved.',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Need help? Email us at support@numberquest.com',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a volume slider with mute icon
  Widget _buildVolumeSlider({
    required String title,
    required double value,
    required bool isMuted,
    required Function(double) onChanged,
    required Function() onMute,
    required Function(double) onChangeEnd,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white, 
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                isMuted ? Icons.volume_off : Icons.volume_down,
                color: Colors.white,
              ),
              onPressed: onMute,
            ),
            Expanded(
              child: Slider(
                value: isMuted ? 0.0 : value,
                min: 0.0,
                max: 1.0,
                onChanged: onChanged,
                onChangeEnd: onChangeEnd,
                activeColor: Colors.white, 
                inactiveColor: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}