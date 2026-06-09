import "package:flutter/material.dart";
import "package:iccc2026/widgets/schedule_card.dart";
import "package:iccc2026/models/presentation.dart";
import "package:iccc2026/repositories/local_json_conference_repository.dart";

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedDay = 0;
  late Future<List<Presentation>> _presentationsFuture;
  final LocalJsonConferenceRepository _repository =
      const LocalJsonConferenceRepository();

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
    final presentations = await _repository.getPresentations();

    return presentations
        .where((presentation) {
          return presentation.type == "talk" || presentation.type == "meal";
        })
        .where((presentation) {
          return presentation.day >= 0 && presentation.day <= 5;
        })
        .where((presentation) {
          return presentation.startTime.isNotEmpty;
        })
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Schedule")),
      body: SafeArea(
        child: FutureBuilder<List<Presentation>>(
          future: _presentationsFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final dayPresentations = snapshot.data!
                .where((presentation) => presentation.day == _selectedDay)
                .toList();

            final groupedByStartTime = <String, List<Presentation>>{};

            for (final presentation in dayPresentations) {
              groupedByStartTime
                  .putIfAbsent(presentation.startTime, () => [])
                  .add(presentation);
            }

            final startTimes = groupedByStartTime.keys.toList()..sort();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _selectedDay == 0
                            ? null
                            : () {
                                setState(() {
                                  _selectedDay--;
                                });
                              },
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
                            Text(_dayLabels[_selectedDay] ?? ""),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _selectedDay == 5
                            ? null
                            : () {
                                setState(() {
                                  _selectedDay++;
                                });
                              },
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
                const _TrackLegend(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    itemCount: startTimes.length,
                    itemBuilder: (context, index) {
                      final startTime = startTimes[index];
                      final presentations = groupedByStartTime[startTime]!;

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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: presentations.map((presentation) {
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ScheduleCard(
                                        presentation: presentation,
                                        itemsInRow: presentations.length,
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
                  ),
                ),
              ],
            );
          },
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
