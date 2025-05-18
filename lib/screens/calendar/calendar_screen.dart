import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zyla/models/period_entry.dart';
import 'package:zyla/services/firestore_service.dart';
import 'package:zyla/providers/auth_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final FirestoreService _firestore = FirestoreService();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<PeriodEntry> _entries = [];

  // Opciones
  final flowOptions = ['Ligero', 'Normal', 'Abundante'];
  final moodOptions = [
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
  ];
  final symptomOptions = [
    'Cólicos',
    'Pechos sensibles',
    'Dolor de cabeza',
    'Dolor de espalda',
    'Acné',
    'Me encuentro bien',
    'Antojos',
  ];
  final activityOptions = [
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
  ];

  @override
  void initState() {
    super.initState();
    _firestore.streamPeriodEntries().listen((list) {
      setState(() => _entries = list);
    });
  }

  List<PeriodEntry> _eventsForDay(DateTime day) {
    return _entries.where((e) => isSameDay(e.date, day)).toList();
  }

  void _onDaySelected(DateTime selected, DateTime focused) {
    setState(() {
      _selectedDay = selected;
      _focusedDay = focused;
    });
    _showEntrySheet();
  }

  Future<void> _showEntrySheet() async {
    if (_selectedDay == null) return;
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
                        'Registro ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
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
                            flowOptions.map((f) {
                              final selColor =
                                  flow == f ? Colors.pink : Colors.pink[100];
                              return ChoiceChip(
                                label: Text(f),
                                selected: flow == f,
                                selectedColor: selColor,
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
                            moodOptions.map((m) {
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
                            symptomOptions.map((s) {
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
                            activityOptions.map((a) {
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
                                    date: _selectedDay!,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        backgroundColor: Colors.pink[50],
        foregroundColor: Colors.pink[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
          onDaySelected: _onDaySelected,

          // Ocultar formato “2 weeks”
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.pink),
            rightChevronIcon: const Icon(
              Icons.chevron_right,
              color: Colors.pink,
            ),
          ),

          // Pintar marcadores en días con datos
          eventLoader: _eventsForDay,
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                return Positioned(
                  bottom: 4,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.pinkAccent,
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
            selectedBuilder: (context, date, _) {
              return Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.pink[200],
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${date.day}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
