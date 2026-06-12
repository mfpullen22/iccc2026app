import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:forui/forui.dart";
import "package:iccc2026/navigation/root_navigator.dart";

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signOut() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // First remove this pushed Account route so it cannot stay frozen on top.
      rootNavigatorKey.currentState?.popUntil((route) => route.isFirst);

      // Let the pop finish before changing auth state.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await FirebaseAuth.instance.signOut();

      // AuthGate will now show AuthScreen.
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = "Unable to sign out. Please try again.";
      });
    }
  }

  Future<void> _confirmDeleteAccount() async {
    String password = "";

    final confirmedPassword = await showDialog<String>(
      context: context,
      barrierDismissible: !_isLoading,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete account?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "This will permanently delete your account, favorites, and saved "
                "account data. This cannot be undone.\n\n"
                "Enter your password to confirm.",
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  password = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(password),
              child: const Text("Delete Account"),
            ),
          ],
        );
      },
    );

    if (confirmedPassword == null) {
      return;
    }

    final trimmedPassword = confirmedPassword.trim();

    if (trimmedPassword.isEmpty) {
      if (!mounted) return;

      setState(() {
        _errorMessage = "Please enter your password to delete your account.";
      });
      return;
    }

    await _deleteAccount(trimmedPassword);
  }

  Future<void> _deleteAccount(String password) async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    if (user == null || email == null) {
      if (!mounted) return;

      setState(() {
        _errorMessage = "No signed-in user was found.";
      });
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Firebase requires recent sign-in before deleting an account.
      await user.reauthenticateWithCredential(credential);

      // Delete app-specific Firestore data while the user is still authenticated.
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .delete();

      // Remove the pushed account route before changing auth state.
      rootNavigatorKey.currentState?.popUntil((route) => route.isFirst);

      // Give Flutter a frame to remove the account page cleanly.
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Delete the Firebase Auth account.
      await user.delete();

      // AuthGate should now show AuthScreen.
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = _friendlyDeleteError(e);
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = "Unable to delete Firestore account data: ${e.code}";
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = "Unable to delete account. Please try again.";
      });
    }
  }

  String _friendlyDeleteError(FirebaseAuthException e) {
    switch (e.code) {
      case "wrong-password":
      case "invalid-credential":
        return "The password you entered is incorrect.";
      case "requires-recent-login":
        return "Please sign out, sign back in, and try deleting your account again.";
      case "user-not-found":
        return "This account could not be found.";
      case "too-many-requests":
        return "Too many attempts. Please wait a little while and try again.";
      default:
        return e.message ?? "Unable to delete account.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "Unknown e-mail";

    return FScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SimpleScreenHeader(
                title: "My Account",
                onBack: _isLoading ? null : () => Navigator.of(context).pop(),
              ),

              const SizedBox(height: 24),

              FCard(
                title: const Text("Account"),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Signed in as",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(email),
                  ],
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],

              const SizedBox(height: 18),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                SizedBox(
                  height: 52,
                  child: FButton(
                    onPress: _signOut,
                    child: const Text("Sign Out"),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 52,
                  child: FButton(
                    onPress: _confirmDeleteAccount,
                    child: const Text("Delete Account"),
                  ),
                ),
              ],

              const Spacer(),

              Text(
                "Deleting your account removes your Firebase Authentication login "
                "and your app account data, including favorites.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.58),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SimpleScreenHeader extends StatelessWidget {
  const _SimpleScreenHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback? onBack;

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
