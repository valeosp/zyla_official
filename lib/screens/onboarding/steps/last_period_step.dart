// lib/screens/onboarding/steps/last_period_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

// Definimos los colores para mantener consistencia
const Color zylaMainColor = Color(0xFFFFC6C3);
const Color zylaAccentColor = Color(0xFFFF8A85);
const Color zylaBackgroundColor = Color(0xFFFFF5F5);
const Color zylaTextColor = Color(0xFF4A4A4A);

class LastPeriodStep extends StatefulWidget {
  const LastPeriodStep({Key? key}) : super(key: key);
  @override
  State<LastPeriodStep> createState() => _LastPeriodStepState();
}

class _LastPeriodStepState extends State<LastPeriodStep> {
  DateTime? _picked;

  // Función para formatear la fecha en español
  String _formatDate(DateTime date) {
    // Lista de nombres de meses en español
    final meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    return '${date.day} de ${meses[date.month - 1]} de ${date.year}';
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
          // Icono mejorado con decoración
          Container(
            decoration: BoxDecoration(
              color: zylaMainColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: const Icon(
              Icons.calendar_month_rounded,
              size: 64,
              color: zylaAccentColor,
            ),
          ),
          const SizedBox(height: 24),
          // Texto principal más atractivo
          const Text(
            '¿Cuándo fue tu último periodo?',
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
            'Esta información es esencial para calcular tu ciclo correctamente',
            style: TextStyle(
              fontSize: 14,
              color: zylaTextColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Interfaz para seleccionar fecha mejorada
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: zylaAccentColor,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: zylaTextColor,
                      ),
                      dialogBackgroundColor: Colors.white,
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                setState(() => _picked = date);
                context.read<OnboardingProvider>().setLastPeriodDate(date);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color:
                    _picked != null
                        ? zylaMainColor.withOpacity(0.1)
                        : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _picked != null ? zylaAccentColor : zylaMainColor,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _picked == null
                        ? 'Seleccionar fecha'
                        : _formatDate(_picked!),
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          _picked != null
                              ? zylaAccentColor
                              : zylaTextColor.withOpacity(0.7),
                      fontWeight:
                          _picked != null ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  Icon(
                    Icons.event,
                    color:
                        _picked != null
                            ? zylaAccentColor
                            : zylaTextColor.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ),

          // Representación visual del calendario (opcional, pero da vida a la interfaz)
          if (_picked != null)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: zylaMainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Fecha registrada correctamente',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const Spacer(),
        ],
      ),
    );
  }
}
