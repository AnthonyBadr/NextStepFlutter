import 'package:flutter/material.dart';

class StepSlider extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepSlider({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: index <= currentStep
                  ? Colors.blue
                  : Colors.grey, // Color changes based on currentStep
              child: Text(
                (index + 1).toString(),
                style: TextStyle(
                  color: index <= currentStep
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
