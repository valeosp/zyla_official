import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyla/widgets/custom_cycle_progress.dart';
import 'package:zyla/providers/cycle_provider.dart';
import 'package:zyla/utils/cycle_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  String _formatDate(DateTime date) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  int _daysUntil(DateTime futureDate) {
    final now = DateTime.now();
    return futureDate.difference(now).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final now = DateTime.now();

    const displayName = 'Usuario';

    int currentDay = 0;
    if (cycle.lastPeriodDate != null) {
      final diff = now.difference(cycle.lastPeriodDate!).inDays;
      currentDay = (diff % cycle.cycleLength) + 1;
    }

    List<PhaseSegment> segments = [];
    String? nextPhase;
    int? nextPhaseDay;

    if (cycle.lastPeriodDate != null) {
      segments = buildCycleSegments(
        cycleLength: cycle.cycleLength,
        lastPeriodDate: cycle.lastPeriodDate!,
        periodLength: cycle.periodLength,
        ovulationDate: cycle.ovulationDate,
        fertileWindow: cycle.fertileWindow,
      );
      nextPhase = getNextPhase(segments, currentDay);
      nextPhaseDay = getNextPhaseDay(segments, currentDay);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Zyla',
          style: TextStyle(
            color: Color(0xFF8E24AA),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Color(0xFF8E24AA)),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola, $displayName!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D1B69),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tu bienestar es nuestra prioridad',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (cycle.lastPeriodDate != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      const Color(0xFF8E24AA).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CustomCycleProgress(
                      cycleLength: cycle.cycleLength,
                      segments: segments,
                      currentDay: currentDay,
                      nextPhase: nextPhase,
                      nextPhaseDay: nextPhaseDay,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Día $currentDay de tu ciclo',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D1B69),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  icon: iconForPhase('periodo'),
                                  title: 'Siguiente período',
                                  value:
                                      cycle.nextPeriodDate != null
                                          ? _formatDate(cycle.nextPeriodDate!)
                                          : 'No calculado',
                                  subtitle:
                                      cycle.nextPeriodDate != null
                                          ? 'En ${_daysUntil(cycle.nextPeriodDate!)} días'
                                          : '',
                                  color: colorForPhase('periodo'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInfoCard(
                                  icon: iconForPhase('ovulación'),
                                  title: 'Ovulación',
                                  value:
                                      cycle.ovulationDate != null
                                          ? _formatDate(cycle.ovulationDate!)
                                          : 'No calculado',
                                  subtitle:
                                      cycle.ovulationDate != null
                                          ? 'En ${_daysUntil(cycle.ovulationDate!)} días'
                                          : '',
                                  color: colorForPhase('ovulación'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8E24AA),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed:
                                  () => Navigator.pushNamed(
                                    context,
                                    '/menstrual/calendar',
                                  ),
                              child: const Text(
                                'Ver calendario completo',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Accesos rápidos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D1B69),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAccessCard(
                          context,
                          icon: Icons.history,
                          title: 'Historial',
                          subtitle: 'Ciclos anteriores',
                          onTap: () => Navigator.pushNamed(context, '/history'),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF64B5F6), Color(0xFF42A5F5)],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickAccessCard(
                          context,
                          icon: Icons.lightbulb_outline,
                          title: 'Consejos',
                          subtitle: 'Bienestar diario',
                          onTap: () => Navigator.pushNamed(context, '/tips'),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFB74D), Color(0xFFFFA726)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 0,
          selectedItemColor: const Color(0xFF8E24AA),
          unselectedItemColor: Colors.grey.shade400,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Calendario',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb_outline),
              activeIcon: Icon(Icons.lightbulb),
              label: 'Consejos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
          onTap: (i) {
            switch (i) {
              case 1:
                Navigator.pushNamed(context, '/menstrual/calendar');
                break;
              case 2:
                Navigator.pushNamed(context, '/tips');
                break;
              case 3:
                Navigator.pushNamed(context, '/profile');
                break;
            }
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D1B69),
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Gradient gradient,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
