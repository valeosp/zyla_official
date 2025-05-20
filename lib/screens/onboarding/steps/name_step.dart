// lib/screens/onboarding/steps/name_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

// Definimos los colores para mantener consistencia
const Color zylaMainColor = Color(0xFFFFC6C3);
const Color zylaAccentColor = Color(0xFFFF8A85);
const Color zylaBackgroundColor = Color(0xFFFFF5F5);
const Color zylaTextColor = Color(0xFF4A4A4A);

class NameStep extends StatelessWidget {
  const NameStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<OnboardingProvider>();

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
          // Añadimos un icono decorativo
          Container(
            decoration: BoxDecoration(
              color: zylaMainColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: const Icon(
              Icons.person_rounded,
              size: 64,
              color: zylaAccentColor,
            ),
          ),
          const SizedBox(height: 24),
          // Texto principal con más estilo
          const Text(
            '¡Hola! ¿Cómo prefieres que te llamemos?',
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
            'Tu nombre nos ayuda a personalizar tu experiencia',
            style: TextStyle(
              fontSize: 14,
              color: zylaTextColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Campo de texto con mejor diseño
          TextField(
            decoration: InputDecoration(
              labelText: 'Tu nombre',
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
              prefixIcon: const Icon(Icons.edit, color: zylaAccentColor),
            ),
            style: const TextStyle(fontSize: 16, color: zylaTextColor),
            cursorColor: zylaAccentColor,
            onChanged: prov.setDisplayName,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
