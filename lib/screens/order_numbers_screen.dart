import 'dart:async'; // For Timer
import 'dart:math'; // For Random()
import 'package:flutter/material.dart';
import '../utils/audio_manager.dart'; // Custom audio manager
import '../widgets/feedback_popup.dart'; // Reusable feedback popup
import '../widgets/quit_game_popup.dart'; // Reusable quit game popup
import '../widgets/reward_popup.dart'; // Reusable result display popup
import '../widgets/music_toggle_button.dart'; // Reusable music toggle button

class OrderNumbersScreen extends StatefulWidget {
  @override
  _OrderNumbersScreenState createState() => _OrderNumbersScreenState();
}

class _OrderNumbersScreenState extends State<OrderNumbersScreen> {
  int _score = 0; // Track the number of correct answers
  int _currentQuestion = 0; // Track the current question number
  int _rewardStars = 0; // Track the number of reward stars

  List<int> _numbers = []; // Random numbers to order
  List<int> _orderedNumbers = []; // For tracking draggable order
  String _orderType = ''; // "ascending" or "descending"
  int _numberOfItems = 3; // Start with 3 items, will increase based on progress

  bool _showFeedback = false; // Track whether to show feedback
  bool _isCorrectAnswer = false; // Track whether the answer is correct
  String _selectedObject = ''; // Random object for the current question

  // List of objects to display (same as in ComposeNumberScreen)
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
    AudioManager.changeScreen('order');
  }

  @override
  void dispose() {
    AudioManager.stopBackgroundMusic(); // Stop game music
    super.dispose();
  }

  void _generateQuestion() {
    // Calculate number of items based on progress
    // Start with 3 items, increase to 4 after question 5, then 5 after question 10
    if (_currentQuestion >= 10) {
      _numberOfItems = 5;
    } else if (_currentQuestion >= 5) {
      _numberOfItems = 4;
    } else {
      _numberOfItems = 3;
    }

    // Generate unique random numbers
    Set<int> uniqueNumbers = {};
    while (uniqueNumbers.length < _numberOfItems) {
      uniqueNumbers.add(
        Random().nextInt(101),
      ); // Random number between 0 and 100
    }

    List<int> numbers = uniqueNumbers.toList();

    // Select a random object for the current question
    String object = _objects[Random().nextInt(_objects.length)];

    setState(() {
      _numbers = List.from(numbers); // Make a copy to keep original order
      _orderedNumbers = List.from(numbers); // Keep as integers
      _orderType = _getRandomOrderType();
      _selectedObject = object;
    });

    // Play question sound effect
    if (_orderType == 'ascending') {
      AudioManager.playSoundEffect('sound_effect/Game2_ascending.mp3');
    } else {
      AudioManager.playSoundEffect('sound_effect/Game2_descending.mp3');
    }
  }

  String _getRandomOrderType() {
    return Random().nextBool() ? 'ascending' : 'descending';
  }

  void _checkAnswer() {
    // Get the current order
    List<int> currentOrder = List.from(_orderedNumbers);

    // Sort to check if answer is correct
    List<int> correctOrder = List.from(_numbers);
    if (_orderType == 'ascending') {
      correctOrder.sort();
    } else {
      correctOrder.sort((a, b) => b.compareTo(a));
    }

    // Check if current order matches correct order
    bool isCorrect = true;
    for (int i = 0; i < currentOrder.length; i++) {
      if (currentOrder[i] != correctOrder[i]) {
        isCorrect = false;
        break;
      }
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

  // Handle reordering of numbers
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final int item = _orderedNumbers.removeAt(oldIndex);
      _orderedNumbers.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate screen dimensions
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Calculate the safest row height based on available space and number of items
    final double headerHeight =
        100; // Estimated header height (app bar + padding)
    final double questionHeight = 100; // Estimated question container height
    final double buttonHeight = 80; // Estimated button height
    final double availableHeight =
        screenHeight - headerHeight - questionHeight - buttonHeight;

    // Calculate safe row height with spacing between rows
    final double verticalPadding =
        4.0 * (_numberOfItems + 1); // Account for spacing between rows
    final double rowHeight =
        (availableHeight - verticalPadding) / _numberOfItems;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background/game2.png'),
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
                      MusicToggleButton(
                        iconSize: 30,
                      ),
                    ],
                  ),

                  // Question text
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      _orderType == 'ascending'
                          ? 'Arrange the numbers in ascending order!'
                          : 'Arrange the numbers in descending order!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Draggable boxes area
                  Expanded(child: _buildDraggableBoxesArea(rowHeight)),

                  // Check Answer Button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                ],
              ),
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

  Widget _buildDraggableBoxesArea(double rowHeight) {
    return Theme(
      // Wrap in Theme to override the default drag decoration
      data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
      child: ReorderableListView.builder(
        itemCount: _orderedNumbers.length,
        onReorder: _onReorder,
        physics: NeverScrollableScrollPhysics(), // Disable scrolling
        itemBuilder: (context, index) {
          return _buildNumberRow(
            index: index,
            number: _orderedNumbers[index],
            key: ValueKey(_orderedNumbers[index]),
            height: rowHeight,
          );
        },
        // Add a custom ProxyDecorator to control the appearance during drag
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              return Material(
                elevation: 0, // No elevation shadow
                color: Colors.transparent, // Transparent background
                child: child,
              );
            },
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildNumberRow({
    required int index,
    required int number,
    required Key key,
    required double height,
  }) {
    // Calculate the size of objects based on the number
    double objectSize =
        number <= 10
            ? 25
            : number <= 20
            ? 22
            : number <= 40
            ? 18
            : number <= 60
            ? 15
            : 12;

    return ReorderableDragStartListener(
      key: key,
      index: index,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        height: height,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Row(
            children: [
              // Number on the left side
              Container(
                width: 70, // Fixed width for the number area
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '$number',
                  style: TextStyle(
                    fontSize: 28, // Smaller font size
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // Vertical divider
              Container(
                height: height * 0.8,
                width: 2,
                color: Colors.white.withOpacity(0.6),
              ),

              // Objects area on the right side
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: _buildNumberObjects(number, objectSize),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberObjects(int number, double objectSize) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 200, // Maximum height constraint to prevent overflow
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        direction: Axis.horizontal,
        alignment: WrapAlignment.start,
        children: List.generate(
          number,
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
