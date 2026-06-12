import "package:flutter/material.dart";
import "package:iccc2026/widgets/schedule_card.dart";
import "package:iccc2026/models/presentation.dart";
//import "package:iccc2026/repositories/local_json_conference_repository.dart";
import "package:iccc2026/repositories/conference_repository.dart";
import "package:iccc2026/repositories/firebase_conference_repository.dart";
import "package:iccc2026/services/favorites_service.dart";

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({
    super.key,
    this.repository = const FirebaseConferenceRepository(),
  });

  final ConferenceRepository repository;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedDay = 0;
  final FavoritesService _favoritesService = const FavoritesService();
  late final Future<List<Presentation>> _presentationsFuture;

  //final LocalJsonConferenceRepository _repository =
  //const LocalJsonConferenceRepository();
  final ConferenceRepository _repository = const FirebaseConferenceRepository();

  static const Map<int, String> _dayLabels = {
    0: "Sunday, June 28",
    1: "Monday, June 29",
    2: "Tuesday, June 30",
    3: "Wednesday, July 1",
    4: "Thursday, July 2",
    5: "Friday, July 3",
  };

  @override
  void initState() {
    super.initState();
    _presentationsFuture = _loadPresentations();
  }

  Future<List<Presentation>> _loadPresentations() async {
    final presentations = await widget.repository.getPresentations();

    final scheduleItems = presentations.where((presentation) {
      final type = presentation.type.trim().toLowerCase();

      final isScheduledType = type == "talk" || type == "meal";
      final hasValidDay = presentation.day >= 0 && presentation.day <= 5;
      final hasStartTime = presentation.startTime.trim().isNotEmpty;

      return isScheduledType && hasValidDay && hasStartTime;
    }).toList();

    scheduleItems.sort((a, b) {
      final dayComparison = a.day.compareTo(b.day);
      if (dayComparison != 0) return dayComparison;

      final timeComparison = a.startTime.compareTo(b.startTime);
      if (timeComparison != 0) return timeComparison;

      return a.displayTitle.toLowerCase().compareTo(
        b.displayTitle.toLowerCase(),
      );
    });

    return scheduleItems;
  }

  void _goToPreviousDay() {
    if (_selectedDay == 0) return;

    setState(() {
      _selectedDay--;
    });
  }

  void _goToNextDay() {
    if (_selectedDay == 5) return;

    setState(() {
      _selectedDay++;
    });
  }

  List<Presentation> _presentationsForSelectedDay(
    List<Presentation> presentations,
  ) {
    return presentations
        .where((presentation) => presentation.day == _selectedDay)
        .toList();
  }

  Map<String, List<Presentation>> _groupPresentationsByStartTime(
    List<Presentation> presentations,
  ) {
    final groupedByStartTime = <String, List<Presentation>>{};

    for (final presentation in presentations) {
      groupedByStartTime
          .putIfAbsent(presentation.startTime, () => [])
          .add(presentation);
    }

    return groupedByStartTime;
  }

  Widget _buildScheduleList(
    List<Presentation> presentations,
    Set<String> favoriteIds,
  ) {
    final dayPresentations = _presentationsForSelectedDay(presentations);
    final groupedByStartTime = _groupPresentationsByStartTime(dayPresentations);

    final startTimes = groupedByStartTime.keys.toList()..sort();

    if (startTimes.isEmpty) {
      return Center(
        key: ValueKey("schedule-empty-day-$_selectedDay"),
        child: const Text("No scheduled sessions for this day."),
      );
    }

    return ListView.builder(
      key: ValueKey("schedule-list-day-$_selectedDay"),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      itemCount: startTimes.length,
      itemBuilder: (context, index) {
        final startTime = startTimes[index];
        final presentationsAtTime = groupedByStartTime[startTime]!;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 56,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    startTime,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: presentationsAtTime.map((presentation) {
                    final isLast = presentation == presentationsAtTime.last;
                    final isFavorite = favoriteIds.contains(presentation.id);

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: isLast ? 0 : 8),
                        child: Stack(
                          children: [
                            ScheduleCard(
                              presentation: presentation,
                              itemsInRow: presentationsAtTime.length,
                            ),
                            if (isFavorite)
                              const Positioned(
                                top: 6,
                                right: 6,
                                child: IgnorePointer(
                                  child: Icon(
                                    Icons.star,
                                    size: 18,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScheduleContent() {
    return FutureBuilder<List<Presentation>>(
      future: _presentationsFuture,
      builder: (context, presentationSnapshot) {
        Widget child;

        if (presentationSnapshot.connectionState == ConnectionState.waiting) {
          child = const Center(
            key: ValueKey("schedule-loading"),
            child: CircularProgressIndicator(),
          );
        } else if (presentationSnapshot.hasError) {
          child = Center(
            key: const ValueKey("schedule-error"),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                "Unable to load schedule.\n\n${presentationSnapshot.error}",
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else {
          return StreamBuilder<Set<String>>(
            stream: _favoritesService.favoriteIdsStream(),
            builder: (context, favoritesSnapshot) {
              final favoriteIds = favoritesSnapshot.data ?? <String>{};

              final child = _buildScheduleList(
                presentationSnapshot.data ?? [],
                favoriteIds,
              );

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final offsetAnimation = animation.drive(
                    Tween<Offset>(
                      begin: const Offset(0.025, 0),
                      end: Offset.zero,
                    ).chain(CurveTween(curve: Curves.easeOutCubic)),
                  );

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    ),
                  );
                },
                child: child,
              );
            },
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final offsetAnimation = animation.drive(
              Tween<Offset>(
                begin: const Offset(0.025, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutCubic)),
            );

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offsetAnimation, child: child),
            );
          },
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayLabel = _dayLabels[_selectedDay] ?? "";

    return Scaffold(
      appBar: AppBar(title: const Text("Schedule")),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _selectedDay == 0 ? null : _goToPreviousDay,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "Day $_selectedDay",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(dayLabel),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _selectedDay == 5 ? null : _goToNextDay,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            const _TrackLegend(),
            Expanded(child: _buildScheduleContent()),
          ],
        ),
      ),
    );
  }
}

class _TrackLegend extends StatelessWidget {
  const _TrackLegend();

  @override
  Widget build(BuildContext context) {
    const items = [
      _LegendItem("Clinical Advances", Colors.grey),
      _LegendItem("Drugs", Colors.yellow),
      _LegendItem("Genomics", Colors.orange),
      _LegendItem("Host-Pathogen", Colors.purpleAccent),
      _LegendItem("Immunology", Colors.pink),
      _LegendItem("Cell Biology", Colors.lightBlue),
      _LegendItem("Special / Meals", Colors.greenAccent),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: items.map((item) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 4),
              Text(item.label, style: const TextStyle(fontSize: 11)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _LegendItem {
  const _LegendItem(this.label, this.color);

  final String label;
  final Color color;
}
