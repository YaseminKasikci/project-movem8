import 'package:flutter/material.dart';

/// A reusable FAB displaying a centered, rounded "+" icon inside a circle.
class LessFAB extends StatelessWidget {
  /// Callback when the button is pressed
  final VoidCallback onPressed;
  /// Background color of the FAB
  
  final Color backgroundColor;
  /// Diameter of the outer circle
  final double diameter;
  /// Thickness of the cross bars
  final double barThickness;
  /// Length of each bar in the cross
  final double barLength;
  
  final String heroTag; 

  const LessFAB({
    super.key,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF60C8B3),
    this.diameter = 70.0,
    this.barThickness = 6.0,
    this.barLength = 40.0,
    this.heroTag = 'defaultLessFAB'
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -4),
      child: FloatingActionButton(
        heroTag: heroTag, 
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        elevation: 4,
        shape: const CircleBorder(),
        child: SizedBox(
          width: diameter,
          height: diameter,
          child: Stack(
            alignment: Alignment.center,
            children: [
             // barre horizontale arrondie
          Container(
            width: 35,
            height: 7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
  
            ],
          ),
        ),
      ),
    );
  }
}
