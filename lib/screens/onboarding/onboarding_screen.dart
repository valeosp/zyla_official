// Pantalla principal del flujo de onboarding (registro inicial) de la app.
// lib/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboarding_provider.dart';

// Importa los widgets de cada paso del onboarding (sin Scaffold propio).
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
import 'steps/name_step.dart';

// Widget principal de la pantalla de onboarding.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

// Estado de la pantalla de onboarding.
class _OnboardingScreenState extends State<OnboardingScreen> {
  // Controlador para manejar el cambio de páginas.
  final _pageController = PageController();
  // Índice de la página actual.
  int _currentPage = 0;

  // Lista de los widgets de cada paso del onboarding.
  final _pages = const [
    NameStep(),
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

  // Lista de validadores para cada paso, usando el provider.
  late final List<bool Function(OnboardingProvider)> _validators = [
    (prov) => prov.data.displayName != null,
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

  // Función para avanzar a la siguiente página o finalizar el onboarding.
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      // Si no es la última página, avanza a la siguiente.
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Si es la última página, envía los datos y navega al home.
      final uid = context.read<AuthProvider>().user!.uid;
      context.read<OnboardingProvider>().submitOnboarding(uid).then((_) {
        Navigator.of(context).pushReplacementNamed('/home');
      });
    }
  }

  // Función para retroceder a la página anterior.
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
    // Obtiene el provider de onboarding para acceder a los datos.
    final provider = context.watch<OnboardingProvider>();
    // Determina si se puede avanzar al siguiente paso.
    final canGoNext = _validators[_currentPage](provider);

    return Scaffold(
      // Barra superior con el título y botón de retroceso si no es la primera página.
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
      // Cuerpo principal: PageView para mostrar los pasos, sin scroll manual.
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: _pages,
      ),
      // Botón inferior para avanzar o finalizar, solo habilitado si el paso es válido.
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
