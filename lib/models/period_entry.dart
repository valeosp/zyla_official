// lib/models/period_entry.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PeriodEntry {
  String? id;

  /// Solo fecha (año, mes, día) sin componente horario para evitar desfases
  DateTime date;
  String flow;
  List<String> mood;
  List<String> symptoms;
  List<String> sexualActivity;

  PeriodEntry({
    this.id,
    required this.date,
    required this.flow,
    required this.mood,
    required this.symptoms,
    required this.sexualActivity,
  });

  /// Construye desde datos de Firestore normalizando la fecha
  factory PeriodEntry.fromMap(String id, Map<String, dynamic> data) {
    final ts = data['date'] as Timestamp;
    final dt = ts.toDate();
    // Normalizar para evitar desfase de zona horaria
    final normalizedDate = DateTime(dt.year, dt.month, dt.day);
    return PeriodEntry(
      id: id,
      date: normalizedDate,
      flow: data['flow'] as String,
      mood: List<String>.from(data['mood'] ?? []),
      symptoms: List<String>.from(data['symptoms'] ?? []),
      sexualActivity: List<String>.from(data['sexualActivity'] ?? []),
    );
  }

  /// Convierte a mapa para Firestore, guardando solo fecha
  Map<String, dynamic> toMap() {
    final d = date;
    final normalized = DateTime(d.year, d.month, d.day);
    return {
      'date': Timestamp.fromDate(normalized),
      'flow': flow,
      'mood': mood,
      'symptoms': symptoms,
      'sexualActivity': sexualActivity,
    };
  }
}
