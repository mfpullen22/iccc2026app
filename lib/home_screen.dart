import "package:flutter/material.dart";
import "package:forui/forui.dart";
import "package:iccc2026/schedule_screen.dart";

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _LogoHeroCard(theme: theme),

            const SizedBox(height: 16),

            FractionallySizedBox(
              widthFactor: 1,
              child: FCard(
                style: const .delta(
                  decoration: .shapeDelta(color: Colors.blueAccent),
                ),
                mainAxisSize: MainAxisSize.min,
                title: const Text(
                  "Current Session(s)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text(
                  "Placeholder text for the current session information.",
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.count(
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
                    onTap: () {},
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
