// lib/screens/onboarding/steps/period_feeling_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

class PeriodFeelingStep extends StatefulWidget {
  const PeriodFeelingStep({Key? key}) : super(key: key);
  @override
  State<PeriodFeelingStep> createState() => _PeriodFeelingStepState();
}

class _PeriodFeelingStepState extends State<PeriodFeelingStep> {
  String? _selected;
  final _opts = ['Bien', 'Excelente', 'Mal', 'Irritada', 'Normal'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.sentiment_satisfied,
            size: 64,
            color: Colors.pinkAccent,
          ),
          const SizedBox(height: 16),
          const Text(
            '¿Cómo te sientes respecto a tu periodo?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            children:
                _opts.map((o) {
                  return ChoiceChip(
                    label: Text(o),
                    selected: _selected == o,
                    onSelected: (_) {
                      setState(() => _selected = o);
                      context.read<OnboardingProvider>().setPeriodFeeling(o);
                    },
                  );
                }).toList(),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
