import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/onboarding_data.dart';

class UserDataProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot>? _docSub;

  OnboardingData _onboardingData = OnboardingData();
  String? _displayName;
  String? _photoUrl;
  String? _email;

  UserDataProvider() {
    // Escucha cambios de autenticación para suscribirse dinámicamente al documento de usuario
    _authSub = FirebaseAuth.instance.authStateChanges().listen(
      _onAuthStateChanged,
    );
  }

  void _onAuthStateChanged(User? firebaseUser) {
    // Cancelar suscripción previa
    _docSub?.cancel();
    if (firebaseUser != null) {
      _email = firebaseUser.email;
      // Suscribirse a los cambios en Firestore para el usuario actual
      _docSub = _db
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots()
          .listen((snap) {
            if (!snap.exists) return;
            final data = snap.data()!;
            _displayName = data['displayName'] as String?;
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
              sexualDesireFluctuation:
                  data['sexualDesireFluctuation'] as String?,
              lastPeriodDate: (data['lastPeriodDate'] as Timestamp?)?.toDate(),
              periodLength: data['periodLength'] as int?,
            );
            _photoUrl = data['photoUrl'] as String?;
            notifyListeners();
          });
    } else {
      // Si el usuario cierra sesión, limpiar datos
      _displayName = null;
      _onboardingData = OnboardingData();
      _photoUrl = null;
      _email = null;
      notifyListeners();
    }
  }

  OnboardingData get onboardingData => _onboardingData;
  String? get displayName => _displayName;
  String? get photoUrl => _photoUrl;
  String? get email => _email;

  @override
  void dispose() {
    _authSub?.cancel();
    _docSub?.cancel();
    super.dispose();
  }
}
