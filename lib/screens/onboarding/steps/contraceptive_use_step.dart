// lib/screens/onboarding/steps/contraceptive_use_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

// Definimos los colores para mantener consistencia
const Color zylaMainColor = Color(0xFFFFC6C3);
const Color zylaAccentColor = Color(0xFFFF8A85);
const Color zylaBackgroundColor = Color(0xFFFFF5F5);
const Color zylaTextColor = Color(0xFF4A4A4A);

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
          // Icono mejorado y decorativo
          Container(
            decoration: BoxDecoration(
              color: zylaMainColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: const Icon(
              Icons.health_and_safety_rounded,
              size: 64,
              color: zylaAccentColor,
            ),
          ),
          const SizedBox(height: 24),
          // Texto principal más atractivo
          const Text(
            '¿Estás usando anticonceptivos?',
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
            'Tu respuesta nos ayuda a personalizar el seguimiento de tu ciclo',
            style: TextStyle(
              fontSize: 14,
              color: zylaTextColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Opciones de selección mejoradas
          Row(
            children:
                _opts.map((o) {
                  final isSelected = _selected == o;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selected = o);
                        context.read<OnboardingProvider>().setContraceptiveUse(
                          o,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: isSelected ? zylaAccentColor : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? zylaAccentColor : zylaMainColor,
                            width: 2,
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: zylaAccentColor.withOpacity(0.2),
                                      blurRadius: 10,
                                      spreadRadius: 0,
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Center(
                          child: Text(
                            o,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              color: isSelected ? Colors.white : zylaTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
