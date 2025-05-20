// lib/screens/onboarding/steps/mental_health_step.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

class MentalHealthStep extends StatefulWidget {
  const MentalHealthStep({Key? key}) : super(key: key);
  @override
  State<MentalHealthStep> createState() => _MentalHealthStepState();
}

class _MentalHealthStepState extends State<MentalHealthStep>
    with SingleTickerProviderStateMixin {
  final _opts = ['Estrés', 'Ansiedad', 'Depresión', 'Concentración', 'Sueño'];
  final _selected = <String>{};

  // Color principal para los elementos
  final Color primaryColor = const Color(0xFFFFC6C3);

  // Animación para el ícono
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
            // Ícono animado
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withOpacity(0.2),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(
                          0.2 + (_animation.value * 0.2),
                        ),
                        blurRadius: 15,
                        spreadRadius: 2 + (_animation.value * 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Icon(
                    Icons.psychology_rounded,
                    size: 64,
                    color: Color.lerp(
                      primaryColor,
                      Colors.pink.shade300,
                      _animation.value,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              '¿Qué aspectos de tu salud mental quieres mejorar?',
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
              'Selecciona todas las opciones que apliquen',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 16,
              children:
                  _opts.map((o) {
                    return _buildChip(o);
                  }).toList(),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String option) {
    final isSelected = _selected.contains(option);

    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected ? _selected.remove(option) : _selected.add(option);
        });
        context.read<OnboardingProvider>().setMentalHealthAspects(
          _selected.toList(),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check_circle_rounded, size: 20, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Text(
              option,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
