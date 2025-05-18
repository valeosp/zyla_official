import 'package:flutter/material.dart';
import 'package:menstrual_cycle_widget/menstrual_cycle_widget.dart';

class PhaseViewScreen extends StatelessWidget {
  const PhaseViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fases del Ciclo')),
      body: Center(
        child: MenstrualCyclePhaseView(
          size: 300,
          theme: MenstrualCycleTheme.arcs,
          phaseTextBoundaries: PhaseTextBoundaries.outside,
          isRemoveBackgroundPhaseColor: true,
          viewType: MenstrualCycleViewType.text,
          isAutoSetData: true,
        ),
      ),
    );
  }
}
