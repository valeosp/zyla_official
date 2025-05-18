// lib/providers/onboarding_provider.dart

import 'package:flutter/material.dart';
import '../models/onboarding_data.dart';
import '../services/firestore_service.dart';

class OnboardingProvider with ChangeNotifier {
  final OnboardingData _data = OnboardingData();
  final FirestoreService _firestore = FirestoreService();
  OnboardingData get data => _data;

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

  // ← NUEVO: setter para duración de periodo
  void setPeriodLength(int days) {
    _data.periodLength = days;
    notifyListeners();
  }

  /// Llama a FirestoreService para persistir el Onboarding
  Future<void> submitOnboarding(String uid) async {
    await _firestore.saveOnboardingData(uid, _data);
  }
}
