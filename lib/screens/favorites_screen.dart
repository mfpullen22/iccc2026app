import "package:flutter/material.dart";
import "package:forui/forui.dart";
import "package:iccc2026/models/presentation.dart";
//import "package:iccc2026/repositories/local_json_conference_repository.dart";
import "package:iccc2026/repositories/conference_repository.dart";
import "package:iccc2026/repositories/firebase_conference_repository.dart";
import "package:iccc2026/screens/presentation_details_screen.dart";
import "package:iccc2026/services/favorites_service.dart";

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = const FavoritesService();

  //final LocalJsonConferenceRepository _repository =
  //const LocalJsonConferenceRepository();
  final ConferenceRepository _repository = const FirebaseConferenceRepository();

  late final Future<List<Presentation>> _presentationsFuture;

  @override
  void initState() {
    super.initState();
    _presentationsFuture = _repository.getPresentations();
  }

  List<Presentation> _favoritePresentations(
    List<Presentation> presentations,
    Set<String> favoriteIds,
  ) {
    return presentations
        .where((presentation) => favoriteIds.contains(presentation.id))
        .toList();
  }

  List<Presentation> _favoriteTalks(List<Presentation> favorites) {
    return favorites.where((presentation) {
      return presentation.type.toLowerCase().trim() == "talk";
    }).toList()..sort((a, b) {
      final dayComparison = a.day.compareTo(b.day);
      if (dayComparison != 0) return dayComparison;

      return a.startTime.compareTo(b.startTime);
    });
  }

  List<Presentation> _favoritePosters(List<Presentation> favorites) {
    return favorites.where((presentation) {
      return presentation.type.toLowerCase().trim() == "poster";
    }).toList()..sort((a, b) {
      final aLastName = _presenterLastName(a);
      final bLastName = _presenterLastName(b);

      return aLastName.compareTo(bLastName);
    });
  }

  String _presenterLastName(Presentation presentation) {
    final presenterName = presentation.presenterName.trim();

    if (presenterName.isEmpty) {
      return "";
    }

    final parts = presenterName.split(RegExp(r"\s+"));

    return parts.last.toLowerCase();
  }

  void _openDetails(Presentation presentation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PresentationDetailsScreen(presentation: presentation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SimpleScreenHeader(
                title: "Favorites",
                onBack: () => Navigator.of(context).pop(),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: FutureBuilder<List<Presentation>>(
                  future: _presentationsFuture,
                  builder: (context, presentationSnapshot) {
                    if (presentationSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (presentationSnapshot.hasError) {
                      return Center(
                        child: Text(
                          "Unable to load presentations.\n\n"
                          "${presentationSnapshot.error}",
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final allPresentations =
                        presentationSnapshot.data ?? <Presentation>[];

                    return StreamBuilder<Set<String>>(
                      stream: _favoritesService.favoriteIdsStream(),
                      builder: (context, favoritesSnapshot) {
                        final favoriteIds =
                            favoritesSnapshot.data ?? <String>{};

                        final favorites = _favoritePresentations(
                          allPresentations,
                          favoriteIds,
                        );

                        final talks = _favoriteTalks(favorites);
                        final posters = _favoritePosters(favorites);

                        if (talks.isEmpty && posters.isEmpty) {
                          return Center(
                            child: Text(
                              "Your favorite presentations will appear here.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.78),
                              ),
                            ),
                          );
                        }

                        return ListView(
                          padding: const EdgeInsets.only(bottom: 24),
                          children: [
                            _FavoritesSection(
                              title: "Talks",
                              emptyMessage: "No favorite talks yet.",
                              presentations: talks,
                              onTapPresentation: _openDetails,
                            ),

                            const SizedBox(height: 18),

                            _FavoritesSection(
                              title: "Posters",
                              emptyMessage: "No favorite posters yet.",
                              presentations: posters,
                              onTapPresentation: _openDetails,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoritesSection extends StatelessWidget {
  const _FavoritesSection({
    required this.title,
    required this.emptyMessage,
    required this.presentations,
    required this.onTapPresentation,
  });

  final String title;
  final String emptyMessage;
  final List<Presentation> presentations;
  final void Function(Presentation presentation) onTapPresentation;

  @override
  Widget build(BuildContext context) {
    return FCard(
      title: Text(title),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (presentations.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                emptyMessage,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
              ),
            )
          else
            ...presentations.map((presentation) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _FavoritePresentationCard(
                  presentation: presentation,
                  onTap: () => onTapPresentation(presentation),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _FavoritePresentationCard extends StatelessWidget {
  const _FavoritePresentationCard({
    required this.presentation,
    required this.onTap,
  });

  final Presentation presentation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isTalk = presentation.type.toLowerCase().trim() == "talk";
    final isPoster = presentation.type.toLowerCase().trim() == "poster";

    final subtitle = isTalk
        ? presentation.dateTimeLabel
        : isPoster
        ? presentation.presenterName
        : presentation.typeLabel;

    return FTappable(
      onPress: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(color: presentation.trackColor, width: 5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.star, size: 18, color: Colors.amber),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    presentation.displayTitle.isEmpty
                        ? "Title Pending"
                        : presentation.displayTitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (subtitle.trim().isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.25,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ],

                  if (presentation.presenterName.trim().isNotEmpty &&
                      isTalk) ...[
                    const SizedBox(height: 6),
                    Text(
                      presentation.presenterName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.62),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleScreenHeader extends StatelessWidget {
  const _SimpleScreenHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FTappable(
          onPress: onBack,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: const Icon(FIcons.chevronLeft, size: 22),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
