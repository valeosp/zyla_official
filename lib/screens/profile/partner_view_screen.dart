import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class PartnerViewScreen extends StatelessWidget {
  final String partnerUid;
  const PartnerViewScreen({super.key, required this.partnerUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vista de pareja')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: FirestoreService().getUserData(partnerUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('No se encontró la información de la pareja.'),
            );
          }
          final data = snapshot.data!;
          // Obtener y convertir timestamp
          final timestamp = data['lastPeriodDate'] as Timestamp?;
          final DateTime? lastDate = timestamp?.toDate();
          // Tipo de ciclo y duración
          final String cycleType = data['cycleType'] as String? ?? 'Regular';
          final int cycleLength =
              cycleType == 'Irregular'
                  ? 30
                  : cycleType == 'Variado'
                  ? 26
                  : 28;
          // Cálculo de fechas
          final DateTime? nextDate = lastDate?.add(Duration(days: cycleLength));
          final DateTime? ovulationDate = lastDate?.add(
            Duration(days: cycleLength ~/ 2),
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('UID: $partnerUid', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Text(
                  'Último periodo: '
                  '${lastDate != null ? '${lastDate.day}/${lastDate.month}/${lastDate.year}' : 'N/A'}',
                ),
                Text(
                  'Próximo periodo: '
                  '${nextDate != null ? '${nextDate.day}/${nextDate.month}' : 'N/A'}',
                ),
                Text(
                  'Ovulación: '
                  '${ovulationDate != null ? '${ovulationDate.day}/${ovulationDate.month}' : 'N/A'}',
                ),
                const Divider(height: 32),
                Text(
                  'Razón seguimiento: '
                  '${data['trackingReason'] as String? ?? '-'}',
                ),
                Text('Tipo de ciclo: $cycleType'),
                Text(
                  'Estado de ánimo: '
                  '${data['periodFeeling'] as String? ?? '-'}',
                ),
                // Puedes agregar más campos de data aquí
              ],
            ),
          );
        },
      ),
    );
  }
}
