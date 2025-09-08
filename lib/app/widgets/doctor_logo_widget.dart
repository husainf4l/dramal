import 'package:flutter/material.dart';

class DoctorLogoWidget extends StatelessWidget {
  final double size;
  final bool showBackground;

  const DoctorLogoWidget({
    super.key,
    this.size = 120,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: showBackground
          ? BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(size * 0.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Medical Cross
          Container(
            width: size * 0.4,
            height: size * 0.6,
            decoration: BoxDecoration(
              color: showBackground ? Colors.white : Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(
            width: size * 0.6,
            height: size * 0.4,
            decoration: BoxDecoration(
              color: showBackground ? Colors.white : Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Doctor text overlay
          if (size > 80)
            Positioned(
              bottom: size * 0.05,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Dr. Amal',
                    style: TextStyle(
                      color: showBackground ? Colors.white : Theme.of(context).primaryColor,
                      fontSize: size * 0.15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Damara',
                    style: TextStyle(
                      color: showBackground ? Colors.white : Theme.of(context).primaryColor,
                      fontSize: size * 0.12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // "Best Doctor" badge
          if (size > 100)
            Positioned(
              top: size * 0.05,
              right: size * 0.05,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size * 0.08,
                  vertical: size * 0.03,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(size * 0.05),
                ),
                child: Text(
                  'BEST',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.08,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
