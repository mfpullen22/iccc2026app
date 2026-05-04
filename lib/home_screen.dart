import "package:flutter/material.dart";
import "package:forui/forui.dart";

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Image.asset(
              "assets/images/ICCC_logo.jpg",
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 20),
          FractionallySizedBox(
            widthFactor: 0.95,
            child: FCard(
              style: const .delta(
                decoration: .shapeDelta(color: Colors.blueAccent),
              ),
              mainAxisSize: MainAxisSize.min,
              title: Text(
                "Current Session:",
                style: TextStyle(
                  fontSize: 18,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text(
                "Placeholder text for the current session information.",
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    "HOME SCREEN PLACEHOLDER",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
