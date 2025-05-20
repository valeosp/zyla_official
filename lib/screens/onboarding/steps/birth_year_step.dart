// lib/screens/onboarding/steps/birth_year_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

// Definimos los colores para mantener consistencia
const Color zylaMainColor = Color(0xFFFFC6C3);
const Color zylaAccentColor = Color(0xFFFF8A85);
const Color zylaBackgroundColor = Color(0xFFFFF5F5);
const Color zylaTextColor = Color(0xFF4A4A4A);

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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icono animado y decorativo
          Container(
            decoration: BoxDecoration(
              color: zylaMainColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: const Icon(
              Icons.calendar_today_rounded,
              size: 64,
              color: zylaAccentColor,
            ),
          ),
          const SizedBox(height: 24),
          // Texto principal más estilizado
          Text(
            '¿En qué año naciste?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: zylaTextColor,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Esto nos ayudará a personalizar tu experiencia',
            style: TextStyle(
              fontSize: 14,
              color: zylaTextColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Dropdown estilizado
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: 'Selecciona tu año de nacimiento',
              labelStyle: TextStyle(color: zylaTextColor.withOpacity(0.8)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: zylaMainColor, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: zylaMainColor, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: zylaAccentColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            icon: const Icon(
              Icons.arrow_drop_down_circle_outlined,
              color: zylaAccentColor,
            ),
            items:
                _years
                    .map(
                      (y) => DropdownMenuItem(
                        value: y,
                        child: Text(
                          '$y',
                          style: const TextStyle(
                            fontSize: 16,
                            color: zylaTextColor,
                          ),
                        ),
                      ),
                    )
                    .toList(),
            value: _selectedYear,
            onChanged: (year) {
              if (year == null) return;
              setState(() => _selectedYear = year);

              // <-- guardo inmediatamente en el provider:
              context.read<OnboardingProvider>().setBirthYear(year);
            },
            dropdownColor: Colors.white,
          ),

          // El Spacer empuja todo hacia arriba para que el botón global quede abajo
          const Spacer(),
        ],
      ),
    );
  }
}
