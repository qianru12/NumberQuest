import 'dart:async';
import 'dart:math';
import 'dart:math' show Random, sqrt, min, max;
import 'package:flutter/material.dart';
import '../utils/audio_manager.dart';
import '../widgets/feedback_popup.dart'; 
import '../widgets/quit_game_popup.dart'; 
import '../widgets/reward_popup.dart'; 
import '../widgets/music_toggle_button.dart'; 

class CompareNumbersScreen extends StatefulWidget {
  @override
  _CompareNumbersScreenState createState() => _CompareNumbersScreenState();
}

class _CompareNumbersScreenState extends State<CompareNumbersScreen> {
  int _score = 0; // Track the number of correct answers
  int _currentQuestion = 0; // Track the current question number
  int _rewardStars = 0; // Track the number of reward stars

  int _number1 = 0; // First random number
  int _number2 = 0; // Second random number
  String _questionType = ''; // "bigger" or "smaller"
  String _selectedObject = ''; // Random object for the current question

  bool _showFeedback = false; // Track whether to show feedback
  bool _isCorrectAnswer = false; // Track whether the answer is correct
  bool _isMusicMuted = false; // Track music mute state

  List<String> _objects = [
    'airplane.png',
    'bee.png',
    'bird.png',
    'butterfly.png',
    'cloud.png',
    'helicopter.png',
    'hot-air-balloon.png',
    'ladybug.png',
    'moon.png',
    'rocket.png',
    'snowflake.png',
    'star.png',
    'sun.png',
    'unicorn.png',
    'MrQuest.png',
    'Numi.png',
  ];

  @override
  void initState() {
    super.initState();
    _generateQuestion(); // Generate the first question
    AudioManager.changeScreen('compare');
  }

  @override
  void dispose() {
    AudioManager.stopBackgroundMusic(); // Stop game music
    super.dispose();
  }

  void _generateQuestion() {
    int number1, number2;
    do {
      number1 = _getRandomNumber();
      number2 = _getRandomNumber();
    } while (number1 == number2); // Ensure numbers are different

    setState(() {
      _number1 = number1;
      _number2 = number2;
      _questionType = _getRandomQuestionType();
      _selectedObject = _objects[_getRandomIndex(_objects.length)];
    });

    // Play question sound effect
    if (_questionType == 'bigger') {
      AudioManager.playSoundEffect('sound_effect/Game1_bigger.mp3');
    } else {
      AudioManager.playSoundEffect('sound_effect/Game1_smaller.mp3');
    }
  }

  int _getRandomNumber() {
    return Random().nextInt(51); // Random number between 0 and 50
  }

  String _getRandomQuestionType() {
    return Random().nextBool() ? 'bigger' : 'smaller';
  }

  int _getRandomIndex(int length) {
    return Random().nextInt(length);
  }

  void _checkAnswer(int selectedNumber) {
    bool isCorrect = false;

    if (_questionType == 'bigger') {
      isCorrect = selectedNumber == (_number1 > _number2 ? _number1 : _number2);
    } else {
      isCorrect = selectedNumber == (_number1 < _number2 ? _number1 : _number2);
    }

    // Play sound effect
    if (isCorrect) {
      AudioManager.playSoundEffect('sound_effect/Correct_answer.mp3');
      setState(() {
        _score++;
      });
    } else {
      AudioManager.playSoundEffect('sound_effect/Wrong_answer.mp3');
    }

    // Show feedback for 0.5 seconds
    setState(() {
      _showFeedback = true;
      _isCorrectAnswer = isCorrect;
    });

    Timer(Duration(milliseconds: 500), () {
      setState(() {
        _showFeedback = false;
      });

      // Move to the next question or end the game
      setState(() {
        _currentQuestion++;
      });

      if (_currentQuestion >= 15) {
        // Calculate stars based on total score (1 star per 5 correct answers)
        setState(() {
          _rewardStars = (_score / 5).floor();
        });
        _showResultPopup();
      } else {
        _generateQuestion();
      }
    });
  }

  void resetGame() {
    setState(() {
      _score = 0;
      _currentQuestion = 0;
      _rewardStars = 0;
    });
    _generateQuestion();
  }

  // Update the _showResultPopup method
  void _showResultPopup() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) {
        return RewardPopup(
          rewardStars: _rewardStars,
          correctAnswers: _score, 
          onClose: () {
            AudioManager.playSoundEffect('sound_effect/Press_button.mp3');
            Navigator.pop(context); 
            Navigator.pop(context); // Go back to the home screen
          },
          onReplay: () {
            AudioManager.playSoundEffect('sound_effect/Press_button.mp3');
            Navigator.pop(context); // Close the popup
            resetGame(); // Reset the game
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background/game1.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.5), // Dark overlay
            ),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                // Home Icon and Music Toggle Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.home, color: Colors.white, size: 30),
                      onPressed: () {
                        AudioManager.playSoundEffect(
                          'sound_effect/Press_button.mp3',
                        );
                        _showQuitConfirmationPopup();
                      },
                    ),
                    MusicToggleButton(iconSize: 30),
                  ],
                ),

                // Question
                Text(
                  _questionType == 'bigger'
                      ? 'Which number is bigger?'
                      : 'Which number is smaller?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),

                // Boxes with Numbers and Objects
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: _buildNumberBox(_number1)),
                      SizedBox(height: 5),
                      Expanded(child: _buildNumberBox(_number2)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Feedback Popup
          if (_showFeedback)
            Center(
              child: FeedbackPopup(
                isCorrect: _isCorrectAnswer,
                showFeedback: _showFeedback,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNumberBox(int number) {
    return GestureDetector(
      onTap: () => _checkAnswer(number),
      child: Column(
        children: [
          // Number displayed above the box
          Container(
            padding: EdgeInsets.symmetric(vertical: 1),
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          // Box for objects only
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
              ),
              padding: EdgeInsets.all(5),
              width: double.infinity,
              child: _buildObjectGrid(number),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectGrid(int number) {
    if (number == 0) {
      return SizedBox(); // No objects to display
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Get available width & height of the container
        double maxWidth = constraints.maxWidth;
        double maxHeight = constraints.maxHeight;

        // Calculate optimal column count based on available width
        int crossAxisCount = min(8, max(2, (sqrt(number)).ceil()));

        // Calculate item size dynamically to prevent overflow
        double itemSize = maxWidth / crossAxisCount;
        double totalRows = (number / crossAxisCount).ceilToDouble();
        double expectedHeight = totalRows * itemSize;

        // Adjust childAspectRatio to ensure everything fits
        double childAspectRatio = itemSize / (maxHeight / totalRows);

        return GridView.builder(
          physics: NeverScrollableScrollPhysics(), // Disable scrolling
          padding: EdgeInsets.all(1),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 2,
            mainAxisSpacing: 4,
            childAspectRatio: childAspectRatio.clamp(
              0.5,
              1.5,
            ), // Ensure reasonable scaling
          ),
          shrinkWrap: true,
          itemCount: number,
          itemBuilder: (context, index) {
            return Image.asset(
              'assets/objects/$_selectedObject',
              fit: BoxFit.contain, // Ensure image fits properly
            );
          },
        );
      },
    );
  }

  void _showQuitConfirmationPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return QuitGamePopup(
          onQuit: () {
            Navigator.pop(context); // Close the popup
            Navigator.pop(context); // Go back to the home screen
          },
          onCancel: () {
            Navigator.pop(context); // Close the popup
          },
        );
      },
    );
  }
}
