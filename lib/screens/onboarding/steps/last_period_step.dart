// lib/screens/onboarding/steps/last_period_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

class LastPeriodStep extends StatefulWidget {
  const LastPeriodStep({Key? key}) : super(key: key);
  @override
  State<LastPeriodStep> createState() => _LastPeriodStepState();
}

class _LastPeriodStepState extends State<LastPeriodStep> {
  DateTime? _picked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.date_range, size: 64, color: Colors.pinkAccent),
          const SizedBox(height: 16),
          const Text(
            '¿Cuándo fue tu último periodo?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _picked = date);
                context.read<OnboardingProvider>().setLastPeriodDate(date);
              }
            },
            child: Text(
              _picked == null
                  ? 'Seleccionar fecha'
                  : 'Fecha: ${_picked!.day}/${_picked!.month}/${_picked!.year}',
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
