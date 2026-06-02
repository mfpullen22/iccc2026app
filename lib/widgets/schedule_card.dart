import "package:flutter/material.dart";
import "package:forui/forui.dart";
import "package:iccc2026/models/presentation.dart";
import "package:iccc2026/presentation_details_screen.dart";

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({super.key, required this.presentation, required this.itemsInRow});

  final Presentation presentation;
  final int itemsInRow;

  double get titleFontSize {
    if (itemsInRow >= 3) return 10;
    if (itemsInRow == 2) return 12;
    return 14;
  }

  double get presenterFontSize {
    if (itemsInRow >= 3) return 11;
    if (itemsInRow == 2) return 13;
    return 15;
  }

  @override
  Widget build(BuildContext context) {
    final hasTitle = presentation.title.trim().isNotEmpty;

    final centerCard =
        !hasTitle || presentation.isMealOrSpecial;

    return FTappable(
      onPress: () {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PresentationDetailsScreen(
        presentation: presentation,
      ),
    ),
  );
},
      child: Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 10,
  ),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border(
      left: BorderSide(
        color: presentation.trackColor,
        width: 8,
      ),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ],
  ),
  child: Column(
    mainAxisAlignment: centerCard
        ? MainAxisAlignment.center
        : MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      if (hasTitle) ...[
        Text(
          presentation.isMealOrSpecial
            ? presentation.shortTitle
            : '"${presentation.shortTitle}"',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: presentation.isMealOrSpecial
                ? FontWeight.bold
                : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        SizedBox(
          height: presentation.isMealOrSpecial ? 4 : 8,
        ),
      ],
      if (presentation.presenterName.isNotEmpty)
        Text(
          presentation.presenterName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: presenterFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
    ],
  ),
),
    );
  }
}