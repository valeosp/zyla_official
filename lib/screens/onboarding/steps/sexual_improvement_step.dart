// lib/screens/onboarding/steps/sexual_improvement_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

class SexualImprovementStep extends StatefulWidget {
  const SexualImprovementStep({Key? key}) : super(key: key);
  @override
  State<SexualImprovementStep> createState() => _SexualImprovementStepState();
}

class _SexualImprovementStepState extends State<SexualImprovementStep> {
  String? _selected;
  final _opts = ['Comunicación', 'Deseo', 'Placer', 'Otro'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.favorite, size: 64, color: Colors.pinkAccent),
          const SizedBox(height: 16),
          const Text(
            '¿Qué quieres mejorar en el sexo?',
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
                context.read<OnboardingProvider>().setSexualImprovement(v);
              },
            );
          }).toList(),
          const Spacer(),
        ],
      ),
    );
  }
}
