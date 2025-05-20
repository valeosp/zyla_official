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
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Colores para el diseño minimalista
  final Color _primaryColor = const Color(0xFFF7B9C5); // Rosa pastel
  final Color _accentColor = const Color(0xFFD16A86); // Rosa más intenso
  final Color _backgroundColor = const Color(
    0xFFFFF9FA,
  ); // Rosa muy claro, casi blanco
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF454545);
  final Color _secondaryTextColor = const Color(0xFF8E8E8E);

  // Colores para diferentes estados del ciclo
  final Color _periodColor = const Color(0xFFF7B9C5); // Rosa pastel
  final Color _fertileColor = const Color(0xFFB5E3FF); // Azul claro pastel
  final Color _ovulationColor = const Color(0xFFD0B1FA); // Lila pastel
  final Color _registeredColor = const Color(
    0xFFFFD4B1,
  ); // Naranja claro pastel
  final Color _todayColor = const Color(0xFFB9F7D9); // Verde pastel
  final Color _selectedDayColor = const Color(0xFFD16A86); // Rosa más intenso

  // Colores para las diferentes secciones de registro
  final Color _flowSectionColor = const Color(
    0xFFD16A86,
  ); // Rosa más intenso para flujo
  final Color _symptomsSectionColor = const Color(
    0xFFE29847,
  ); // Naranja pastel para síntomas
  final Color _moodSectionColor = const Color(
    0xFF6AB387,
  ); // Verde pastel para ánimo
  final Color _activitySectionColor = const Color(
    0xFF5BA2C6,
  ); // Azul pastel para actividad

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
            (_) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: _cardColor,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _accentColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.calendar,
                            color: _accentColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Registro del ${norm.day}/${norm.month}/${norm.year}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _textColor,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(
                      color: _primaryColor.withOpacity(0.2),
                      thickness: 1.5,
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      icon: CupertinoIcons.drop,
                      label: 'Flujo',
                      value: existing.flow,
                      color: _flowSectionColor,
                    ),
                    if (existing.symptoms.isNotEmpty)
                      _InfoRow(
                        icon: CupertinoIcons.bandage,
                        label: 'Síntomas',
                        value: existing.symptoms.join(', '),
                        color: _symptomsSectionColor,
                      ),
                    if (existing.mood.isNotEmpty)
                      _InfoRow(
                        icon: CupertinoIcons.smiley,
                        label: 'Ánimo',
                        value: existing.mood.join(', '),
                        color: _moodSectionColor,
                      ),
                    if (existing.sexualActivity.isNotEmpty)
                      _InfoRow(
                        icon: CupertinoIcons.heart_fill,
                        label: 'Actividad sexual',
                        value: existing.sexualActivity.join(', '),
                        color: _activitySectionColor,
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
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
              ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _accentColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              CupertinoIcons.calendar_badge_plus,
                              color: _accentColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Registrar - ${norm.day}/${norm.month}/${norm.year}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _SectionTitle(
                        icon: CupertinoIcons.drop,
                        label: 'Flujo',
                        color: _flowSectionColor,
                      ),
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 32),
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
                                        content: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            SizedBox(width: 10),
                                            Text('Registro guardado'),
                                          ],
                                        ),
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        margin: const EdgeInsets.all(16),
                                        duration: const Duration(seconds: 2),
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
    final isToday = _isSameDay(date, DateTime.now());
    final hasEntry = _entries.containsKey(norm);

    Color? bg;
    Color textColor = _textColor;
    BoxDecoration? decoration;
    Widget? marker;

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
    } else if (isToday) {
      bg = _todayColor;
      decoration = BoxDecoration(color: bg, shape: BoxShape.circle);
      marker = Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            margin: const EdgeInsets.only(bottom: 2),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Hoy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 7,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    } else if (cp.lastPeriodDate != null &&
        !norm.isBefore(cp.lastPeriodDate!) &&
        norm.isBefore(
          cp.lastPeriodDate!.add(Duration(days: cp.periodLength)),
        )) {
      bg = _periodColor;
      decoration = BoxDecoration(color: bg, shape: BoxShape.circle);
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
    }
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(4),
          decoration: decoration,
          alignment: Alignment.center,
          child: AspectRatio(
            aspectRatio: 1,
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: textColor,
                  fontWeight:
                      isSelected || isToday
                          ? FontWeight.w600
                          : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        if (marker != null) marker,
      ],
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                _calendarFormat == CalendarFormat.month
                    ? CupertinoIcons.list_bullet
                    : CupertinoIcons.calendar,
                color: _accentColor,
              ),
              onPressed: () {
                setState(() {
                  _calendarFormat =
                      _calendarFormat == CalendarFormat.month
                          ? CalendarFormat.twoWeeks
                          : CalendarFormat.month;
                });
              },
              tooltip:
                  _calendarFormat == CalendarFormat.month
                      ? 'Vista semanal'
                      : 'Vista mensual',
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          children: [
            // Leyenda de colores
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _LegendDot(color: _periodColor, label: 'Período'),
                  _LegendDot(color: _fertileColor, label: 'Fértil'),
                  _LegendDot(color: _ovulationColor, label: 'Ovulación'),
                  _LegendDot(color: _registeredColor, label: 'Registrado'),
                  _LegendDot(color: _todayColor, label: 'Hoy'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Calendario
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: TableCalendar(
                    firstDay: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate:
                        (d) =>
                            _selectedDay != null &&
                            _isSameDay(d, _selectedDay!),
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
                      cellMargin: const EdgeInsets.all(4),
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
                      headerPadding: const EdgeInsets.symmetric(vertical: 12.0),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),
                    calendarFormat: _calendarFormat,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Mes',
                      CalendarFormat.twoWeeks: 'Semanas',
                    },
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
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.04),
                      ),
                    ),
                    daysOfWeekHeight: 40,
                    rowHeight: 52,
                  ),
                ),
              ),
            ),

            // Sección de estadísticas o información adicional
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          CupertinoIcons.chart_pie,
                          color: _accentColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Resumen del ciclo',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: _textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _CycleInfoItem(
                        icon: CupertinoIcons.drop,
                        label: 'Último período',
                        value:
                            cp.lastPeriodDate != null
                                ? '${cp.lastPeriodDate!.day}/${cp.lastPeriodDate!.month}'
                                : 'No hay datos',
                        color: _periodColor,
                      ),
                      _CycleInfoItem(
                        icon: CupertinoIcons.sparkles,
                        label: 'Ovulación',
                        value:
                            cp.ovulationDate != null
                                ? '${cp.ovulationDate!.day}/${cp.ovulationDate!.month}'
                                : 'No hay datos',
                        color: _ovulationColor,
                      ),
                      _CycleInfoItem(
                        icon: CupertinoIcons.calendar,
                        label: 'Duración ciclo',
                        value: '${cp.cycleLength} días',
                        color: _primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
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
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF454545),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
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

class _CycleInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _CycleInfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color.withOpacity(0.8), size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF454545),
          ),
        ),
      ],
    );
  }
}
