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

// Define el color principal rosa para toda la aplicación
const Color zylaMainColor = Color(0xFFFFC6C3);
const Color zylaAccentColor = Color(0xFFFF8A85);
const Color zylaBackgroundColor = Color(0xFFFFF5F5);
const Color zylaTextColor = Color(0xFF4A4A4A);

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
      backgroundColor: zylaBackgroundColor,
      // Barra superior elegante con indicador de progreso
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading:
            _currentPage > 0
                ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: zylaAccentColor,
                  ),
                  onPressed: _prevPage,
                )
                : null,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '${_currentPage + 1}/${_pages.length}',
                style: const TextStyle(
                  color: zylaTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      // Indicador de progreso visual en la parte superior
      body: Column(
        children: [
          // Indicador de progreso lineal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / _pages.length,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(zylaAccentColor),
              minHeight: 4,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          // PageView para mostrar los pasos, sin scroll manual.
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: _pages,
            ),
          ),
        ],
      ),
      // Botón inferior para avanzar o finalizar, solo habilitado si el paso es válido.
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ElevatedButton(
            onPressed: canGoNext ? _nextPage : null,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: zylaAccentColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              shadowColor: zylaAccentColor.withOpacity(0.5),
              disabledBackgroundColor: zylaMainColor.withOpacity(0.5),
            ),
            child: Text(
              _currentPage < _pages.length - 1 ? 'Siguiente' : 'Finalizar',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
