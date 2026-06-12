import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _isCreateAccountMode = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Please enter both your e-mail and password.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // AuthGate handles navigation automatically.
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _friendlyAuthError(e);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = "Something went wrong. Please try again.";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createAccount() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = "Please complete all fields.";
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = "The passwords do not match.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        await _firestore.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "email": email,
          "createdAt": FieldValue.serverTimestamp(),
          "favoritePresentationIds": <String>[],
          "savedNotes": {},
          "role": "attendee",
        });
      }

      // AuthGate handles navigation automatically.
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _friendlyAuthError(e);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = "Something went wrong while creating your account.";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage =
            "Enter your e-mail address first, then tap Forgot my password.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.sendPasswordResetEmail(email: email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password reset e-mail sent. Check your inbox."),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _friendlyAuthError(e);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage =
              "Unable to send password reset e-mail. Please try again.";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case "invalid-email":
        return "Please enter a valid e-mail address.";
      case "user-disabled":
        return "This account has been disabled.";
      case "user-not-found":
        return "No account was found with that e-mail address.";
      case "wrong-password":
      case "invalid-credential":
        return "The e-mail or password is incorrect.";
      case "email-already-in-use":
        return "An account already exists with that e-mail address.";
      case "weak-password":
        return "Please choose a stronger password.";
      case "operation-not-allowed":
        return "E-mail/password accounts are not enabled for this app yet.";
      case "too-many-requests":
        return "Too many attempts. Please wait a little while and try again.";
      default:
        return e.message ?? "Authentication failed. Please try again.";
    }
  }

  void _switchToCreateAccountMode() {
    setState(() {
      _isCreateAccountMode = true;
      _errorMessage = null;
      _confirmPasswordController.clear();
    });
  }

  void _switchToLoginMode() {
    setState(() {
      _isCreateAccountMode = false;
      _errorMessage = null;
      _confirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth > 500 ? 430.0 : screenWidth * 0.88;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: SizedBox(
              width: formWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: "app-logo",
                    child: Image.asset(
                      "assets/images/ICCC_logo.jpg",
                      height: 135,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    _isCreateAccountMode ? "Create Account" : "Login",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: "E-mail",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: _isCreateAccountMode
                        ? TextInputAction.next
                        : TextInputAction.done,
                    onSubmitted: (_) {
                      if (!_isCreateAccountMode) {
                        _login();
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),

                  if (_isCreateAccountMode) ...[
                    const SizedBox(height: 14),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _createAccount(),
                      decoration: const InputDecoration(
                        labelText: "Re-enter your password",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_reset_outlined),
                      ),
                    ),
                  ],

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 22),

                  if (_isLoading)
                    const CircularProgressIndicator()
                  else if (_isCreateAccountMode)
                    _CreateAccountButtons(
                      onCreateAccount: _createAccount,
                      onAlreadyHaveAccount: _switchToLoginMode,
                    )
                  else
                    _LoginButtons(
                      onLogin: _login,
                      onForgotPassword: _resetPassword,
                      onCreateAccount: _switchToCreateAccountMode,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginButtons extends StatelessWidget {
  const _LoginButtons({
    required this.onLogin,
    required this.onForgotPassword,
    required this.onCreateAccount,
  });

  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: onLogin,
                  child: const Text("Login"),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: onForgotPassword,
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Forgot My Password",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton.icon(
            onPressed: onCreateAccount,
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text("Create Account"),
          ),
        ),
      ],
    );
  }
}

class _CreateAccountButtons extends StatelessWidget {
  const _CreateAccountButtons({
    required this.onCreateAccount,
    required this.onAlreadyHaveAccount,
  });

  final VoidCallback onCreateAccount;
  final VoidCallback onAlreadyHaveAccount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: onCreateAccount,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text("Create Account"),
          ),
        ),

        const SizedBox(height: 12),

        TextButton(
          onPressed: onAlreadyHaveAccount,
          child: const Text("I already have an account"),
        ),
      ],
    );
  }
}
