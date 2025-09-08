import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kid_controller.dart';
import '../models/kid_model.dart';
import 'doctor_logo_widget.dart';

class KidsHeaderWidget extends StatelessWidget {
  final VoidCallback? onKidSwitch;
  final bool showDoctorLogo;

  const KidsHeaderWidget({
    super.key,
    this.onKidSwitch,
    this.showDoctorLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    final KidController kidController = Get.find<KidController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row with logo and main content
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showDoctorLogo) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const DoctorLogoWidget(
                    size: 32,
                    showBackground: false,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: _buildMainContent(kidController, isDark, context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Kids selector - Apple style segmented control inspired
          Obx(() => _buildKidsSelector(kidController, isDark, context)),
        ],
      ),
    );
  }

  Widget _buildMainContent(
      KidController kidController, bool isDark, BuildContext context) {
    return Obx(() {
      final selectedKid = kidController.selectedKid.value;
      final kidsCount = kidController.kids.length;

      if (selectedKid != null) {
        return _buildSelectedKidContent(selectedKid, isDark, context);
      } else if (kidsCount == 0) {
        return _buildWelcomeContent(isDark, context);
      } else {
        return _buildMultipleKidsContent(kidsCount, isDark, context);
      }
    });
  }

  Widget _buildSelectedKidContent(
      KidData kid, bool isDark, BuildContext context) {
    final nameParts = _parseFullName(kid.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name with Apple typography hierarchy
        if (nameParts.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              children: [
                // First name - prominent
                TextSpan(
                  text: nameParts[0],
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                // Middle and last names - subtle
                if (nameParts.length > 1) ...[
                  for (int i = 1; i < nameParts.length; i++) ...[
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: nameParts[i],
                      style: TextStyle(
                        fontSize: 24 - (i * 2), // Gradually smaller
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.8)
                            : Colors.white.withValues(alpha: 0.9),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ],
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Age and info row
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getKidEmoji(kid.dateOfBirth),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatAge(kid.dateOfBirth),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildWelcomeContent(bool isDark, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pediatric Care',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your child\'s health companion',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark
                ? Colors.white.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleKidsContent(
      int kidsCount, bool isDark, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Children',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$kidsCount ${kidsCount == 1 ? 'child' : 'children'}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKidsSelector(
      KidController kidController, bool isDark, BuildContext context) {
    final kids = kidController.kids;

    if (kids.length <= 1) {
      return kids.isEmpty
          ? _buildEmptyState(isDark, context)
          : const SizedBox.shrink();
    }

    final selectedKid = kidController.selectedKid.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Switch Child',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.8),
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Apple-style horizontal selector
        Container(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: kids.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final kid = kids[index];
              final isSelected = selectedKid?.id == kid.id;
              final nameParts = _parseFullName(kid.name);
              final displayName = nameParts.isNotEmpty ? nameParts[0] : 'Child';

              return GestureDetector(
                onTap: () {
                  kidController.selectKid(kid);
                  onKidSwitch?.call();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  width: 64,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.4)
                                : Colors.white.withValues(alpha: 0.5),
                            width: 2,
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Avatar
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.3),
                            width: isSelected ? 2.5 : 1.5,
                          ),
                        ),
                        child: ClipOval(
                          child: _buildKidAvatar(kid, isSelected),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Name
                      Text(
                        displayName.length > 6
                            ? '${displayName.substring(0, 6)}..'
                            : displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Add your first child to get started',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKidAvatar(KidData kid, bool isSelected) {
    // Beautiful gradient avatars
    final gradients = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)], // Purple
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)], // Blue
      [const Color(0xFF43e97b), const Color(0xFF38f9d7)], // Green
      [const Color(0xFFfa709a), const Color(0xFFfee140)], // Pink
      [const Color(0xFFa8edea), const Color(0xFFfed6e3)], // Mint
      [const Color(0xFFffecd2), const Color(0xFFfcb69f)], // Peach
      [const Color(0xFF84fab0), const Color(0xFF8fd3f4)], // Aqua
      [const Color(0xFFd299c2), const Color(0xFFfef9d7)], // Lavender
    ];

    final nameParts = _parseFullName(kid.name);
    final nameForHash = nameParts.isNotEmpty ? nameParts[0] : kid.name;
    final colorIndex = nameForHash.isNotEmpty
        ? (nameForHash.codeUnits.fold(0, (sum, unit) => sum + unit)) %
            gradients.length
        : 0;
    final gradientColors = gradients[colorIndex];

    final displayLetter = nameParts.isNotEmpty && nameParts[0].isNotEmpty
        ? nameParts[0][0].toUpperCase()
        : '?';

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Center(
        child: Text(
          displayLetter,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper functions
  List<String> _parseFullName(String fullName) {
    return fullName.trim().split(' ').where((part) => part.isNotEmpty).toList();
  }

  String _formatAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    final difference = now.difference(dateOfBirth);

    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 0 ? '${difference.inDays}d' : '${weeks}w';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}m';
    } else {
      final years = (difference.inDays / 365).floor();
      final remainingMonths = ((difference.inDays % 365) / 30).floor();

      if (remainingMonths == 0) {
        return '${years}y';
      } else {
        return '${years}y ${remainingMonths}m';
      }
    }
  }

  String _getKidEmoji(DateTime dateOfBirth) {
    final now = DateTime.now();
    final ageInYears = (now.difference(dateOfBirth).inDays / 365).floor();

    if (ageInYears <= 1) return '👶';
    if (ageInYears <= 3) return '🧒';
    if (ageInYears <= 8) return '👦';
    if (ageInYears <= 12) return '🧑';
    return '👨‍🎓';
  }
}
