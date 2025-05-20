// lib/screens/onboarding/steps/period_feeling_step.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

class PeriodFeelingStep extends StatefulWidget {
  const PeriodFeelingStep({Key? key}) : super(key: key);
  @override
  State<PeriodFeelingStep> createState() => _PeriodFeelingStepState();
}

class _PeriodFeelingStepState extends State<PeriodFeelingStep>
    with SingleTickerProviderStateMixin {
  String? _selected;
  final _opts = ['Bien', 'Excelente', 'Mal', 'Irritada', 'Normal'];

  // Color principal para los elementos
  final Color primaryColor = const Color(0xFFFFC6C3);

  // Emojis correspondientes a cada opción
  final Map<String, IconData> _emoji = {
    'Bien': Icons.sentiment_satisfied_rounded,
    'Excelente': Icons.sentiment_very_satisfied_rounded,
    'Mal': Icons.sentiment_dissatisfied_rounded,
    'Irritada': Icons.mood_bad_rounded,
    'Normal': Icons.sentiment_neutral_rounded,
  };

  // Animación para el ícono central
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
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
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Icon(
                    _selected != null
                        ? _emoji[_selected]!
                        : Icons.sentiment_satisfied_rounded,
                    size: 64,
                    color: primaryColor,
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              '¿Cómo te sientes respecto a tu periodo?',
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
              'Selecciona la opción que mejor describa cómo te sientes',
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
                    return _buildFeelingChip(o);
                  }).toList(),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeelingChip(String option) {
    final isSelected = _selected == option;

    return GestureDetector(
      onTap: () {
        setState(() => _selected = option);
        context.read<OnboardingProvider>().setPeriodFeeling(option);
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
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _emoji[option]!,
              size: 20,
              color: isSelected ? Colors.white : primaryColor,
            ),
            const SizedBox(width: 8),
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
