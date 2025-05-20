import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyla/providers/onboarding_provider.dart';

class NameStep extends StatelessWidget {
  const NameStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<OnboardingProvider>();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Cómo prefieres que te llamemos?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Tu nombre',
              border: OutlineInputBorder(),
            ),
            onChanged: prov.setDisplayName,
          ),
        ],
      ),
    );
  }
}
