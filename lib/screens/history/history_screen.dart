import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../models/period_entry.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';

enum FilterType { mes, ano, semana }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirestoreService _firestore = FirestoreService();
  FilterType _filter = FilterType.mes;
  DateTime? _searchDate;
  final TextEditingController _searchController = TextEditingController();

  // Colores para el diseño minimalista
  final Color _primaryColor = const Color(0xFFFF84AB);
  final Color _accentColor = const Color(0xFFFF4081);
  final Color _backgroundColor = const Color(0xFFFAF8F9);
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF454545);
  final Color _secondaryTextColor = const Color(0xFF757575);

  // Colores para diferentes flujos
  Color getFlowColor(String flow) {
    switch (flow) {
      case 'Ligero':
        return const Color(0xFFFFB6C1);
      case 'Normal':
        return const Color(0xFFFF69B4);
      case 'Abundante':
        return const Color(0xFFFF1493);
      default:
        return _primaryColor;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PeriodEntry> _applyFilter(List<PeriodEntry> all) {
    final now = DateTime.now();
    final query = _searchController.text.toLowerCase();
    List<PeriodEntry> filtered = all;

    if (query.isNotEmpty) {
      filtered =
          all.where((e) {
            final formattedDate1 = DateFormat('dd/MM/yyyy').format(e.date);
            final formattedDate2 = DateFormat('yyyy-MM-dd').format(e.date);
            return formattedDate1.contains(query) ||
                formattedDate2.contains(query) ||
                e.flow.toLowerCase().contains(query) ||
                e.symptoms.any((s) => s.toLowerCase().contains(query)) ||
                e.mood.any((m) => m.toLowerCase().contains(query)) ||
                e.sexualActivity.any((a) => a.toLowerCase().contains(query));
          }).toList();
    } else if (_searchDate != null) {
      filtered =
          all.where((e) {
            return e.date.year == _searchDate!.year &&
                e.date.month == _searchDate!.month &&
                e.date.day == _searchDate!.day;
          }).toList();
    } else {
      switch (_filter) {
        case FilterType.mes:
          filtered =
              all
                  .where(
                    (e) => e.date.month == now.month && e.date.year == now.year,
                  )
                  .toList();
          break;
        case FilterType.ano:
          filtered = all.where((e) => e.date.year == now.year).toList();
          break;
        case FilterType.semana:
          final weekAgo = now.subtract(const Duration(days: 7));
          filtered = all.where((e) => e.date.isAfter(weekAgo)).toList();
          break;
      }
    }
    return filtered;
  }

  Future<void> _editEntry(PeriodEntry entry) async {
    String flow = entry.flow;
    final mood = entry.mood.toSet();
    final symptoms = entry.symptoms.toSet();
    final activity = entry.sexualActivity.toSet();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: StatefulBuilder(
            builder: (context, setSt) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Editar Registro',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle(
                      label: 'Flujo',
                      color: _primaryColor,
                      emoji: '🩸',
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
                                  color: flow == f ? Colors.white : _textColor,
                                  fontWeight:
                                      flow == f
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                ),
                              ),
                              selected: flow == f,
                              selectedColor: _accentColor,
                              backgroundColor: Colors.grey.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              onSelected: (_) => setSt(() => flow = f),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle(
                      label: 'Síntomas',
                      color: _primaryColor,
                      emoji: '🤒',
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
                              selectedColor: _primaryColor,
                              backgroundColor: Colors.grey.shade100,
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
                    const SizedBox(height: 24),
                    _SectionTitle(
                      label: 'Ánimo',
                      color: _primaryColor,
                      emoji: '😊',
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
                              selectedColor: _primaryColor,
                              backgroundColor: Colors.grey.shade100,
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
                    const SizedBox(height: 24),
                    _SectionTitle(
                      label: 'Actividad sexual',
                      color: _primaryColor,
                      emoji: ' 🩷 ',
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
                              selectedColor: _primaryColor,
                              backgroundColor: Colors.grey.shade100,
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
                        onPressed: () async {
                          final updated = PeriodEntry(
                            id: entry.id,
                            date: entry.date,
                            flow: flow,
                            mood: mood.toList(),
                            symptoms: symptoms.toList(),
                            sexualActivity: activity.toList(),
                          );
                          await _firestore.savePeriodEntry(updated);
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Guardar',
                              style: TextStyle(
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
        );
      },
    );
  }

  Future<bool?> _confirmDelete() {
    return showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: _backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Eliminar entrada',
              style: TextStyle(color: _textColor, fontWeight: FontWeight.w600),
            ),
            content: Text(
              '¿Seguro que deseas eliminar esta entrada?',
              style: TextStyle(color: _secondaryTextColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: _secondaryTextColor),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _backgroundColor,
        foregroundColor: _textColor,
        centerTitle: true,
        title: Text(
          'Historial de tu ciclo',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: _textColor,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: _textColor),
                    decoration: InputDecoration(
                      hintText: 'Buscar por fecha o palabra clave...',
                      hintStyle: TextStyle(
                        color: _secondaryTextColor,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: _cardColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      prefixIcon: Icon(
                        Icons.search,
                        color: _secondaryTextColor,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _primaryColor),
                      ),
                    ),
                    onChanged: (val) => setState(() {}),
                    onSubmitted: (val) {
                      final parts = val.split('/');
                      if (parts.length == 3) {
                        final d = int.tryParse(parts[0]);
                        final m = int.tryParse(parts[1]);
                        final y = int.tryParse(parts[2]);
                        if (d != null && m != null && y != null) {
                          setState(() {
                            _searchDate = DateTime(y, m, d);
                          });
                          return;
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: PopupMenuButton<FilterType>(
                    icon: Icon(
                      Icons.filter_list,
                      color: _accentColor,
                      size: 20,
                    ),
                    padding: const EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onSelected: (f) {
                      setState(() {
                        _filter = f;
                        _searchDate = null;
                        _searchController.clear();
                      });
                    },
                    itemBuilder:
                        (_) => [
                          PopupMenuItem(
                            value: FilterType.mes,
                            child: Text(
                              'Este mes',
                              style: TextStyle(color: _textColor),
                            ),
                          ),
                          PopupMenuItem(
                            value: FilterType.ano,
                            child: Text(
                              'Este año',
                              style: TextStyle(color: _textColor),
                            ),
                          ),
                          PopupMenuItem(
                            value: FilterType.semana,
                            child: Text(
                              'Última semana',
                              style: TextStyle(color: _textColor),
                            ),
                          ),
                        ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PeriodEntry>>(
              stream: _firestore.streamPeriodEntries(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: _accentColor,
                      strokeWidth: 3,
                    ),
                  );
                }
                final all = snap.data ?? [];
                final shown = _applyFilter(all);
                if (shown.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay entradas',
                          style: TextStyle(
                            color: _secondaryTextColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: shown.length,
                  itemBuilder: (context, i) {
                    final e = shown[i];
                    return Slidable(
                      key: Key(e.id!),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        extentRatio: 0.30,
                        children: [
                          SlidableAction(
                            onPressed: (_) => _editEntry(e),
                            backgroundColor: Colors.blue.shade100,
                            foregroundColor: Colors.blue.shade700,
                            icon: Icons.edit_rounded,
                            spacing: 2,
                            padding: const EdgeInsets.all(4),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                          ),
                          SlidableAction(
                            onPressed: (_) async {
                              final confirm = await _confirmDelete();
                              if (confirm == true) {
                                await _firestore.deletePeriodEntry(e.id!);
                              }
                            },
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red.shade600,
                            icon: Icons.delete_rounded,
                            spacing: 2,
                            padding: const EdgeInsets.all(4),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                        ],
                      ),
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        elevation: 0,
                        color: _cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade100),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [_primaryColor, _accentColor],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${e.date.day}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              DateFormat('EEE, dd MMM yyyy').format(e.date),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _textColor,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: getFlowColor(
                                          e.flow,
                                        ).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '🩸 ',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            'Flujo: ${e.flow}',
                                            style: TextStyle(
                                              color: getFlowColor(e.flow),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  e.symptoms.isNotEmpty
                                      ? '🤒 Síntomas: ${e.symptoms.join(', ')}'
                                      : '✅ Sin síntomas registrados',
                                  style: TextStyle(
                                    color: _secondaryTextColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Container(
                              decoration: BoxDecoration(
                                color: _primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: _accentColor,
                                ),
                                onPressed: () => _editEntry(e),
                              ),
                            ),
                            onTap: () => _editEntry(e),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  final Color color;
  final String emoji;

  const _SectionTitle({
    required this.label,
    required this.color,
    this.emoji = '',
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
        if (emoji.isNotEmpty) Text(emoji, style: const TextStyle(fontSize: 16)),
        if (emoji.isNotEmpty) const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: const Color(0xFF454545),
          ),
        ),
      ],
    );
  }
}
