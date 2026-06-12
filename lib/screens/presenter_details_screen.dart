import "package:flutter/material.dart";
import "package:iccc2026/models/presentation.dart";
import "package:iccc2026/models/presenter.dart";
import "package:iccc2026/repositories/conference_repository.dart";
//import "package:iccc2026/repositories/local_json_conference_repository.dart";
import "package:iccc2026/repositories/firebase_conference_repository.dart";
import "package:iccc2026/screens/presentation_details_screen.dart";
import "package:url_launcher/url_launcher.dart";
import "package:iccc2026/utils/smooth_page_route.dart";

class PresenterDetailsScreen extends StatelessWidget {
  const PresenterDetailsScreen({
    super.key,
    required this.presenter,
    //this.repository = const LocalJsonConferenceRepository(),
    this.repository = const FirebaseConferenceRepository(),
  });

  final Presenter presenter;
  final ConferenceRepository repository;

  Future<void> _sendEmail(String email) async {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty) return;

    final Uri emailUri = Uri(scheme: "mailto", path: trimmedEmail);

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final affiliationText = presenter.affiliations.isEmpty
        ? "Affiliation Pending"
        : presenter.affiliations.join("\n\n");

    return Scaffold(
      appBar: AppBar(title: const Text("Presenter Details")),
      body: SafeArea(
        child: FutureBuilder<List<Presentation>>(
          future: repository.getPresentationsForPresenter(presenter),
          builder: (context, snapshot) {
            final presentations = snapshot.data ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PresenterHeaderCard(
                    presenter: presenter,
                    affiliationText: affiliationText,
                    onEmailTap: () => _sendEmail(presenter.email),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Presentations",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (snapshot.hasError)
                    _InfoCard(
                      child: Text(
                        "Unable to load presentations.\n\n${snapshot.error}",
                      ),
                    )
                  else if (presentations.isEmpty)
                    const _InfoCard(
                      child: Text(
                        "No presentations listed for this presenter.",
                      ),
                    )
                  else
                    ...presentations.map((presentation) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PresentationTile(
                          presentation: presentation,
                          onTap: () {
                            Navigator.of(context).push(
                              smoothPageRoute(
                                builder: (_) => PresentationDetailsScreen(
                                  presentation: presentation,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PresenterHeaderCard extends StatelessWidget {
  const _PresenterHeaderCard({
    required this.presenter,
    required this.affiliationText,
    required this.onEmailTap,
  });

  final Presenter presenter;
  final String affiliationText;
  final VoidCallback onEmailTap;

  @override
  Widget build(BuildContext context) {
    final email = presenter.email.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(115),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            presenter.fullName,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 18),
          _DetailSection(
            label: "Affiliation",
            child: Text(
              affiliationText,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 18),
          _DetailSection(
            label: "Email",
            child: email.isEmpty
                ? Text(
                    "Email Pending",
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
                : InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: onEmailTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        email,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _PresentationTile extends StatelessWidget {
  const _PresentationTile({required this.presentation, required this.onTap});

  final Presentation presentation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasDateTime = presentation.dateTimeLabel.trim().isNotEmpty;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.article_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      presentation.displayTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (hasDateTime) ...[
                      const SizedBox(height: 6),
                      Text(
                        presentation.dateTimeLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}
