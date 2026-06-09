import "package:flutter/material.dart";
import "package:iccc2026/models/presentation.dart";
import "package:url_launcher/url_launcher.dart";

class PresentationDetailsScreen extends StatelessWidget {
  const PresentationDetailsScreen({super.key, required this.presentation});

  final Presentation presentation;

  Future<void> _sendEmail(BuildContext context, String email) async {
    final Uri emailUri = Uri(scheme: "mailto", path: email);

    final launched = await launchUrl(
      emailUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open email app for $email")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasTitle = presentation.title.trim().isNotEmpty;
    final displayTitle = hasTitle
        ? '"${presentation.displayTitle}"'
        : "Title Pending";

    return Scaffold(
      appBar: AppBar(title: const Text("Presentation Details")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailsHeaderCard(
                presentation: presentation,
                displayTitle: displayTitle,
              ),
              const SizedBox(height: 14),
              _PresenterCard(
                presentation: presentation,
                onEmailTap: () {
                  _sendEmail(context, presentation.presenterEmail.trim());
                },
              ),
              const SizedBox(height: 14),
              _AbstractCard(presentation: presentation),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsHeaderCard extends StatelessWidget {
  const _DetailsHeaderCard({
    required this.presentation,
    required this.displayTitle,
  });

  final Presentation presentation;
  final String displayTitle;

  @override
  Widget build(BuildContext context) {
    final isTalk = presentation.type.toLowerCase() == "talk";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(
          left: BorderSide(color: presentation.trackColor, width: 8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (presentation.typeLabel.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: presentation.trackColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                presentation.typeLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: presentation.trackColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            displayTitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.18,
              color: Colors.black,
            ),
          ),
          if (isTalk && presentation.dateTimeLabel.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.schedule, size: 18, color: Colors.black54),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    presentation.dateTimeLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.3,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          if (presentation.type.toLowerCase().trim() != "poster")
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 3),
                  decoration: BoxDecoration(
                    color: presentation.trackColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    presentation.trackLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.3,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PresenterCard extends StatelessWidget {
  const _PresenterCard({required this.presentation, required this.onEmailTap});

  final Presentation presentation;
  final VoidCallback onEmailTap;

  @override
  Widget build(BuildContext context) {
    final hasEmail = presentation.presenterEmail.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Presenter",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            presentation.presenterName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: Colors.black,
            ),
          ),
          if (presentation.affiliation.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...presentation.affiliation.map(
              (affiliation) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  affiliation,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.normal,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
          if (hasEmail) ...[
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: onEmailTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  presentation.presenterEmail.trim(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AbstractCard extends StatelessWidget {
  const _AbstractCard({required this.presentation});

  final Presentation presentation;

  @override
  Widget build(BuildContext context) {
    final abstractText = presentation.abstract.trim().isEmpty
        ? "No abstract available."
        : presentation.abstract.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Abstract",
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            abstractText,
            style: const TextStyle(
              fontSize: 15,
              height: 1.45,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
