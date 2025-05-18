// lib/screens/onboarding/steps/mental_health_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

class MentalHealthStep extends StatefulWidget {
  const MentalHealthStep({Key? key}) : super(key: key);
  @override
  State<MentalHealthStep> createState() => _MentalHealthStepState();
}

class _MentalHealthStepState extends State<MentalHealthStep> {
  final _opts = ['Estrés', 'Ansiedad', 'Depresión', 'Concentración', 'Sueño'];
  final _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.psychology, size: 64, color: Colors.pinkAccent),
          const SizedBox(height: 16),
          const Text(
            '¿Qué aspectos de tu salud mental quieres mejorar?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            children:
                _opts.map((o) {
                  return FilterChip(
                    label: Text(o),
                    selected: _selected.contains(o),
                    onSelected: (sel) {
                      setState(() {
                        sel ? _selected.add(o) : _selected.remove(o);
                      });
                      context.read<OnboardingProvider>().setMentalHealthAspects(
                        _selected.toList(),
                      );
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
