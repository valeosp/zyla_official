// lib/utils/cycle_utils.dart

import 'package:flutter/material.dart';

Color colorForPhase(String phase) {
  switch (phase) {
    case 'periodo':
      return const Color(0xFFE91E63);
    case 'ovulación':
      return const Color(0xFF8E24AA);
    case 'fértil':
      return const Color.fromARGB(255, 119, 232, 255);
    case 'folicular':
    default:
      return const Color.fromARGB(190, 255, 208, 40);
  }
}

String displayNameForPhase(String phase) {
  switch (phase) {
    case 'periodo':
      return 'Período';
    case 'ovulación':
      return 'Ovulación';
    case 'fértil':
      return 'Días fértiles';
    case 'folicular':
    default:
      return 'Fase folicular';
  }
}

IconData iconForPhase(String phase) {
  switch (phase) {
    case 'periodo':
      return Icons.water_drop;
    case 'ovulación':
      return Icons.favorite;
    case 'fértil':
      return Icons.eco;
    case 'folicular':
    default:
      return Icons.brightness_2;
  }
}

/// Calcula el día actual del ciclo dado el último periodo
int calculateCurrentDay(DateTime lastPeriodDate) {
  final today = DateTime.now();
  final normalizedLast = DateTime(
    lastPeriodDate.year,
    lastPeriodDate.month,
    lastPeriodDate.day,
  );
  final diff = today.difference(normalizedLast).inDays + 1;
  return diff < 1 ? 1 : diff;
}
