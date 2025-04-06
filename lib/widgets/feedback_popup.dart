import 'package:flutter/material.dart';

class FeedbackPopup extends StatelessWidget {
  final bool isCorrect;
  final bool showFeedback;

  const FeedbackPopup({
    required this.isCorrect,
    required this.showFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: showFeedback ? 1.0 : 0.0, 
      duration: Duration(milliseconds: 300), 
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300), 
        width: showFeedback ? 150 : 100, 
        height: showFeedback ? 150 : 100,
        decoration: BoxDecoration(
          color: isCorrect ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCorrect
                ? Colors.green[800]! 
                : Colors.red[900]!, 
            width: 4, 
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
          size: 70, 
        ),
      ),
    );
  }
}