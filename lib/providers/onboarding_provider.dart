// lib/providers/onboarding_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/onboarding_data.dart';
import '../services/firestore_service.dart';

class OnboardingProvider with ChangeNotifier {
  final OnboardingData _data = OnboardingData();
  final FirestoreService _firestore = FirestoreService();

  // Nuevo flag
  bool _completed = false;
  bool get completed => _completed;

  OnboardingData get data => _data;

  // Carga desde users/{uid} el flag onboardingComplete
  Future<void> loadStatus(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    _completed = doc.data()?['onboardingComplete'] as bool? ?? false;
    notifyListeners();
  }

  void setBirthYear(int year) {
    _data.birthYear = year;
    notifyListeners();
  }

  void setTrackingReason(String reason) {
    _data.trackingReason = reason;
    notifyListeners();
  }

  void setPeriodFeeling(String feeling) {
    _data.periodFeeling = feeling;
    notifyListeners();
  }

  void setContraceptiveUse(String use) {
    _data.contraceptiveUse = use;
    notifyListeners();
  }

  void setCycleType(String type) {
    _data.cycleType = type;
    notifyListeners();
  }

  void setMentalHealthAspects(List<String> aspects) {
    _data.mentalHealthAspects = aspects;
    notifyListeners();
  }

  void setSexualImprovement(String improvement) {
    _data.sexualImprovement = improvement;
    notifyListeners();
  }

  void setSexualDesireFluctuation(String fluctuation) {
    _data.sexualDesireFluctuation = fluctuation;
    notifyListeners();
  }

  void setLastPeriodDate(DateTime date) {
    _data.lastPeriodDate = date;
    notifyListeners();
  }

  void setPeriodLength(int days) {
    _data.periodLength = days;
    notifyListeners();
  }

  void setDisplayName(String name) {
    _data.displayName = name;
    notifyListeners();
  }

  /// Persiste datos de onboarding Y marca el flag en el perfil de usuario
  Future<void> submitOnboarding(String uid) async {
    // 1) Guarda los datos de onboarding (colección “onboarding”)
    await _firestore.saveOnboardingData(uid, _data);

    // 2) Marca en users/{uid} que ya completó el onboarding
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'onboardingComplete': true,
    });

    // 3) Actualiza estado local
    _completed = true;
    notifyListeners();
  }
}
