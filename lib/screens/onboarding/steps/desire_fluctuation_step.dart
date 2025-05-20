// lib/screens/onboarding/steps/desire_fluctuation_step.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

class DesireFluctuationStep extends StatefulWidget {
  const DesireFluctuationStep({Key? key}) : super(key: key);
  @override
  State<DesireFluctuationStep> createState() => _DesireFluctuationStepState();
}

class _DesireFluctuationStepState extends State<DesireFluctuationStep>
    with SingleTickerProviderStateMixin {
  String? _selected;
  final _opts = ['Sí', 'No'];

  // Color principal para los elementos
  final Color primaryColor = const Color(0xFFFFC6C3);

  // Animación para las ondas
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 10).animate(_controller);
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
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 15 + _animation.value,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Icon(
                    Icons.waves_rounded,
                    size: 64,
                    color: primaryColor,
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              '¿Tu deseo sexual fluctúa en el mes?',
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
              'Esto nos ayuda a entender mejor tu ciclo hormonal',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  _opts.map((o) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _buildChoiceButton(o),
                      ),
                    );
                  }).toList(),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceButton(String option) {
    final isSelected = _selected == option;

    return GestureDetector(
      onTap: () {
        setState(() => _selected = option);
        context.read<OnboardingProvider>().setSexualDesireFluctuation(option);
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
                      color: primaryColor.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(0, 5),
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
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Center(
          child: Text(
            option,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
