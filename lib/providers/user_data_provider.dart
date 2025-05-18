import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/onboarding_data.dart';

class UserDataProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  OnboardingData _onboardingData = OnboardingData();
  String? _photoUrl;
  String? _email;

  UserDataProvider() {
    _listenToUserDoc();
  }

  OnboardingData get onboardingData => _onboardingData;
  String? get photoUrl => _photoUrl;
  String? get email => _email;

  void _listenToUserDoc() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _db.collection('users').doc(uid).snapshots().listen((snap) {
      if (!snap.exists) return;
      final data = snap.data()!;
      _onboardingData = OnboardingData(
        birthYear: data['birthYear'] as int?,
        trackingReason: data['trackingReason'] as String?,
        periodFeeling: data['periodFeeling'] as String?,
        contraceptiveUse: data['contraceptiveUse'] as String?,
        cycleType: data['cycleType'] as String?,
        mentalHealthAspects: List<String>.from(
          data['mentalHealthAspects'] ?? [],
        ),
        sexualImprovement: data['sexualImprovement'] as String?,
        sexualDesireFluctuation: data['sexualDesireFluctuation'] as String?,
        lastPeriodDate: (data['lastPeriodDate'] as Timestamp?)?.toDate(),
        periodLength: data['periodLength'] as int?, // ← Mapea aquí
      );
      _photoUrl = data['photoUrl'] as String?;
      _email = FirebaseAuth.instance.currentUser?.email;
      notifyListeners();
    });
  }
}
