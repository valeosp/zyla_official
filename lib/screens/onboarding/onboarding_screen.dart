// lib/screens/onboarding/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboarding_provider.dart';

// Tus widgets de contenido (sin Scaffold ni navegación propia):
import 'steps/birth_year_step.dart';
import 'steps/tracking_reason_step.dart';
import 'steps/period_feeling_step.dart';
import 'steps/contraceptive_use_step.dart';
import 'steps/cycle_type_step.dart';
import 'steps/mental_health_step.dart';
import 'steps/sexual_improvement_step.dart';
import 'steps/desire_fluctuation_step.dart';
import 'steps/last_period_step.dart';
import 'steps/period_length_step.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Las 10 "steps" de tu flujo:
  final _pages = const [
    BirthYearStep(),
    TrackingReasonStep(),
    PeriodFeelingStep(),
    ContraceptiveUseStep(),
    CycleTypeStep(),
    MentalHealthStep(),
    SexualImprovementStep(),
    DesireFluctuationStep(),
    LastPeriodStep(),
    PeriodLengthStep(),
  ];

  // Validadores: cada uno comprueba que el provider ya tenga el valor.
  late final List<bool Function(OnboardingProvider)> _validators = [
    (prov) => prov.data.birthYear != null,
    (prov) => prov.data.trackingReason != null,
    (prov) => prov.data.periodFeeling != null,
    (prov) => prov.data.contraceptiveUse != null,
    (prov) => prov.data.cycleType != null,
    (prov) => (prov.data.mentalHealthAspects?.isNotEmpty ?? false),
    (prov) => prov.data.sexualImprovement != null,
    (prov) => prov.data.sexualDesireFluctuation != null,
    (prov) => prov.data.lastPeriodDate != null,
    (prov) => prov.data.periodLength != null,
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final uid = context.read<AuthProvider>().user!.uid;
      context.read<OnboardingProvider>().submitOnboarding(uid).then((_) {
        Navigator.of(context).pushReplacementNamed('/home');
      });
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    final canGoNext = _validators[_currentPage](provider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Paso ${_currentPage + 1} de ${_pages.length}'),
        leading:
            _currentPage > 0
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _prevPage,
                )
                : null,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: ElevatedButton(
            onPressed: canGoNext ? _nextPage : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _currentPage < _pages.length - 1 ? 'Siguiente' : 'Finalizar',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
