import "package:flutter/material.dart";
import "package:forui/forui.dart";
import "package:iccc2026/models/presentation.dart";
import "package:iccc2026/screens/presentation_details_screen.dart";

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    super.key,
    required this.presentation,
    required this.itemsInRow,
  });

  final Presentation presentation;
  final int itemsInRow;

  double get titleFontSize {
    if (itemsInRow >= 3) return 9.5;
    if (itemsInRow == 2) return 11.5;
    return 14;
  }

  double get presenterFontSize {
    if (itemsInRow >= 3) return 9.8;
    if (itemsInRow == 2) return 11.8;
    return 15;
  }

  double get horizontalPadding {
    if (itemsInRow >= 3) return 6;
    if (itemsInRow == 2) return 8;
    return 12;
  }

  double get verticalPadding {
    if (itemsInRow >= 3) return 8;
    if (itemsInRow == 2) return 9;
    return 10;
  }

  double get leftBorderWidth {
    if (itemsInRow >= 3) return 5;
    if (itemsInRow == 2) return 6;
    return 8;
  }

  @override
  Widget build(BuildContext context) {
    final hasTitle = presentation.title.trim().isNotEmpty;
    final centerCard = !hasTitle || presentation.isMealOrSpecial;

    return FTappable(
      onPress: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                PresentationDetailsScreen(presentation: presentation),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: presentation.trackColor,
              width: leftBorderWidth,
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
                softWrap: true,
                style: TextStyle(
                  fontSize: titleFontSize,
                  height: 1.08,
                  fontWeight: presentation.isMealOrSpecial
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: presentation.isMealOrSpecial ? 4 : 6),
            ],
            if (presentation.presenterName.isNotEmpty)
              Text(
                presentation.presenterName,
                textAlign: TextAlign.center,
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: presenterFontSize,
                  height: 1.05,
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
