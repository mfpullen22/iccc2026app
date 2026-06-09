import "dart:async";
import "dart:convert";
import "package:iccc2026/main.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:forui/forui.dart";
import "package:iccc2026/models/presentation.dart";
import "package:iccc2026/screens/presentation_details_screen.dart";
import "package:iccc2026/screens/presenters_screen.dart";
import "package:iccc2026/screens/schedule_screen.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  List<Presentation> _sessions = [];
  bool _isLoadingSessions = true;
  String? _sessionLoadError;

  void _refreshNow() {
    if (!mounted) return;

    setState(() {
      _now = DateTime.now();
    });
  }

  @override
  void initState() {
    super.initState();

    _loadSessions();

    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _refreshNow();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    _refreshNow();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    try {
      final jsonString = await rootBundle.loadString("data/presentations.json");

      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

      final loadedSessions = decoded.entries.map((entry) {
        return Presentation.fromJson(
          entry.key,
          entry.value as Map<String, dynamic>,
        );
      }).toList();

      loadedSessions.sort((a, b) {
        final aStart = _sessionStartDateTime(a);
        final bStart = _sessionStartDateTime(b);

        if (aStart == null && bStart == null) return 0;
        if (aStart == null) return 1;
        if (bStart == null) return -1;

        return aStart.compareTo(bStart);
      });

      if (!mounted) return;

      setState(() {
        _sessions = loadedSessions;
        _isLoadingSessions = false;
        _sessionLoadError = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _sessions = [];
        _isLoadingSessions = false;
        _sessionLoadError = error.toString();
      });
    }
  }

  DateTime? _sessionStartDateTime(Presentation session) {
    return _sessionDateTime(session.day, session.startTime);
  }

  DateTime? _sessionEndDateTime(Presentation session) {
    return _sessionDateTime(session.day, session.endTime);
  }

  DateTime? _sessionDateTime(int day, String time) {
    final parts = time.trim().split(":");

    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;

    final date = switch (day) {
      0 => DateTime(2026, DateTime.june, 28),
      1 => DateTime(2026, DateTime.june, 29),
      2 => DateTime(2026, DateTime.june, 30),
      3 => DateTime(2026, DateTime.july, 1),
      4 => DateTime(2026, DateTime.july, 2),
      5 => DateTime(2026, DateTime.july, 3),
      _ => null,
    };

    if (date == null) return null;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  bool _isScheduledSession(Presentation session) {
    final start = _sessionStartDateTime(session);
    final end = _sessionEndDateTime(session);

    return start != null && end != null;
  }

  List<Presentation> _currentSessions() {
    return _sessions.where((session) {
      if (!_isScheduledSession(session)) return false;

      final start = _sessionStartDateTime(session)!;
      final end = _sessionEndDateTime(session)!;

      return (_now.isAtSameMomentAs(start) || _now.isAfter(start)) &&
          _now.isBefore(end);
    }).toList();
  }

  List<Presentation> _nextSessions() {
    final futureSessions = _sessions.where((session) {
      if (!_isScheduledSession(session)) return false;

      final start = _sessionStartDateTime(session)!;
      return start.isAfter(_now);
    }).toList();

    if (futureSessions.isEmpty) return [];

    futureSessions.sort((a, b) {
      final aStart = _sessionStartDateTime(a)!;
      final bStart = _sessionStartDateTime(b)!;
      return aStart.compareTo(bStart);
    });

    final nextStart = _sessionStartDateTime(futureSessions.first)!;

    return futureSessions.where((session) {
      final start = _sessionStartDateTime(session)!;
      return start.isAtSameMomentAs(nextStart);
    }).toList();
  }

  String _sessionTimeLabel(Presentation session) {
    if (session.dayLabel.isEmpty ||
        session.startTime.isEmpty ||
        session.endTime.isEmpty) {
      return "";
    }

    return "${session.dayLabel} • ${session.startTime} - ${session.endTime}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final screenHeight = MediaQuery.sizeOf(context).height;

    final liveCardHeight = (screenHeight * 0.28).clamp(185.0, 235.0).toDouble();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _LogoHeroCard(theme: theme),

            const SizedBox(height: 12),

            SizedBox(
              height: liveCardHeight,
              child: _LiveSessionsCard(
                isLoading: _isLoadingSessions,
                errorMessage: _sessionLoadError,
                currentSessions: _currentSessions(),
                nextSessions: _nextSessions(),
                timeLabelBuilder: _sessionTimeLabel,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _HomeNavCard(
                    icon: FIcons.calendarDays,
                    title: "Schedule",
                    subtitle: "View sessions",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ScheduleScreen(),
                        ),
                      );
                    },
                  ),
                  _HomeNavCard(
                    icon: FIcons.users,
                    title: "Presenters",
                    subtitle: "Browse speakers",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PresentersScreen(),
                        ),
                      );
                    },
                  ),
                  _HomeNavCard(
                    icon: FIcons.fileText,
                    title: "Abstracts",
                    subtitle: "Search posters & talks",
                    onTap: () {},
                  ),
                  _HomeNavCard(
                    icon: FIcons.map,
                    title: "Venue",
                    subtitle: "Maps & info",
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveSessionsCard extends StatelessWidget {
  const _LiveSessionsCard({
    required this.isLoading,
    required this.errorMessage,
    required this.currentSessions,
    required this.nextSessions,
    required this.timeLabelBuilder,
  });

  final bool isLoading;
  final String? errorMessage;
  final List<Presentation> currentSessions;
  final List<Presentation> nextSessions;
  final String Function(Presentation session) timeLabelBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Builder(
        builder: (context) {
          if (isLoading) {
            return const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            );
          }

          if (errorMessage != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Schedule",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Unable to load schedule.",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.78)),
                ),
              ],
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight;
              final sectionHeight = (availableHeight - 10) / 2;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: sectionHeight,
                    child: _SessionSection(
                      heading: "Current Session(s)",
                      emptyText: "No session currently in progress",
                      sessions: currentSessions,
                      timeLabelBuilder: timeLabelBuilder,
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    height: sectionHeight,
                    child: _SessionSection(
                      heading: "Next Session(s)",
                      emptyText: "No upcoming sessions found",
                      sessions: nextSessions,
                      timeLabelBuilder: timeLabelBuilder,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _SessionSection extends StatelessWidget {
  const _SessionSection({
    required this.heading,
    required this.emptyText,
    required this.sessions,
    required this.timeLabelBuilder,
  });

  final String heading;
  final String emptyText;
  final List<Presentation> sessions;
  final String Function(Presentation session) timeLabelBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const headingHeight = 18.0;
        const gapHeight = 4.0;

        final cardAreaHeight =
            (constraints.maxHeight - headingHeight - gapHeight)
                .clamp(0.0, constraints.maxHeight)
                .toDouble();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: headingHeight,
              child: Text(
                heading,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
            ),

            const SizedBox(height: gapHeight),

            SizedBox(
              height: cardAreaHeight,
              child: sessions.isEmpty
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        emptyText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.78),
                        ),
                      ),
                    )
                  : _CompactSessionRow(
                      sessions: sessions,
                      timeLabelBuilder: timeLabelBuilder,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _CompactSessionRow extends StatelessWidget {
  const _CompactSessionRow({
    required this.sessions,
    required this.timeLabelBuilder,
  });

  final List<Presentation> sessions;
  final String Function(Presentation session) timeLabelBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = sessions.length == 1
            ? constraints.maxWidth
            : constraints.maxWidth * 0.74;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: sessions.map((session) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: cardWidth,
                  height: constraints.maxHeight,
                  child: _CompactSessionCard(
                    session: session,
                    timeLabel: timeLabelBuilder(session),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _CompactSessionCard extends StatelessWidget {
  const _CompactSessionCard({required this.session, required this.timeLabel});

  final Presentation session;
  final String timeLabel;

  String get _middleLine {
    if (session.presenterName.trim().isNotEmpty) {
      return session.presenterName.trim();
    }

    return session.displayTitle.trim();
  }

  @override
  Widget build(BuildContext context) {
    return FTappable(
      onPress: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) {
              return PresentationDetailsScreen(presentation: session);
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: session.trackColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.trackLabel,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      height: 1.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    _middleLine.isEmpty ? "Session" : _middleLine,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    timeLabel,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.0,
                      color: Colors.white.withValues(alpha: 0.68),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoHeroCard extends StatelessWidget {
  const _LogoHeroCard({required this.theme});

  final FThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blueAccent.withValues(alpha: 0.18),
            Colors.blueAccent.withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                "assets/images/ICCC_logo.jpg",
                height: 105,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _HomeNavCard extends StatelessWidget {
  const _HomeNavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FTappable(
      onPress: onTap,
      child: FCard(
        mainAxisSize: MainAxisSize.max,
        title: Row(
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        child: Text(
          subtitle,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
        ),
      ),
    );
  }
}
