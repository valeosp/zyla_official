// lib/screens/onboarding/steps/cycle_type_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

class CycleTypeStep extends StatefulWidget {
  const CycleTypeStep({Key? key}) : super(key: key);
  @override
  State<CycleTypeStep> createState() => _CycleTypeStepState();
}

class _CycleTypeStepState extends State<CycleTypeStep> {
  String? _selected;
  final _opts = ['Regular', 'Irregular', 'Variado'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.repeat, size: 64, color: Colors.pinkAccent),
          const SizedBox(height: 16),
          const Text(
            '¿Cómo es tu ciclo menstrual?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ..._opts.map((o) {
            return RadioListTile<String>(
              title: Text(o),
              value: o,
              groupValue: _selected,
              onChanged: (v) {
                if (v == null) return;
                setState(() => _selected = v);
                context.read<OnboardingProvider>().setCycleType(v);
              },
            );
          }).toList(),
          const Spacer(),
        ],
      ),
    );
  }
}
