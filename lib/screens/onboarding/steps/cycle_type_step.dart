import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

class CycleTypeStep extends StatefulWidget {
  const CycleTypeStep({Key? key}) : super(key: key);
  @override
  State<CycleTypeStep> createState() => _CycleTypeStepState();
}

class _CycleTypeStepState extends State<CycleTypeStep> {
  String? _selected;
  final _opts = ['Regular', 'Irregular', 'Variado'];

  // Color principal para los elementos
  final Color primaryColor = const Color(0xFFFFC6C3);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, primaryColor.withOpacity(0.2)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Icon(Icons.repeat_rounded, size: 64, color: primaryColor),
            ),
            const SizedBox(height: 32),
            Text(
              '¿Cómo es tu ciclo menstrual?',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Esta información nos ayuda a personalizar tu experiencia',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ..._opts.map((o) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOptionCard(o),
              );
            }).toList(),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(String option) {
    final isSelected = _selected == option;

    return GestureDetector(
      onTap: () {
        setState(() => _selected = option);
        context.read<OnboardingProvider>().setCycleType(option);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? primaryColor : Colors.white,
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child:
                  isSelected
                      ? Center(
                        child: Icon(Icons.check, size: 16, color: Colors.white),
                      )
                      : null,
            ),
            const SizedBox(width: 16),
            Text(
              option,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? primaryColor.withRed(220) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
