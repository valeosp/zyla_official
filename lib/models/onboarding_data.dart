// lib/models/onboarding_data.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class OnboardingData {
  String? displayName;
  int? birthYear;
  String? trackingReason;
  String? periodFeeling;
  String? contraceptiveUse;
  String? cycleType;
  List<String>? mentalHealthAspects;
  String? sexualImprovement;
  String? sexualDesireFluctuation;
  DateTime? lastPeriodDate;

  // ← NUEVO: duración del periodo en días
  int? periodLength;

  OnboardingData({
    this.displayName,
    this.birthYear,
    this.trackingReason,
    this.periodFeeling,
    this.contraceptiveUse,
    this.cycleType,
    this.mentalHealthAspects,
    this.sexualImprovement,
    this.sexualDesireFluctuation,
    this.lastPeriodDate,
    this.periodLength,
  });

  /// Convierte los datos en un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'birthYear': birthYear,
      'trackingReason': trackingReason,
      'periodFeeling': periodFeeling,
      'contraceptiveUse': contraceptiveUse,
      'cycleType': cycleType,
      'mentalHealthAspects': mentalHealthAspects,
      'sexualImprovement': sexualImprovement,
      'sexualDesireFluctuation': sexualDesireFluctuation,
      'lastPeriodDate':
          lastPeriodDate != null ? Timestamp.fromDate(lastPeriodDate!) : null,
      'periodLength': periodLength, // ← guardamos aquí
    };
  }

  /// Crea una instancia a partir de un mapa de Firestore
  factory OnboardingData.fromMap(Map<String, dynamic> map) {
    return OnboardingData(
      displayName: map['displayName'] as String?,
      birthYear: map['birthYear'] as int?,
      trackingReason: map['trackingReason'] as String?,
      periodFeeling: map['periodFeeling'] as String?,
      contraceptiveUse: map['contraceptiveUse'] as String?,
      cycleType: map['cycleType'] as String?,
      mentalHealthAspects: List<String>.from(map['mentalHealthAspects'] ?? []),
      sexualImprovement: map['sexualImprovement'] as String?,
      sexualDesireFluctuation: map['sexualDesireFluctuation'] as String?,
      lastPeriodDate: (map['lastPeriodDate'] as Timestamp?)?.toDate(),
      periodLength: map['periodLength'] as int?, // ← leemos aquí
    );
  }
}
