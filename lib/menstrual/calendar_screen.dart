import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/cupertino.dart';

import '../../models/period_entry.dart';
import '../../services/firestore_service.dart';
import '../../providers/cycle_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _firestore = FirestoreService();
  Map<DateTime, PeriodEntry> _entries = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Colores para el diseño minimalista
  final Color _primaryColor = const Color(0xFFFF84AB);
  final Color _accentColor = const Color(0xFFFF4081);
  final Color _backgroundColor = const Color(0xFFFAF8F9);
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF454545);
  final Color _secondaryTextColor = const Color(0xFF757575);

  // Colores para diferentes estados del ciclo
  final Color _periodColor = const Color(0xFFFFCDD2);
  final Color _fertileColor = const Color(0xFFE1BEE7);
  final Color _ovulationColor = const Color(0xFFBBDEFB);
  final Color _registeredColor = const Color(0xFFF8BBD0);
  final Color _selectedDayColor = const Color(0xFFFF4081);

  // Colores para las diferentes secciones de registro
  final Color _flowSectionColor = const Color(
    0xFFE91E63,
  ); // Rosa fuerte para flujo
  final Color _symptomsSectionColor = const Color(
    0xFFFF9800,
  ); // Naranja para síntomas
  final Color _moodSectionColor = const Color(0xFF4CAF50); // Verde para ánimo
  final Color _activitySectionColor = const Color(
    0xFF00BCD4,
  ); // Azul agua para actividad sexual

  @override
  void initState() {
    super.initState();
    _firestore.streamPeriodEntries().listen((list) {
      final map = <DateTime, PeriodEntry>{};
      for (var e in list) {
        final d = DateTime(e.date.year, e.date.month, e.date.day);
        map[d] = e;
      }
      setState(() => _entries = map);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _onDaySelected(DateTime day) async {
    final norm = DateTime(day.year, day.month, day.day);
    final existing = _entries[norm];
    if (existing != null) {
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: _backgroundColor,
              elevation: 0,
              title: Column(
                children: [
                  Text(
                    'Registro del ${norm.day}/${norm.month}/${norm.year}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Divider(color: _primaryColor.withOpacity(0.2), thickness: 1),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    icon: CupertinoIcons.drop,
                    label: 'Flujo',
                    value: existing.flow,
                    color: _primaryColor,
                  ),
                  if (existing.symptoms.isNotEmpty)
                    _InfoRow(
                      icon: CupertinoIcons.bandage,
                      label: 'Síntomas',
                      value: existing.symptoms.join(', '),
                      color: _primaryColor,
                    ),
                  if (existing.mood.isNotEmpty)
                    _InfoRow(
                      icon: CupertinoIcons.smiley,
                      label: 'Ánimo',
                      value: existing.mood.join(', '),
                      color: _primaryColor,
                    ),
                  if (existing.sexualActivity.isNotEmpty)
                    _InfoRow(
                      icon: CupertinoIcons.heart_fill,
                      label: 'Actividad sexual',
                      value: existing.sexualActivity.join(', '),
                      color: _primaryColor,
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: _accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
      );
      return;
    }

    String? flow;
    final mood = <String>{};
    final symptoms = <String>{};
    final activity = <String>{};

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (ctx) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              top: 16,
              left: 20,
              right: 20,
            ),
            child: StatefulBuilder(
              builder: (ctx, setSt) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        'Registrar - ${norm.day}/${norm.month}/${norm.year}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: _textColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionTitle(
                        icon: CupertinoIcons.drop,
                        label: 'Flujo',
                        color: _flowSectionColor,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        children:
                            ['Ligero', 'Normal', 'Abundante'].map((f) {
                              return ChoiceChip(
                                label: Text(
                                  f,
                                  style: TextStyle(
                                    color:
                                        flow == f ? Colors.white : _textColor,
                                    fontWeight:
                                        flow == f
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                  ),
                                ),
                                selected: flow == f,
                                selectedColor: _flowSectionColor,
                                backgroundColor: _flowSectionColor.withOpacity(
                                  0.1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                onSelected: (_) => setSt(() => flow = f),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 20),
                      _SectionTitle(
                        icon: CupertinoIcons.bandage,
                        label: 'Síntomas',
                        color: _symptomsSectionColor,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children:
                            [
                              'Cólicos',
                              'Dolor de cabeza',
                              'Acné',
                              'Antojos',
                              'Me encuentro bien',
                            ].map((s) {
                              return FilterChip(
                                label: Text(
                                  s,
                                  style: TextStyle(
                                    color:
                                        symptoms.contains(s)
                                            ? Colors.white
                                            : _textColor,
                                    fontWeight:
                                        symptoms.contains(s)
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                  ),
                                ),
                                selected: symptoms.contains(s),
                                selectedColor: _symptomsSectionColor,
                                backgroundColor: _symptomsSectionColor
                                    .withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                onSelected:
                                    (sel) => setSt(
                                      () =>
                                          sel
                                              ? symptoms.add(s)
                                              : symptoms.remove(s),
                                    ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 20),
                      _SectionTitle(
                        icon: CupertinoIcons.smiley,
                        label: 'Ánimo',
                        color: _moodSectionColor,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children:
                            [
                              'Bien',
                              'Mal',
                              'Ansiosa',
                              'Triste',
                              'Energética',
                            ].map((m) {
                              return FilterChip(
                                label: Text(
                                  m,
                                  style: TextStyle(
                                    color:
                                        mood.contains(m)
                                            ? Colors.white
                                            : _textColor,
                                    fontWeight:
                                        mood.contains(m)
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                  ),
                                ),
                                selected: mood.contains(m),
                                selectedColor: _moodSectionColor,
                                backgroundColor: _moodSectionColor.withOpacity(
                                  0.1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                onSelected:
                                    (sel) => setSt(
                                      () => sel ? mood.add(m) : mood.remove(m),
                                    ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 20),
                      _SectionTitle(
                        icon: CupertinoIcons.heart_fill,
                        label: 'Actividad sexual',
                        color: _activitySectionColor,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children:
                            [
                              'Protegido',
                              'Sin protección',
                              'Masturbación',
                              'Orgasmo',
                            ].map((a) {
                              return FilterChip(
                                label: Text(
                                  a,
                                  style: TextStyle(
                                    color:
                                        activity.contains(a)
                                            ? Colors.white
                                            : _textColor,
                                    fontWeight:
                                        activity.contains(a)
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                  ),
                                ),
                                selected: activity.contains(a),
                                selectedColor: _activitySectionColor,
                                backgroundColor: _activitySectionColor
                                    .withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                onSelected:
                                    (sel) => setSt(
                                      () =>
                                          sel
                                              ? activity.add(a)
                                              : activity.remove(a),
                                    ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 36),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              flow == null
                                  ? null
                                  : () async {
                                    final entry = PeriodEntry(
                                      date: norm,
                                      flow: flow!,
                                      mood: mood.toList(),
                                      symptoms: symptoms.toList(),
                                      sexualActivity: activity.toList(),
                                    );
                                    await _firestore.savePeriodEntry(entry);

                                    setState(() {
                                      _entries[norm] = entry;
                                    });
                                    Navigator.pop(ctx);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Registro guardado exitosamente',
                                        ),
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        margin: const EdgeInsets.all(16),
                                      ),
                                    );
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accentColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_outline, size: 18),
                              const SizedBox(width: 8),
                              const Text(
                                'Guardar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          ),
    );
  }

  Widget _dayCell(BuildContext ctx, DateTime date, DateTime focusedDay) {
    final cp = Provider.of<CycleProvider>(ctx);
    final norm = DateTime(date.year, date.month, date.day);
    final isSelected = _selectedDay != null && _isSameDay(date, _selectedDay!);
    final hasEntry = _entries.containsKey(norm);

    Color? bg;
    Color textColor = _textColor;
    BoxDecoration? decoration;

    if (isSelected) {
      bg = _selectedDayColor;
      textColor = Colors.white;
      decoration = BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _selectedDayColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      );
    } else if (hasEntry) {
      bg = _registeredColor;
      decoration = BoxDecoration(color: bg, shape: BoxShape.circle);
    } else if (cp.ovulationDate != null &&
        _isSameDay(norm, cp.ovulationDate!)) {
      bg = _ovulationColor;
      decoration = BoxDecoration(color: bg, shape: BoxShape.circle);
    } else if (cp.fertileWindow.any((d) => _isSameDay(norm, d))) {
      bg = _fertileColor;
      decoration = BoxDecoration(color: bg, shape: BoxShape.circle);
    } else if (cp.lastPeriodDate != null &&
        !norm.isBefore(cp.lastPeriodDate!) &&
        norm.isBefore(
          cp.lastPeriodDate!.add(Duration(days: cp.periodLength)),
        )) {
      bg = _periodColor;
      decoration = BoxDecoration(color: bg, shape: BoxShape.circle);
    }

    return Container(
      margin: const EdgeInsets.all(6),
      decoration: decoration,
      alignment: Alignment.center,
      child: Text(
        '${date.day}',
        style: TextStyle(
          color: textColor,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CycleProvider>();

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Calendario',
          style: TextStyle(
            color: _textColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: IconThemeData(color: _textColor),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _LegendDot(color: _periodColor, label: 'Período'),
                _LegendDot(color: _fertileColor, label: 'Fértil'),
                _LegendDot(color: _ovulationColor, label: 'Ovulación'),
                _LegendDot(color: _registeredColor, label: 'Registrado'),
                _LegendDot(color: _selectedDayColor, label: 'Seleccionado'),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                selectedDayPredicate:
                    (d) => _selectedDay != null && _isSameDay(d, _selectedDay!),
                onPageChanged: (d) => setState(() => _focusedDay = d),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (ctx, d, f) => _dayCell(ctx, d, f),
                  selectedBuilder: (ctx, d, f) => _dayCell(ctx, d, f),
                  todayBuilder: (ctx, d, f) => _dayCell(ctx, d, f),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _onDaySelected(selectedDay);
                },
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  markersMaxCount: 0,
                  cellMargin: const EdgeInsets.all(6),
                ),
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextStyle: TextStyle(
                    color: _textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left_rounded,
                    color: _accentColor,
                    size: 28,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right_rounded,
                    color: _accentColor,
                    size: 28,
                  ),
                ),
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: _textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  weekendStyle: TextStyle(
                    color: _accentColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF757575),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionTitle({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF454545),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: const Color(0xFF454545),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
