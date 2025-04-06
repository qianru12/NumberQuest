import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class RewardPopup extends StatefulWidget {
  final int rewardStars; // Number of reward stars
  final VoidCallback onClose; // Callback for closing the popup and going home
  final VoidCallback onReplay; // Callback for starting a new game
  final int correctAnswers; // Number of correct answers out of 15

  const RewardPopup({
    required this.rewardStars,
    required this.onClose,
    required this.onReplay,
    this.correctAnswers = 0, 
  });

  @override
  State<RewardPopup> createState() => _RewardPopupState();
}

class _RewardPopupState extends State<RewardPopup> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  @override
  void initState() {
    super.initState();
    // Play sound effect when the popup appears
    _playRewardSound();
  }
  
  @override
  void dispose() {
    // Dispose of the audio player when the widget is removed
    _audioPlayer.dispose();
    super.dispose();
  }
  
  Future<void> _playRewardSound() async {
    try {
      final String soundPath = widget.rewardStars >= 2 
        ? 'sound_effect/Cheer.mp3'
        : 'sound_effect/Disappointed.mp3';
      
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  String _getEncouragingMessage(int stars) {
    switch (stars) {
      case 1:
        return 'Great start! Keep going!';
      case 2:
        return 'Awesome! You\'re doing so well!';
      case 3:
        return 'Fantastic! You\'re a math champion!';
      default:
        return 'Try again to earn more stars!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Prevent closing by tapping outside or back button
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  'Game Over',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              SizedBox(height: 20),
              
              // Star display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Image.asset(
                      index < widget.rewardStars 
                          ? 'assets/star_filled.png' 
                          : 'assets/star_outline.png',
                      width: 50,
                      height: 50,
                    ),
                  );
                }),
              ),
              SizedBox(height: 20),
              
              // Score display with decorative container
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Text(
                      '${widget.correctAnswers}/15',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Correct',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              
              // Encouraging message
              Text(
                _getEncouragingMessage(widget.rewardStars),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 30),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Home button
                  ElevatedButton(
                    onPressed: widget.onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.all(15),
                      shape: CircleBorder(),
                    ),
                    child: Icon(
                      Icons.home,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  
                  // Replay button
                  ElevatedButton(
                    onPressed: widget.onReplay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.all(15),
                      shape: CircleBorder(),
                    ),
                    child: Icon(
                      Icons.replay,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}