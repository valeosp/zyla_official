// lib/screens/history/history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // ← Import necesario para DateFormat
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PeriodEntry> _applyFilter(List<PeriodEntry> all) {
    final now = DateTime.now();
    var filtered = all;
    if (_searchDate != null) {
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

  Future<bool?> _confirmDelete() {
    return showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Eliminar entrada'),
            content: const Text('¿Seguro que deseas eliminar esta entrada?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  Future<void> _showEditDialog(PeriodEntry entry) async {
    DateTime date = entry.date;
    String flow = entry.flow;
    await showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (ctx, setState) => AlertDialog(
                  title: Text('Editar ${date.day}/${date.month}/${date.year}'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Flujo'),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: flow,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items:
                            ['Ligero', 'Normal', 'Abundante']
                                .map(
                                  (f) => DropdownMenuItem(
                                    value: f,
                                    child: Text(f),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setState(() => flow = v!),
                      ),
                      const SizedBox(height: 16),
                      // aquí podrías añadir más campos si quisieras
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final updated = PeriodEntry(
                          id: entry.id,
                          date: date,
                          flow: flow,
                          mood: entry.mood,
                          symptoms: entry.symptoms,
                          sexualActivity: entry.sexualActivity,
                        );
                        await _firestore.savePeriodEntry(updated);
                        Navigator.pop(context);
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text('Historial de tu ciclo'),
      ),
      body: Column(
        children: [
          // barra de búsqueda + filtro
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'dd/mm/yyyy',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
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
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<FilterType>(
                  icon: const Icon(Icons.filter_list, color: Colors.pinkAccent),
                  onSelected:
                      (f) => setState(() {
                        _filter = f;
                        _searchDate = null;
                        _searchController.clear();
                      }),
                  itemBuilder:
                      (_) => const [
                        PopupMenuItem(
                          value: FilterType.mes,
                          child: Text('Este mes'),
                        ),
                        PopupMenuItem(
                          value: FilterType.ano,
                          child: Text('Este año'),
                        ),
                        PopupMenuItem(
                          value: FilterType.semana,
                          child: Text('Última semana'),
                        ),
                      ],
                ),
              ],
            ),
          ),

          // lista de entradas
          Expanded(
            child: StreamBuilder<List<PeriodEntry>>(
              stream: _firestore.streamPeriodEntries(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final all = snap.data ?? [];
                final shown = _applyFilter(all);
                if (shown.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay entradas',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: shown.length,
                  itemBuilder: (context, i) {
                    final e = shown[i];
                    return Dismissible(
                      key: Key(e.id!),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) => _confirmDelete(),
                      onDismissed: (_) async {
                        await _firestore.deletePeriodEntry(e.id!);
                      },
                      background: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.pinkAccent.shade100,
                            child: Text('${e.date.day}'),
                          ),
                          title: Text(
                            DateFormat('EEE, dd MMM yyyy').format(e.date),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Flujo: ${e.flow}\n'
                            'Síntomas: ${e.symptoms.join(', ')}',
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.pink),
                            onPressed: () => _showEditDialog(e),
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
