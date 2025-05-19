// lib/providers/cycle_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CycleProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DateTime? lastPeriodDate;
  String cycleType = 'Regular';

  /// Entre inicios de periodos
  int cycleLength = 28;

  /// Duración real del sangrado (días de periodo)
  int periodLength = 5;

  /// Predicciones
  DateTime? nextPeriodDate;
  DateTime? ovulationDate;
  List<DateTime> fertileWindow = [];

  CycleProvider() {
    _listenToUserData();
    _listenToEntries();
  }

  void _listenToUserData() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _db.collection('users').doc(uid).snapshots().listen((snap) {
      if (!snap.exists) return;
      final data = snap.data()!;

      // 1) Leemos la fecha de último periodo DECIDIDA en el Onboarding:
      final tsOnb = data['lastPeriodDate'] as Timestamp?;
      if (tsOnb != null) {
        lastPeriodDate = DateTime(
          tsOnb.toDate().year,
          tsOnb.toDate().month,
          tsOnb.toDate().day,
        );
      }

      // 2) Leemos tipo de ciclo y duración del sangrado
      cycleType = data['cycleType'] as String? ?? cycleType;
      periodLength = data['periodLength'] as int? ?? periodLength;

      // 3) Actualizamos resto de parámetros y notificamos
      _updateCycleLength();
      _computePredictions();
      notifyListeners();
    });
  }

  void _listenToEntries() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _db
        .collection('users')
        .doc(uid)
        .collection('period_entries')
        .orderBy('date', descending: true)
        .limit(1)
        .snapshots()
        .listen((snap) {
          if (snap.docs.isEmpty) return;
          final ts = snap.docs.first.data()['date'] as Timestamp;
          final d = ts.toDate();
          lastPeriodDate = DateTime(d.year, d.month, d.day);
          _computePredictions();
          notifyListeners();
        });
  }

  void _updateCycleLength() {
    switch (cycleType) {
      case 'Irregular':
        cycleLength = 30;
        break;
      case 'Variado':
        cycleLength = 26;
        break;
      default:
        cycleLength = 28;
    }
  }

  void _computePredictions() {
    if (lastPeriodDate == null) {
      nextPeriodDate = null;
      ovulationDate = lastPeriodDate!.add(Duration(days: cycleLength ~/ 2));
      fertileWindow = [];
      return;
    }
    // Aseguramos ciclo actualizado
    _updateCycleLength();

    // Próximo periodo
    nextPeriodDate = lastPeriodDate!.add(Duration(days: cycleLength));
    // Ovulación a mitad de ciclo
    ovulationDate = lastPeriodDate!.add(Duration(days: cycleLength ~/ 2));
    // Ventana fértil: 3 días antes + 2 días después
    fertileWindow = List.generate(6, (i) {
      return ovulationDate!.add(Duration(days: i - 3));
    });
  }

  void setLastPeriodDate(DateTime date) {
    lastPeriodDate = date;
    notifyListeners();
  }
}
