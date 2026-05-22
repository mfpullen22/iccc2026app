import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:forui/forui.dart";

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedDay = 1;
  late Future<List<Presentation>> _presentationsFuture;

  static const Map<int, String> _dayLabels = {
    1: "Monday, June 28",
    2: "Tuesday, June 29",
    3: "Wednesday, June 30",
    4: "Thursday, July 1",
    5: "Friday, July 2",
  };

  @override
  void initState() {
    super.initState();
    _presentationsFuture = _loadPresentations();
  }

  Future<List<Presentation>> _loadPresentations() async {
    final jsonString = await rootBundle.loadString(
      "data/presentations.json",
    );

    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

    return decoded.entries
        .map((entry) {
          return Presentation.fromJson(
            entry.key,
            entry.value as Map<String, dynamic>,
          );
        })
        .where((presentation) {
          return presentation.type == "talk" || presentation.type == "meal";
        })
        .where((presentation) {
          return presentation.day >= 1 && presentation.day <= 5;
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
      appBar: AppBar(
        title: const Text("Schedule"),
      ),
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
                        onPressed: _selectedDay == 1
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
                                      child: _ScheduleCard(
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

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.presentation,
    required this.itemsInRow,
  });

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
    return FTappable(
      onPress: () {
        // Details navigation will go here later.
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: presentation.trackColor.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              presentation.isMealOrSpecial
                  ? presentation.displayTitle
                  : '"${presentation.displayTitle}"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: presentation.isMealOrSpecial
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              presentation.presenterName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: presenterFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Presentation {
  const Presentation({
    required this.id,
    required this.title,
    required this.type,
    required this.track,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.presenterFirstName,
    required this.presenterLastNames,
  });

  final String id;
  final String title;
  final String type;
  final String track;
  final int day;
  final String startTime;
  final String endTime;
  final String presenterFirstName;
  final String presenterLastNames;

  factory Presentation.fromJson(String id, Map<String, dynamic> json) {
    return Presentation(
      id: id,
      title: json["title"]?.toString() ?? "",
      type: json["type"]?.toString().trim().toLowerCase() ?? "",
      track: json["track"]?.toString().trim().toLowerCase() ?? "",
      day: int.tryParse(json["day"]?.toString() ?? "") ?? 0,
      startTime: json["startTime"]?.toString() ?? "",
      endTime: json["endTime"]?.toString() ?? "",
      presenterFirstName: json["presenterFirstName"]?.toString() ?? "",
      presenterLastNames: json["presenterLastNames"]?.toString() ?? "",
    );
  }

  String get displayTitle {
    if (title.trim().isEmpty) return "Title Pending";
    return title.trim();
  }

  String get presenterName {
    final name = "$presenterFirstName $presenterLastNames".trim();
    return name.isEmpty ? "" : name;
  }

  bool get isMealOrSpecial {
    return type == "meal" || track == "special";
  }

  Color get trackColor {
    switch (track) {
      case "clinicaladv":
        return Colors.grey;
      case "drugs":
        return Colors.yellow;
      case "genomics":
        return Colors.orange;
      case "hostpathogen":
        return Colors.purple;
      case "immunology":
        return Colors.pink;
      case "cellbio":
        return Colors.lightBlue;
      default:
        return Colors.greenAccent;
    }
  }
}