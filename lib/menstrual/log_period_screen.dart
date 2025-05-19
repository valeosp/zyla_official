// lib/screens/menstrual/log_period_screen.dart

import 'package:flutter/material.dart';
import 'calendar_screen.dart';

class LogPeriodScreen extends StatelessWidget {
  const LogPeriodScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Redirige directamente al calendario para que el usuario registre su periodo
    return const CalendarScreen();
  }
}
