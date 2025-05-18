// lib/screens/onboarding/steps/desire_fluctuation_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

class DesireFluctuationStep extends StatefulWidget {
  const DesireFluctuationStep({Key? key}) : super(key: key);
  @override
  State<DesireFluctuationStep> createState() => _DesireFluctuationStepState();
}

class _DesireFluctuationStepState extends State<DesireFluctuationStep> {
  String? _selected;
  final _opts = ['Sí', 'No'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.waves, size: 64, color: Colors.pinkAccent),
          const SizedBox(height: 16),
          const Text(
            '¿Tu deseo sexual fluctúa en el mes?',
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
                context.read<OnboardingProvider>().setSexualDesireFluctuation(
                  v,
                );
              },
            );
          }).toList(),
          const Spacer(),
        ],
      ),
    );
  }
}
