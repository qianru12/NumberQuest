// audio_manager.dart
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioPlayer _backgroundPlayer = AudioPlayer();
  static final Map<String, AudioPlayer> _soundEffectPlayers = {};

  static double _mainVolume = 1.0;
  static double _bgMusicVolume = 1.0;
  static double _soundEffectVolume = 1.0;

  static bool _isMusicMuted = false;
  static String _currentScreen = 'home'; // Track current screen

  // Map screens to their background music
  static final Map<String, String> _screenMusic = {
    'home': 'background_music/home.mp3',
    'compare': 'background_music/game1.mp3',
    'order': 'background_music/game2.mp3',
    'compose': 'background_music/game3.mp3',
  };

  static Future<void> playBackgroundMusic(String path) async {
    if (_isMusicMuted) return;

    await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
    await _backgroundPlayer.setVolume(_bgMusicVolume * _mainVolume);
    await _backgroundPlayer.play(AssetSource(path));
  }

  static Future<void> changeScreen(String screenName) async {
    // Only change music if we're actually changing screens or music isn't playing
    if (_currentScreen != screenName ||
        _backgroundPlayer.state != PlayerState.playing) {
      _currentScreen = screenName;
      if (!_isMusicMuted) {
        await stopBackgroundMusic();
        String musicPath =
            _screenMusic[screenName] ??
            _screenMusic['home'] ??
            'background_music/home.mp3';
        await playBackgroundMusic(musicPath);
      }
    } else {
      _currentScreen = screenName;
    }
  }

  static String getCurrentScreen() {
    return _currentScreen;
  }

  static Future<void> stopBackgroundMusic() async {
    await _backgroundPlayer.stop();
  }

  static void toggleMusic() {
    _isMusicMuted = !_isMusicMuted;

    if (_isMusicMuted) {
      stopBackgroundMusic();
    } else {
      // Fix the nullable String issue with a more explicit null check
      String musicPath =
          _screenMusic[_currentScreen] ??
          _screenMusic['home'] ??
          'background_music/home.mp3';
      playBackgroundMusic(musicPath);
    }
  }

  static bool isMusicMuted() {
    return _isMusicMuted;
  }

  static Future<void> playSoundEffect(String path) async {
    // Create a new player for each sound effect or reuse existing
    final player = _soundEffectPlayers[path] ?? AudioPlayer();
    _soundEffectPlayers[path] = player;

    await player.setVolume(_soundEffectVolume * _mainVolume);
    await player.play(AssetSource(path));
  }

  static void setMainVolume(double volume) {
    _mainVolume = volume;
    _backgroundPlayer.setVolume(_bgMusicVolume * _mainVolume);
    _soundEffectPlayers.values.forEach((player) {
      player.setVolume(_soundEffectVolume * _mainVolume);
    });
  }

  static void setBgMusicVolume(double volume) {
    _bgMusicVolume = volume;
    _backgroundPlayer.setVolume(_bgMusicVolume * _mainVolume);
  }

  static void setSoundEffectVolume(double volume) {
    _soundEffectVolume = volume;
    _soundEffectPlayers.values.forEach((player) {
      player.setVolume(_soundEffectVolume * _mainVolume);
    });
  }

  static double getMainVolume() => _mainVolume;
  static double getBgMusicVolume() => _bgMusicVolume;
  static double getSoundEffectVolume() => _soundEffectVolume;
}