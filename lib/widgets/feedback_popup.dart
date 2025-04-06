import 'package:flutter/material.dart';

class FeedbackPopup extends StatelessWidget {
  final bool isCorrect; // Whether the answer is correct
  final bool showFeedback; // Whether to show the feedback

  const FeedbackPopup({
    required this.isCorrect,
    required this.showFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: showFeedback ? 1.0 : 0.0, // Fade in/out
      duration: Duration(milliseconds: 300), // Transition duration
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300), // Transition duration
        width: showFeedback ? 150 : 100, // Animate size
        height: showFeedback ? 150 : 100,
        decoration: BoxDecoration(
          color: isCorrect ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCorrect
                ? Colors.green[800]! // Darker green for border
                : Colors.red[900]!, // Darker red for border
            width: 4, // Border thickness
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          isCorrect ? Icons.check : Icons.close,
          color: Colors.white,
          size: 70, // Larger icon
        ),
      ),
    );
  }
}