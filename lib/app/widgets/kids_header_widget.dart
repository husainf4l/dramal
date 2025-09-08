import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kid_controller.dart';
import '../models/kid_model.dart';
import 'doctor_logo_widget.dart';

/// A modern, card-based header that displays the current child, allows switching
/// between children, and provides a welcoming message.
class KidsHeaderWidget extends StatelessWidget {
  final VoidCallback? onKidSwitch;
  final bool compactMode;

  const KidsHeaderWidget({
    super.key,
    this.onKidSwitch,
    this.compactMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final KidController kidController = Get.find<KidController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: Colors.black.withOpacity(0.1),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [colorScheme.surface, colorScheme.surface.withOpacity(0.8)]
                : [colorScheme.primary, colorScheme.primary.withOpacity(0.9)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(
            () {
              final kids = kidController.kids;
              final selectedKid = kidController.selectedKid.value;

              if (kids.isEmpty) {
                return _EmptyState(compactMode: compactMode);
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: _WelcomeSection(
                      selectedKid: selectedKid,
                      compactMode: compactMode,
                    ),
                  ),
                  if (!compactMode && kids.length > 1) ...[
                    const SizedBox(height: 12),
                    Flexible(
                      child: _KidsSwitcher(
                        kids: kids,
                        selectedKid: selectedKid,
                        onKidSelected: (kid) {
                          kidController.selectKid(kid);
                          onKidSwitch?.call();
                        },
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Section displaying the welcome message and doctor's logo.
class _WelcomeSection extends StatelessWidget {
  final KidData? selectedKid;
  final bool compactMode;

  const _WelcomeSection({this.selectedKid, required this.compactMode});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = isDark ? colorScheme.onSurface : colorScheme.onPrimary;

    return Row(
      children: [
        DoctorLogoWidget(size: compactMode ? 35 : 40, showBackground: false),
        const SizedBox(width: 12),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedKid != null
                      ? 'Hello, ${selectedKid!.name.split(' ').first}! 👋'
                      : 'Welcome!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: compactMode ? 18 : 22,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!compactMode)
                  Text(
                    "Let's check on your child's health.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textColor.withOpacity(0.8),
                        ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Horizontal list for switching between children.
class _KidsSwitcher extends StatelessWidget {
  final List<KidData> kids;
  final KidData? selectedKid;
  final ValueChanged<KidData> onKidSelected;

  const _KidsSwitcher({
    required this.kids,
    this.selectedKid,
    required this.onKidSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: kids.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final kid = kids[index];
          final isSelected = kid.id == selectedKid?.id;
          return _KidAvatar(
            kid: kid,
            isSelected: isSelected,
            onTap: () => onKidSelected(kid),
          );
        },
      ),
    );
  }
}

/// Circular avatar for a single child in the switcher.
class _KidAvatar extends StatelessWidget {
  final KidData kid;
  final bool isSelected;
  final VoidCallback onTap;

  const _KidAvatar({
    required this.kid,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectionColor = isDark ? colorScheme.secondary : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? selectionColor : Colors.transparent,
                  width: 2.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: selectionColor.withOpacity(0.5),
                          blurRadius: 5,
                        )
                      ]
                    : [],
              ),
              child: ClipOval(
                child: _InitialAvatar(kid: kid),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              kid.name.split(' ').first,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isDark ? colorScheme.onSurface : colorScheme.onPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Fallback avatar displaying the child's initial.
class _InitialAvatar extends StatelessWidget {
  final KidData kid;
  const _InitialAvatar({required this.kid});

  static const List<Color> _avatarColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

  @override
  Widget build(BuildContext context) {
    final name = kid.name.trim();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final color = _avatarColors[name.hashCode % _avatarColors.length];

    return Container(
      color: color.withOpacity(0.8),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// State displayed when no children have been added yet.
class _EmptyState extends StatelessWidget {
  final bool compactMode;
  const _EmptyState({required this.compactMode});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = isDark ? colorScheme.onSurface : colorScheme.onPrimary;

    return Row(
      children: [
        Icon(Icons.child_care_outlined, color: textColor, size: 30),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Add your first child to get started.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textColor.withOpacity(0.8),
                    ),
              ),
            ],
          ),
        ),
        if (!compactMode)
          ElevatedButton(
            onPressed: () {
              // TODO: Implement navigation to add child screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.onSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Add Child'),
          ),
      ],
    );
  }
}
