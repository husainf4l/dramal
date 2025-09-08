import 'package:flutter/material.dart';

class DrAmalDamraLogo extends StatelessWidget {
  final double? height;
  final double? width;
  final Color? textColor;
  final bool isMinimal;
  final double fontSize;
  final bool showSpecialty;

  const DrAmalDamraLogo({
    super.key,
    this.height,
    this.width,
    this.textColor,
    this.isMinimal = false,
    this.fontSize = 18.0,
    this.showSpecialty = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = textColor ?? 
        (isDarkMode ? Colors.white : Theme.of(context).colorScheme.onSurface);

    return Container(
      width: width ?? 120,
      height: height ?? (showSpecialty ? 100 : 70),
      child: Center(
        child: isMinimal ? _buildMinimalLogo(defaultTextColor) : _buildFullLogo(context, defaultTextColor),
      ),
    );
  }

  Widget _buildMinimalLogo(Color textColor) {
    return Text(
      'Dr. Amal Damra',
      style: TextStyle(
        color: textColor,
        fontSize: fontSize * 0.9,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        fontFamily: '.SF Pro Display',
      ),
    );
  }

  Widget _buildFullLogo(BuildContext context, Color textColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Dr. Amal Damra',
          style: TextStyle(
            color: textColor,
            fontSize: fontSize * 1.4,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
            height: 1.0,
            fontFamily: '.SF Pro Display',
          ),
          textAlign: TextAlign.center,
        ),
        
        if (showSpecialty) ...[
          SizedBox(height: fontSize * 0.6),
          Text(
            'Consultant Pediatrician & Neonatologist',
            style: TextStyle(
              color: textColor.withValues(alpha: 0.7),
              fontSize: fontSize * 0.55,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
              height: 1.4,
              fontFamily: '.SF Pro Text',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: fontSize * 0.4),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: fontSize * 1.0,
              vertical: fontSize * 0.3,
            ),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(fontSize * 1.0),
            ),
            child: Text(
              'Amman, Jordan',
              style: TextStyle(
                color: textColor.withValues(alpha: 0.6),
                fontSize: fontSize * 0.45,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1,
                fontFamily: '.SF Pro Text',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}