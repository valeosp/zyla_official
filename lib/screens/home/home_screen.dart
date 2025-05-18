import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:menstrual_cycle_widget/menstrual_cycle_widget.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cycle_provider.dart';
import 'package:zyla/menstrual/calendar_view_screen.dart';
import '../history/history_screen.dart';
import '../tips/tips_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cycleProv = context.watch<CycleProvider>();
    final now = DateTime.now();

    // Saludo
    final rawEmail = auth.user?.email ?? '';
    final namePart = rawEmail.split('@').first;
    final displayName =
        namePart.isNotEmpty
            ? '${namePart[0].toUpperCase()}${namePart.substring(1)}'
            : '¡Hola!';

    // Día actual de ciclo (para mostrar texto)
    int currentDay = 0;
    if (cycleProv.lastPeriodDate != null) {
      final diff = now.difference(cycleProv.lastPeriodDate!).inDays;
      currentDay = (diff % cycleProv.cycleLength) + 1;
    }

    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text('Zyla'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          // -- Saludo --
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '¡Hola, $displayName!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent.shade700,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // -- Tarjeta de ciclo + gráfico automático --
          if (cycleProv.lastPeriodDate != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Gráfico de fases MANUAL ⇢ pero dejando que el widget calcule internamente
                      MenstrualCyclePhaseView(
                        size: 200, // ≥ 200
                        theme: MenstrualCycleTheme.arcs,
                        phaseTextBoundaries: PhaseTextBoundaries.outside,
                        isRemoveBackgroundPhaseColor: true,
                        viewType: MenstrualCycleViewType.circleText,
                        isAutoSetData: true, // aquí activamos las preds.
                      ),

                      const SizedBox(height: 16),

                      // Texto predictivo
                      Text(
                        'Día $currentDay de tu ciclo',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Ya se calcula y se muestra la fecha dentro del propio widget,
                      // pero si quieres repetirla aquí deberías
                      // pasar cycleProv.nextPeriodDate y cycleProv.ovulationDate
                      // tras calcularlas tú mismo.
                      const SizedBox(height: 16),

                      // Botón degradado: lleva al calendario de registro
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.pinkAccent, Colors.pink],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CalendarViewScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 32,
                            ),
                          ),
                          child: const Text(
                            'Registrar período',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],

          // -- Consejos diarios --
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Text(
              'Consejos diarios',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder:
                  (_, i) => Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 200,
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.asset(
                                'assets/tips/tip_${i + 1}.jpg',
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => Container(
                                      color: Colors.pink[100],
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Consejo ${i + 1}'),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
            ),
          ),

          const SizedBox(height: 32),

          // -- Historial de ciclos --
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.history, color: Colors.pinkAccent),
                title: const Text('Historial de ciclos'),
                subtitle: const Text('Revisa tus ciclos anteriores'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.pushNamed(context, '/history'),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Consejos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        onTap: (i) {
          switch (i) {
            case 1:
              Navigator.pushNamed(context, '/calendar');
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
    );
  }
}
