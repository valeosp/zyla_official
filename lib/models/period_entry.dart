// lib/models/period_entry.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PeriodEntry {
  String? id;

  /// Fecha normalizada (sin hora) para evitar desfases de zona horaria
  final DateTime date;

  /// Flujo menstrual: "Ligero", "Normal", "Abundante"
  final String flow;

  /// Estado de ánimo seleccionado(s)
  final List<String> mood;

  /// Síntomas seleccionados
  final List<String> symptoms;

  /// Actividad sexual registrada
  final List<String> sexualActivity;

  PeriodEntry({
    this.id,
    required this.date,
    required this.flow,
    required this.mood,
    required this.symptoms,
    required this.sexualActivity,
  });

  /// Construye una instancia desde Firestore
  factory PeriodEntry.fromMap(String id, Map<String, dynamic> data) {
    final Timestamp ts = data['date'];
    final dt = ts.toDate();
    final normalizedDate = DateTime(dt.year, dt.month, dt.day);

    return PeriodEntry(
      id: id,
      date: normalizedDate,
      flow: data['flow'] as String? ?? 'Normal',
      mood: List<String>.from(data['mood'] ?? []),
      symptoms: List<String>.from(data['symptoms'] ?? []),
      sexualActivity: List<String>.from(data['sexualActivity'] ?? []),
    );
  }

  /// Convierte la entrada a un mapa compatible con Firestore
  Map<String, dynamic> toMap() {
    final normalized = DateTime(date.year, date.month, date.day);
    return {
      'date': Timestamp.fromDate(normalized),
      'flow': flow,
      'mood': mood,
      'symptoms': symptoms,
      'sexualActivity': sexualActivity,
    };
  }
}
