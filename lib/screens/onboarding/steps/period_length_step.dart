// lib/screens/onboarding/steps/period_length_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

class PeriodLengthStep extends StatelessWidget {
  const PeriodLengthStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<OnboardingProvider>();
    final selected = prov.data.periodLength ?? 5;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.av_timer, size: 64, color: Colors.pinkAccent),
          const SizedBox(height: 16),
          const Text(
            '¿Cuántos días dura tu periodo normalmente?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<int>(
            value: selected,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items:
                List.generate(8, (i) => i + 3)
                    .map(
                      (d) => DropdownMenuItem(value: d, child: Text('$d días')),
                    )
                    .toList(),
            onChanged: (v) {
              if (v != null) prov.setPeriodLength(v);
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
