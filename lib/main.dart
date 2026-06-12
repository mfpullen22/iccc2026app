import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:iccc2026/screens/auth_screen.dart';
import 'package:iccc2026/screens/home_screen.dart';

import "package:iccc2026/navigation/root_navigator.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const Application());
}

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    final theme =
        const <TargetPlatform>{
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.fuchsia,
        }.contains(defaultTargetPlatform)
        ? FThemes.green.dark.touch
        : FThemes.green.dark.desktop;

    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      supportedLocales: FLocalizations.supportedLocales,
      localizationsDelegates: const [...FLocalizations.localizationsDelegates],
      theme: theme.toApproximateMaterialTheme(),
      builder: (_, child) => FTheme(
        data: theme,
        child: FToaster(child: FTooltipGroup(child: child!)),
      ),

      // AuthGate decides whether to show AuthScreen or HomeScreen.
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        Widget child;

        if (snapshot.connectionState == ConnectionState.waiting) {
          child = const FScaffold(
            key: ValueKey("loading"),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          child = const FScaffold(key: ValueKey("home"), child: HomeScreen());
        } else {
          child = const FScaffold(key: ValueKey("auth"), child: AuthScreen());
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 550),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final scaleAnimation = Tween<double>(
              begin: 0.97,
              end: 1.0,
            ).animate(animation);

            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: scaleAnimation, child: child),
            );
          },
          child: child,
        );
      },
    );
  }
}
