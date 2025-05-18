// lib/screens/menstrual/calendar_view_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zyla/models/period_entry.dart';
import 'package:zyla/providers/cycle_provider.dart';
import 'package:zyla/providers/onboarding_provider.dart';
import 'package:zyla/services/firestore_service.dart';

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({Key? key}) : super(key: key);

  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  final _firestore = FirestoreService();
  List<PeriodEntry> _entries = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _firestore.streamPeriodEntries().listen((list) {
      setState(() => _entries = list);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<PeriodEntry> _eventsForDay(DateTime day) =>
      _entries.where((e) => _isSameDay(e.date, day)).toList();

  Future<void> _showEntrySheet(DateTime date) async {
    final existing = _eventsForDay(date);
    if (existing.isNotEmpty) {
      final e = existing.first;
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text('Entrada ${date.day}/${date.month}/${date.year}'),
              content: Text(
                'Flujo: ${e.flow}\n'
                'Ánimo: ${e.mood.join(", ")}\n'
                'Síntomas: ${e.symptoms.join(", ")}\n'
                'Actividad sexual: ${e.sexualActivity.join(", ")}',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
      );
      return;
    }

    String? flow;
    final mood = <String>{};
    final symptom = <String>{};
    final activity = <String>{};

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (ctx) => StatefulBuilder(
            builder: (ctx, setState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  top: 16,
                  left: 16,
                  right: 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Registro ${date.day}/${date.month}/${date.year}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Flujo
                      const Text(
                        'Flujo',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children:
                            ['Ligero', 'Normal', 'Abundante'].map((f) {
                              return ChoiceChip(
                                label: Text(f),
                                selected: flow == f,
                                selectedColor: Colors.pink,
                                onSelected: (_) => setState(() => flow = f),
                              );
                            }).toList(),
                      ),

                      const SizedBox(height: 16),
                      // Estado de ánimo
                      const Text(
                        'Estado de ánimo',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children:
                            [
                              'Bien',
                              'Excelente',
                              'Mal',
                              'Irritada',
                              'Normal',
                              'Deseo sexual elevado',
                              'Triste',
                              'Ansiosa',
                              'Deprimida',
                              'Con energía',
                              'Confundida',
                              'Apática',
                            ].map((m) {
                              return FilterChip(
                                label: Text(
                                  m,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                selected: mood.contains(m),
                                selectedColor: Colors.pink[200],
                                onSelected:
                                    (sel) => setState(
                                      () => sel ? mood.add(m) : mood.remove(m),
                                    ),
                              );
                            }).toList(),
                      ),

                      const SizedBox(height: 16),
                      // Síntomas
                      const Text(
                        'Síntomas',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children:
                            [
                              'Cólicos',
                              'Pechos sensibles',
                              'Dolor de cabeza',
                              'Dolor de espalda',
                              'Acné',
                              'Me encuentro bien',
                              'Antojos',
                            ].map((s) {
                              return FilterChip(
                                label: Text(
                                  s,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                selected: symptom.contains(s),
                                selectedColor: Colors.pink[200],
                                onSelected:
                                    (sel) => setState(
                                      () =>
                                          sel
                                              ? symptom.add(s)
                                              : symptom.remove(s),
                                    ),
                              );
                            }).toList(),
                      ),

                      const SizedBox(height: 16),
                      // Actividad sexual
                      const Text(
                        'Actividad sexual',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children:
                            [
                              'No he practicado sexo',
                              'Sexo con protección',
                              'Sexo sin protección',
                              'Masturbación',
                              'Orgasmo',
                              'Juguetes sexuales',
                              'Deseo sexual elevado',
                              'Deseo sexual neutro',
                              'Deseo sexual bajo',
                              'Sexo anal',
                              'Sexo oral',
                            ].map((a) {
                              return FilterChip(
                                label: Text(
                                  a,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                selected: activity.contains(a),
                                selectedColor: Colors.pink[200],
                                onSelected:
                                    (sel) => setState(
                                      () =>
                                          sel
                                              ? activity.add(a)
                                              : activity.remove(a),
                                    ),
                              );
                            }).toList(),
                      ),

                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed:
                            flow == null
                                ? null
                                : () async {
                                  final entry = PeriodEntry(
                                    date: date,
                                    flow: flow!,
                                    mood: mood.toList(),
                                    symptoms: symptom.toList(),
                                    sexualActivity: activity.toList(),
                                  );
                                  await _firestore.savePeriodEntry(entry);
                                  Navigator.pop(ctx);
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Guardar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _buildDayCell(DateTime date, Color bg, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        '${date.day}',
        style: TextStyle(color: isSelected ? Colors.white : Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CycleProvider>();
    final onboard = context.watch<OnboardingProvider>().data;
    final periodLen = onboard.periodLength ?? 5;
    final last = cp.lastPeriodDate;
    final ovu = cp.ovulationDate;
    final fertile = cp.fertileWindow;

    return Scaffold(
      appBar: AppBar(title: const Text('Calendario')),

      body: Column(
        children: [
          // 1) Leyenda de colores
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _LegendDot(color: Colors.pink[100]!, label: 'Periodo'),
                _LegendDot(color: Colors.purple[100]!, label: 'Fértil'),
                _LegendDot(
                  color: const Color.fromARGB(255, 64, 229, 251),
                  label: 'Ovulación',
                ),
                _LegendDot(color: Colors.pinkAccent, label: 'Seleccionado'),
              ],
            ),
          ),

          // 2) TableCalendar
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                selectedDayPredicate:
                    (d) => _selectedDay != null && _isSameDay(d, _selectedDay!),
                onDaySelected: (sel, foc) {
                  setState(() {
                    _selectedDay = sel;
                    _focusedDay = foc;
                  });
                  _showEntrySheet(sel);
                },
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                eventLoader: _eventsForDay,
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (ctx, date, _) {
                    // 1) Ovulación (primero)
                    if (ovu != null && _isSameDay(date, ovu)) {
                      return _buildDayCell(
                        date,
                        const Color.fromARGB(255, 64, 235, 251),
                      );
                    }
                    // 2) Ventana fértil
                    if (fertile.any((d) => _isSameDay(d, date))) {
                      return _buildDayCell(date, Colors.purple[100]!);
                    }
                    // 3) Periodo
                    if (last != null &&
                        !date.isBefore(last) &&
                        date.isBefore(last.add(Duration(days: periodLen)))) {
                      return _buildDayCell(date, Colors.pink[100]!);
                    }
                    // 4) Día normal
                    return Container(
                      margin: const EdgeInsets.all(4),
                      alignment: Alignment.center,
                      child: Text('${date.day}'),
                    );
                  },
                  selectedBuilder:
                      (ctx, date, _) => _buildDayCell(
                        date,
                        Colors.pinkAccent,
                        isSelected: true,
                      ),
                  markerBuilder: (ctx, date, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        bottom: 4,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.pinkAccent,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pequeño widget para leyenda circular + etiqueta
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
