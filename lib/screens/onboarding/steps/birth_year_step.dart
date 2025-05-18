// lib/screens/onboarding/steps/birth_year_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

class BirthYearStep extends StatefulWidget {
  const BirthYearStep({Key? key}) : super(key: key);

  @override
  State<BirthYearStep> createState() => _BirthYearStepState();
}

class _BirthYearStepState extends State<BirthYearStep> {
  int? _selectedYear;
  late final List<int> _years;

  @override
  void initState() {
    super.initState();
    final current = DateTime.now().year;
    _years = List.generate(50, (i) => current - i);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.calendar_today, size: 64, color: Colors.pinkAccent),
          const SizedBox(height: 16),
          const Text(
            '¿En qué año naciste?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Aquí guardamos en el provider en cuanto cambia:
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'Año',
              border: OutlineInputBorder(),
            ),
            items:
                _years
                    .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                    .toList(),
            value: _selectedYear,
            onChanged: (year) {
              if (year == null) return;
              setState(() => _selectedYear = year);

              // <-- guardo inmediatamente en el provider:
              context.read<OnboardingProvider>().setBirthYear(year);
            },
          ),

          // El Spacer empuja todo hacia arriba para que el botón global quede abajo
          const Spacer(),
        ],
      ),
    );
  }
}
