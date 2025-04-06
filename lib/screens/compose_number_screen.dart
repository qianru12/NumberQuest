import 'dart:async'; 
import 'dart:math'; 
import 'package:flutter/material.dart';
import '../utils/audio_manager.dart'; 
import '../widgets/feedback_popup.dart'; 
import '../widgets/quit_game_popup.dart'; 
import '../widgets/reward_popup.dart'; 
import '../widgets/music_toggle_button.dart';

class ComposeNumberScreen extends StatefulWidget {
  @override
  _ComposeNumberScreenState createState() => _ComposeNumberScreenState();
}

class _ComposeNumberScreenState extends State<ComposeNumberScreen> {
  int _score = 0; 
  int _currentQuestion = 0; 
  int _rewardStars = 0; 

  int _targetNumber = 0; 
  List<int> _numberChoices = []; 
  List<int?> _selectedNumbers = [
    null,
    null,
  ]; // Numbers selected by the user (initially empty)

  bool _showFeedback = false; 
  bool _isCorrectAnswer = false; 
  String _selectedObject = ''; 

  final int _fixedNumberOfChoices =
      10; // Fixed number of choices for all questions

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
    AudioManager.changeScreen('compose');
  }

  @override
  void dispose() {
    AudioManager.stopBackgroundMusic(); // Stop game music
    super.dispose();
  }

  void _generateQuestion() {
    // Clear previous selections
    setState(() {
      _selectedNumbers = [null, null];
    });

    // Generate a random target number between 2 and 20
    int targetNumber = Random().nextInt(19) + 2; 

    // Generate number choices that include valid answers
    List<int> choices = [];

    // First, add some valid answer pairs (numbers that add up to target)
    // We'll ensure at least 2 valid pairs
    for (int i = 0; i < 2; i++) {
      int firstNumber =
          Random().nextInt(targetNumber - 1) + 1; // 1 to (target-1)
      int secondNumber = targetNumber - firstNumber;

      // Ensure we don't add the same number twice
      if (!choices.contains(firstNumber)) {
        choices.add(firstNumber);
      }

      if (!choices.contains(secondNumber)) {
        choices.add(secondNumber);
      }
    }

    // Verify that we have at least one valid pair in our choices
    bool hasValidPair = false;
    for (int i = 0; i < choices.length; i++) {
      for (int j = i + 1; j < choices.length; j++) {
        if (choices[i] + choices[j] == targetNumber) {
          hasValidPair = true;
          break;
        }
      }
      if (hasValidPair) break;
    }

    // If somehow we don't have a valid pair, add one explicitly
    if (!hasValidPair) {
      int firstNumber = 1;
      int secondNumber = targetNumber - firstNumber;
      choices.clear(); // Clear existing choices to ensure we have room
      choices.add(firstNumber);
      choices.add(secondNumber);
    }

    while (choices.length < _fixedNumberOfChoices) {
      // Generate random numbers between 1 and 20
      int num = Random().nextInt(20) + 1; 
      if (!choices.contains(num) && num != targetNumber) {
        choices.add(num);
      }
    }

    // If we got more than _fixedNumberOfChoices choices, trim the list
    if (choices.length > _fixedNumberOfChoices) {
      // Make sure we keep at least one valid pair
      List<int> validPairIndices = [];
      for (int i = 0; i < choices.length; i++) {
        for (int j = i + 1; j < choices.length; j++) {
          if (choices[i] + choices[j] == targetNumber) {
            validPairIndices.add(i);
            validPairIndices.add(j);
            break;
          }
        }
        if (validPairIndices.isNotEmpty) break;
      }

      // Keep track of numbers we want to keep
      List<int> numbersToKeep = [];
      for (int index in validPairIndices) {
        numbersToKeep.add(choices[index]);
      }

      // Remove numbers to keep from choices
      for (int number in numbersToKeep) {
        choices.remove(number);
      }

      // Shuffle and trim remaining choices
      choices.shuffle();
      choices = choices.sublist(
        0,
        _fixedNumberOfChoices - numbersToKeep.length,
      );

      // Add back numbers to keep
      choices.addAll(numbersToKeep);
    }
    choices.shuffle();

    // Select a random object for the current question
    String object = _objects[Random().nextInt(_objects.length)];

    setState(() {
      _targetNumber = targetNumber;
      _numberChoices = choices;
      _selectedObject = object;
    });

    // Double-check that we have at least one valid pair in our final choices
    bool finalCheck = false;
    for (int i = 0; i < choices.length; i++) {
      for (int j = i + 1; j < choices.length; j++) {
        if (choices[i] + choices[j] == targetNumber) {
          finalCheck = true;
          print(
            'Valid pair found: ${choices[i]} + ${choices[j]} = $targetNumber',
          );
          break;
        }
      }
      if (finalCheck) break;
    }

    // regenerate the question
    if (!finalCheck) {
      print('No valid pair found, regenerating question');
      _generateQuestion(); // Recursively call again
      return;
    }

    // Play question sound effect
    AudioManager.playSoundEffect('sound_effect/Game3.mp3');
  }

  void _checkAnswer() {
    // Check if both slots are filled
    if (_selectedNumbers[0] == null || _selectedNumbers[1] == null) {
      // Show an alert or message that both slots need to be filled
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill both boxes with numbers.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Calculate sum of selected numbers
    int sum = (_selectedNumbers[0] ?? 0) + (_selectedNumbers[1] ?? 0);

    // Check if sum equals target number
    bool isCorrect = sum == _targetNumber;

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

  void _showResultPopup() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) {
        return RewardPopup(
          rewardStars: _rewardStars,
          correctAnswers: _score, // Pass the correct answer count
          onClose: () {
            AudioManager.playSoundEffect('sound_effect/Press_button.mp3');
            Navigator.pop(context); // Close the popup
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

  void resetGame() {
    setState(() {
      _score = 0;
      _currentQuestion = 0;
      _rewardStars = 0;
    });
    _generateQuestion();
  }

  // Handle drag of a number choice
  void _onDragNumber(int number, int? targetIndex) {
    if (targetIndex != null && targetIndex >= 0 && targetIndex < 2) {
      setState(() {
        _selectedNumbers[targetIndex] = number;
      });
    }
  }

  // Handle tap selection of a number choice
  void _onTapNumber(int number) {
    // Find the first empty slot
    for (int i = 0; i < _selectedNumbers.length; i++) {
      if (_selectedNumbers[i] == null) {
        setState(() {
          _selectedNumbers[i] =
              number; // No error, using non-nullable int directly
        });
        break;
      }
    }
  }

  // Remove a number from answer box
  void _removeNumber(int index) {
    setState(() {
      _selectedNumbers[index] = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image (unchanged)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background/game3.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.5), // Dark overlay
            ),
          ),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // Home Icon and Music Toggle Button (unchanged)
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

                  // Question text (unchanged)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      'Find two numbers that add up to $_targetNumber!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Target Number with Objects (unchanged)
                  Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$_targetNumber',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildTargetNumberObjects(),
                      ],
                    ),
                  ),

                  // Number Choices - Changed to flex: 2 (was flex: 3)
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 12),
                      child: _buildNumberChoices(),
                    ),
                  ),

                  // Answer Boxes - moved up
                  Container(
                    margin: EdgeInsets.only(
                      bottom: 24,
                    ), // Increased bottom margin
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAnswerBox(0),
                        SizedBox(width: 16),
                        Text(
                          '+',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 16),
                        _buildAnswerBox(1),
                        SizedBox(width: 16),
                        Text(
                          '=',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 16),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '$_targetNumber',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Added padding between answer box and button
                  SizedBox(height: 16),

                  // Check Answer Button
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 20,
                    ), // Added padding at bottom
                    child: ElevatedButton(
                      onPressed: _checkAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Check Answer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Added some extra space at the bottom
                  Expanded(flex: 1, child: SizedBox()),
                ],
              ),
            ),
          ),

          // Feedback Popup (unchanged)
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

  Widget _buildTargetNumberObjects() {
    // Calculate the size of objects based on the target number
    // The more objects, the smaller each should be
    double objectSize =
        _targetNumber <= 10
            ? 30
            : _targetNumber <= 20
            ? 25
            : _targetNumber <= 40
            ? 20
            : _targetNumber <= 60
            ? 15
            : 12;

    return Container(
      constraints: BoxConstraints(
        maxHeight: 200, // Maximum height constraint to prevent overflow
      ),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 5,
          runSpacing: 5,
          alignment: WrapAlignment.center,
          children: List.generate(
            _targetNumber,
            (index) => Container(
              width: objectSize,
              height: objectSize,
              child: Image.asset(
                'assets/objects/$_selectedObject',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberChoices() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children:
          _numberChoices.map((number) {
            // Check if this number is already selected in any answer box
            bool isSelected = _selectedNumbers.contains(number);

            // If not selected, make it draggable and tappable
            return !isSelected
                ? GestureDetector(
                  onTap: () => _onTapNumber(number),
                  child: Draggable<int>(
                    data: number,
                    feedback: _buildNumberItem(
                      number,
                      isSelected: false,
                      isDragging: true,
                    ),
                    childWhenDragging: _buildNumberItem(
                      number,
                      isSelected: true,
                      isDragging: false,
                    ),
                    child: _buildNumberItem(
                      number,
                      isSelected: false,
                      isDragging: false,
                    ),
                  ),
                )
                : _buildNumberItem(number, isSelected: true, isDragging: false);
          }).toList(),
    );
  }

  Widget _buildNumberItem(
    int number, {
    required bool isSelected,
    required bool isDragging,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color:
            isSelected
                ? Colors.grey.withOpacity(0.3)
                : Colors.orange.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDragging ? Colors.yellow : Colors.white,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.grey : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerBox(int index) {
    // If there's already a number in this answer box, show it with option to remove
    if (_selectedNumbers[index] != null) {
      return GestureDetector(
        onTap: () => _removeNumber(index),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.7),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  '${_selectedNumbers[index]}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Otherwise, show an empty drop target
    return DragTarget<int>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color:
                candidateData.isNotEmpty
                    ? Colors.green.withOpacity(0.5)
                    : Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: candidateData.isNotEmpty ? Colors.yellow : Colors.white,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
      onAccept: (number) {
        _onDragNumber(number, index);
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
