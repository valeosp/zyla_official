// lib/screens/onboarding/steps/contraceptive_use_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

class ContraceptiveUseStep extends StatefulWidget {
  const ContraceptiveUseStep({Key? key}) : super(key: key);
  @override
  State<ContraceptiveUseStep> createState() => _ContraceptiveUseStepState();
}

class _ContraceptiveUseStepState extends State<ContraceptiveUseStep> {
  String? _selected;
  final _opts = ['Sí', 'No'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.shield, size: 64, color: Colors.pinkAccent),
          const SizedBox(height: 16),
          const Text(
            '¿Estás usando anticonceptivos?',
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
                context.read<OnboardingProvider>().setContraceptiveUse(v);
              },
            );
          }).toList(),
          const Spacer(),
        ],
      ),
    );
  }
}
