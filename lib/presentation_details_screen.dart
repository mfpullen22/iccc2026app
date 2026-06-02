import "package:flutter/material.dart";
import "package:iccc2026/models/presentation.dart";

class PresentationDetailsScreen extends StatelessWidget {
  const PresentationDetailsScreen({
    super.key,
    required this.presentation,
  });

  final Presentation presentation;

  @override
  Widget build(BuildContext context) {
    final title = presentation.title.trim().isEmpty
        ? "Title Pending"
        : presentation.title.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Presentation Details"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border(
      left: BorderSide(
        color: presentation.trackColor,
        width: 8,
      ),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '"${presentation.displayTitle}"',
        style: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      const SizedBox(height: 14),
      Text(
        presentation.presenterName,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      if (presentation.affiliation.isNotEmpty) ...[
        const SizedBox(height: 6),
        ...presentation.affiliation.map(
          (affiliation) => Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(
              affiliation,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
      if (presentation.presenterEmail.trim().isNotEmpty) ...[
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            // Later: open email app with this address in the To field.
          },
          child: Text(
            presentation.presenterEmail.trim(),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
      const SizedBox(height: 10),
      Text(
        "Track: ${presentation.trackLabel}",
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    ],
  ),
),
              const SizedBox(height: 24),
              const Text(
                "Abstract",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                presentation.abstract.trim().isEmpty
                    ? "No abstract available."
                    : presentation.abstract.trim(),
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}