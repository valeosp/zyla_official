import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:zyla/widgets/custom_cycle_progress.dart';
import 'package:zyla/providers/cycle_provider.dart';
import 'package:zyla/utils/cycle_utils.dart';
import 'package:zyla/services/firestore_service.dart';
import 'package:zyla/models/tip.dart';
import 'package:zyla/providers/user_data_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // Para mostrar los emojis y colores de categoría en el modal
  static const Map<String, String> _categoryEmojis = {
    'Todas': '🌈',
    'psicológica': '🧠',
    'sexualidad': '❤️‍🔥',
    'salud íntima': '🌸',
  };

  // Nuevos colores pasteles
  static const Map<String, Color> _categoryColors = {
    'Todas': Color(0xFFFCE4EC),
    'psicológica': Color(0xFFE1F5FE),
    'sexualidad': Color(0xFFFFF8E1),
    'salud íntima': Color(0xFFE8F5E9),
  };

  static const Map<String, Color> _selectedCategoryColors = {
    'Todas': Color(0xFFF48FB1),
    'psicológica': Color(0xFF81D4FA),
    'sexualidad': Color(0xFFFFCC80),
    'salud íntima': Color(0xFFA5D6A7),
  };

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
    final firestoreService = FirestoreService();
    final now = DateTime.now();

    final name = context.watch<UserDataProvider>().displayName;

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

    // Colores principales de la app renovados
    final Color primaryColor = const Color.fromARGB(255, 235, 164, 178);
    final Color secondaryColor = const Color(0xFFD0B1FA);
    final Color accentColor = const Color(0xFFF8BBD0);
    final Color backgroundColor = const Color(0xFFF5F0FF);
    final Color textColor = const Color(0xFF5D4777);

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: true,
      body: Stack(
        children: [
          // Fondo con gradient suave
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [backgroundColor, const Color(0xFFE3F2FD)],
              ),
            ),
          ),

          // Decoración de burbujas/círculos en el fondo
          Positioned(
            top: -50,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withOpacity(0.1),
              ),
            ),
          ),

          Positioned(
            top: 100,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: secondaryColor.withOpacity(0.07),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // AppBar Personalizado
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  floating: true,
                  expandedHeight: 0,
                  automaticallyImplyLeading: false,
                  flexibleSpace: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/images/logo.png', // Tu logo
                          height: 32,
                          errorBuilder:
                              (_, __, ___) => Text(
                                'Zyla',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                        ),
                        Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color.fromARGB(255, 255, 236, 236),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.person_outline,
                                  color: primaryColor,
                                ),
                                onPressed:
                                    () => Navigator.pushNamed(
                                      context,
                                      '/profile',
                                    ),
                              ),
                            )
                            .animate()
                            .fade(duration: 400.ms)
                            .scale(
                              begin: const Offset(0.9, 0.9),
                              end: const Offset(1, 1),
                              duration: 400.ms,
                            ),
                      ],
                    ),
                  ),
                ),

                // Contenido principal
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Saludo
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                  '¡Hola, $name!',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                    letterSpacing: -0.5,
                                  ),
                                )
                                .animate()
                                .fade(duration: 500.ms)
                                .slideY(
                                  begin: 0.2,
                                  end: 0,
                                  duration: 500.ms,
                                  curve: Curves.easeOutQuint,
                                ),
                            const SizedBox(height: 4),
                            Text(
                                  'Tu bienestar es nuestra prioridad',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: textColor.withOpacity(0.7),
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                                .animate(delay: 150.ms)
                                .fade(duration: 500.ms)
                                .slideY(
                                  begin: 0.2,
                                  end: 0,
                                  duration: 500.ms,
                                  curve: Curves.easeOutQuint,
                                ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Módulo de ciclo (si aplica)
                        if (cycle.lastPeriodDate != null) ...[
                          Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color.fromARGB(0, 255, 255, 255),
                                      primaryColor.withOpacity(0.08),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.08),
                                      blurRadius: 10,
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
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFFF5F0FF),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Día $currentDay de tu ciclo',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildInfoCard(
                                                  icon: iconForPhase('periodo'),
                                                  title: 'Siguiente período',
                                                  value:
                                                      cycle.nextPeriodDate !=
                                                              null
                                                          ? _formatDate(
                                                            cycle
                                                                .nextPeriodDate!,
                                                          )
                                                          : 'No calculado',
                                                  subtitle:
                                                      cycle.nextPeriodDate !=
                                                              null
                                                          ? 'En ${_daysUntil(cycle.nextPeriodDate!)} días'
                                                          : '',
                                                  color: accentColor,
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: _buildInfoCard(
                                                  icon: iconForPhase(
                                                    'ovulación',
                                                  ),
                                                  title: 'Ovulación',
                                                  value:
                                                      cycle.ovulationDate !=
                                                              null
                                                          ? _formatDate(
                                                            cycle
                                                                .ovulationDate!,
                                                          )
                                                          : 'No calculado',
                                                  subtitle:
                                                      cycle.ovulationDate !=
                                                              null
                                                          ? 'En ${_daysUntil(cycle.ovulationDate!)} días'
                                                          : '',
                                                  color: secondaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 18),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        primaryColor,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 16,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                    ),
                                                    elevation: 0,
                                                  ),
                                                  onPressed:
                                                      () => Navigator.pushNamed(
                                                        context,
                                                        '/menstrual/calendar',
                                                      ),
                                                  child: const Text(
                                                    'Registrar Periodo',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                )
                                                .animate(
                                                  onPlay:
                                                      (controller) =>
                                                          controller.forward(),
                                                  onComplete:
                                                      (controller) =>
                                                          controller.reset(),
                                                )
                                                .scaleXY(
                                                  end: 0.95,
                                                  duration: 100.ms,
                                                )
                                                .then(duration: 100.ms)
                                                .scaleXY(end: 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .animate()
                              .fade(duration: 600.ms)
                              .slideY(
                                begin: 0.2,
                                end: 0,
                                duration: 600.ms,
                                curve: Curves.easeOutQuint,
                              ),
                          const SizedBox(height: 32),
                        ],

                        // Tus Consejos Diarios
                        Row(
                              children: [
                                Text(
                                  'Mis Consejos Diarios',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.auto_awesome,
                                  size: 18,
                                  color: accentColor,
                                ),
                              ],
                            )
                            .animate(delay: 200.ms)
                            .fade(duration: 500.ms)
                            .slideY(begin: 0.2, end: 0, duration: 500.ms),
                        const SizedBox(height: 16),

                        // Consejos con StreamBuilder
                        SizedBox(
                          height: 210,
                          child: StreamBuilder<List<Tip>>(
                            stream: firestoreService.streamTips(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                      primaryColor,
                                    ),
                                  ),
                                );
                              }
                              if (snapshot.hasError) {
                                return const Center(
                                  child: Text('Error al cargar consejos'),
                                );
                              }
                              final tips = (snapshot.data ?? [])..shuffle();
                              final displayTips = tips.take(6).toList();
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: displayTips.length,
                                itemBuilder: (context, index) {
                                  final tip = displayTips[index];
                                  return GestureDetector(
                                    onTap: () => _showTipDetails(context, tip),
                                    child: Container(
                                          width: 150,
                                          margin: EdgeInsets.only(
                                            right:
                                                index < displayTips.length - 1
                                                    ? 16
                                                    : 0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.04,
                                                ),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.vertical(
                                                        top: Radius.circular(
                                                          20,
                                                        ),
                                                      ),
                                                  child: Image.network(
                                                    tip.imageUrl,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          _,
                                                          __,
                                                          ___,
                                                        ) => Container(
                                                          color: const Color(
                                                            0xFFF0F0F0,
                                                          ),
                                                          child: Icon(
                                                            Icons
                                                                .lightbulb_outline_rounded,
                                                            size: 40,
                                                            color: accentColor,
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                child: Text(
                                                  tip.title,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: textColor,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                        .animate(
                                          delay: 200.ms + (index * 50).ms,
                                        )
                                        .fade()
                                        .scale(
                                          begin: const Offset(0.9, 0.9),
                                          end: const Offset(1, 1),
                                        ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Accesos rápidos (con nuevo diseño)
                        Row(
                              children: [
                                Text(
                                  'Accesos rápidos',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.touch_app,
                                  size: 18,
                                  color: secondaryColor,
                                ),
                              ],
                            )
                            .animate(delay: 300.ms)
                            .fade(duration: 500.ms)
                            .slideY(begin: 0.2, end: 0, duration: 500.ms),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickAccessCard(
                                context,
                                icon: Icons.history,
                                title: 'Historial',
                                subtitle: 'Ciclos anteriores',
                                onTap:
                                    () => Navigator.pushNamed(
                                      context,
                                      '/history',
                                    ),
                                gradient: LinearGradient(
                                  colors: [
                                    secondaryColor,
                                    secondaryColor.withBlue(230),
                                  ],
                                ),
                                index: 0,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildQuickAccessCard(
                                context,
                                icon: Icons.lightbulb_outline,
                                title: 'Consejos',
                                subtitle: 'Bienestar diario',
                                onTap:
                                    () => Navigator.pushNamed(context, '/tips'),
                                gradient: LinearGradient(
                                  colors: [
                                    accentColor,
                                    accentColor.withRed(250),
                                  ],
                                ),
                                index: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar con diseño mejorado
      bottomNavigationBar: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: 0,
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.grey.shade400,
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.home, color: primaryColor),
                ),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.calendar_today_outlined),
                activeIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.calendar_today, color: primaryColor),
                ),
                label: 'Calendario',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.lightbulb_outline),
                activeIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lightbulb, color: primaryColor),
                ),
                label: 'Consejos',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: primaryColor),
                ),
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
      ).animate().fade(duration: 800.ms).slideY(begin: 0.3, end: 0),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
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
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4777),
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 3),
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
    required int index,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 14),
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
          )
          .animate(delay: 350.ms + (index * 100).ms)
          .fade()
          .slideX(
            begin: index.isEven ? -0.1 : 0.1,
            end: 0,
            duration: 600.ms,
            curve: Curves.easeOutQuint,
          ),
    );
  }

  void _showTipDetails(BuildContext context, Tip tip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.7,
                minChildSize: 0.5,
                maxChildSize: 0.95,
                builder: (_, scrollController) {
                  return SingleChildScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              width: 50,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Text(
                            tip.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  _categoryColors[tip.category] ??
                                  Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: (_selectedCategoryColors[tip.category] ??
                                        Colors.grey)
                                    .withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _categoryEmojis[tip.category] ?? '💡',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  tip.category,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        _selectedCategoryColors[tip.category] ??
                                        Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              tip.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200,
                              errorBuilder:
                                  (_, __, ___) => Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F0F0),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.lightbulb_outline_rounded,
                                        size: 60,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            tip.description,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: Color(0xFF424242),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
            .animate()
            .fade(duration: 300.ms)
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1, 1),
              duration: 350.ms,
              curve: Curves.easeOutQuint,
            );
      },
    );
  }
}
