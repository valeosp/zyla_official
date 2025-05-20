// lib/widgets/initial_loader.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InitialLoader extends StatelessWidget {
  const InitialLoader({Key? key}) : super(key: key);

  Future<String> _getInitialRoute() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return '/welcome'; // Ahora va a WelcomeScreen
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    final onboarded = doc.data()?['onboardingComplete'] as bool? ?? false;
    return onboarded ? '/home' : '/onboarding';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getInitialRoute(),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        Future.microtask(() {
          Navigator.of(context).pushReplacementNamed(snap.data!);
        });
        return const SizedBox.shrink();
      },
    );
  }
}
