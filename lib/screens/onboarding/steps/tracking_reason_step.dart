// lib/screens/onboarding/steps/tracking_reason_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

class TrackingReasonStep extends StatefulWidget {
  const TrackingReasonStep({Key? key}) : super(key: key);
  @override
  State<TrackingReasonStep> createState() => _TrackingReasonStepState();
}

class _TrackingReasonStepState extends State<TrackingReasonStep> {
  String? _selected;
  final _opts = [
    'Salud',
    'Planificación familiar',
    'Bienestar personal',
    'Otro',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.help_outline, size: 64, color: Colors.pinkAccent),
          const SizedBox(height: 16),
          const Text(
            '¿Por qué sigues tu ciclo?',
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
                context.read<OnboardingProvider>().setTrackingReason(v);
              },
            );
          }).toList(),
          const Spacer(),
        ],
      ),
    );
  }
}
