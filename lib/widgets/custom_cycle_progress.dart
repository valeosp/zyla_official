// lib/widgets/custom_cycle_progress.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:zyla/utils/cycle_utils.dart'; // Asegúrate que esta ruta sea correcta

class PhaseSegment {
  final int day;
  final String phase; // 'periodo', 'ovulación', 'fértil', 'folicular'
  final DateTime date;
  final bool isToday;

  PhaseSegment({
    required this.day,
    required this.phase,
    required this.date,
    this.isToday = false,
  });
}

class CustomCycleProgress extends StatefulWidget {
  final int cycleLength;
  final List<PhaseSegment> segments;
  final int currentDay;
  final String? nextPhase;
  final int? nextPhaseDay;

  const CustomCycleProgress({
    Key? key,
    required this.cycleLength,
    required this.segments,
    required this.currentDay,
    this.nextPhase,
    this.nextPhaseDay,
  }) : super(key: key);

  @override
  State<CustomCycleProgress> createState() => _CustomCycleProgressState();
}

class _CustomCycleProgressState extends State<CustomCycleProgress>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSegment = widget.segments.firstWhere(
      (segment) => segment.day == widget.currentDay,
      orElse: () => widget.segments.first,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            colorForPhase(currentSegment.phase).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCycleWheel(),
          const SizedBox(height: 24),
          _buildPhaseInfo(currentSegment),
          const SizedBox(height: 16),
          _buildNextPhaseInfo(),
        ],
      ),
    );
  }

  Widget _buildCycleWheel() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade100,
                ),
              ),
              ...widget.segments.map((segment) {
                final sweepAngle = 360 / widget.cycleLength;
                final startAngle = (segment.day - 1) * sweepAngle;

                return Positioned.fill(
                  child: CustomPaint(
                    painter: _SegmentPainter(
                      startAngle: startAngle,
                      sweepAngle: sweepAngle,
                      color: colorForPhase(segment.phase),
                      isToday: segment.day == widget.currentDay,
                      animation: _animation.value,
                    ),
                  ),
                );
              }).toList(),
              ...widget.segments.map((segment) {
                final angle = (segment.day - 1) * (360 / widget.cycleLength);
                final radians = (angle - 90) * math.pi / 180;
                const radius = 120.0;
                final x = radius * math.cos(radians);
                final y = radius * math.sin(radians);

                return Positioned(
                  left: 140 + x - 12,
                  top: 140 + y - 12,
                  child: _buildDayNumber(segment),
                );
              }).toList(),
              _buildCenterContent(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayNumber(PhaseSegment segment) {
    final isToday = segment.day == widget.currentDay;

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isToday ? colorForPhase(segment.phase) : Colors.transparent,
        border:
            isToday
                ? null
                : Border.all(color: Colors.grey.shade400, width: 0.5),
      ),
      child: Center(
        child: Text(
          '${segment.day}',
          style: TextStyle(
            fontSize: 10,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildCenterContent() {
    final currentSegment = widget.segments.firstWhere(
      (segment) => segment.day == widget.currentDay,
    );

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconForPhase(currentSegment.phase),
            size: 32,
            color: colorForPhase(currentSegment.phase),
          ),
          const SizedBox(height: 8),
          Text(
            'Día ${widget.currentDay}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorForPhase(currentSegment.phase),
            ),
          ),
          Text(
            'de ${widget.cycleLength}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseInfo(PhaseSegment currentSegment) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: colorForPhase(currentSegment.phase).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorForPhase(currentSegment.phase).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconForPhase(currentSegment.phase),
            color: colorForPhase(currentSegment.phase),
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayNameForPhase(currentSegment.phase),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorForPhase(currentSegment.phase),
                ),
              ),
              Text(
                'Fase actual de tu ciclo',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextPhaseInfo() {
    if (widget.nextPhase == null || widget.nextPhaseDay == null) {
      return const SizedBox.shrink();
    }

    final daysUntilNext = widget.nextPhaseDay! - widget.currentDay;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Próxima fase: ${displayNameForPhase(widget.nextPhase!)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  daysUntilNext == 1 ? 'En 1 día' : 'En $daysUntilNext días',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentPainter extends CustomPainter {
  final double startAngle;
  final double sweepAngle;
  final Color color;
  final bool isToday;
  final double animation;

  _SegmentPainter({
    required this.startAngle,
    required this.sweepAngle,
    required this.color,
    required this.isToday,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = isToday ? 16.0 : 12.0;
    final rect = Offset.zero & size;
    final paint =
        Paint()
          ..color = color.withOpacity(animation)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    if (isToday) {
      final glowPaint =
          Paint()
            ..color = color.withOpacity(0.3 * animation)
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth + 4
            ..strokeCap = StrokeCap.round;

      final startRadian = (startAngle - 90) * (math.pi / 180);
      final sweepRadian = sweepAngle * (math.pi / 180);

      canvas.drawArc(
        Rect.fromCircle(
          center: rect.center,
          radius: size.width / 2 - strokeWidth - 2,
        ),
        startRadian,
        sweepRadian,
        false,
        glowPaint,
      );
    }

    final startRadian = (startAngle - 90) * (math.pi / 180);
    final sweepRadian = sweepAngle * (math.pi / 180);

    canvas.drawArc(
      Rect.fromCircle(
        center: rect.center,
        radius: size.width / 2 - strokeWidth,
      ),
      startRadian,
      sweepRadian,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SegmentPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.startAngle != startAngle ||
        oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.isToday != isToday ||
        oldDelegate.animation != animation;
  }
}

/// Función helper para construir los segmentos del ciclo
List<PhaseSegment> buildCycleSegments({
  required int cycleLength,
  required DateTime lastPeriodDate,
  required int periodLength,
  required DateTime? ovulationDate,
  required List<DateTime> fertileWindow,
}) {
  List<PhaseSegment> segments = [];
  final today = DateTime.now();

  for (int day = 1; day <= cycleLength; day++) {
    final dayDate = lastPeriodDate.add(Duration(days: day - 1));
    final isToday =
        dayDate.year == today.year &&
        dayDate.month == today.month &&
        dayDate.day == today.day;

    String phase = 'folicular';

    if (day <= periodLength) {
      phase = 'periodo';
    } else if (ovulationDate != null &&
        dayDate.year == ovulationDate.year &&
        dayDate.month == ovulationDate.month &&
        dayDate.day == ovulationDate.day) {
      phase = 'ovulación';
    } else if (fertileWindow.any(
      (date) =>
          date.year == dayDate.year &&
          date.month == dayDate.month &&
          date.day == dayDate.day,
    )) {
      phase = 'fértil';
    }

    segments.add(
      PhaseSegment(day: day, phase: phase, date: dayDate, isToday: isToday),
    );
  }

  return segments;
}

/// Función para obtener la siguiente fase
String? getNextPhase(List<PhaseSegment> segments, int currentDay) {
  for (int day = currentDay + 1; day <= segments.length; day++) {
    final segment = segments.firstWhere((s) => s.day == day);
    final currentSegment = segments.firstWhere((s) => s.day == currentDay);
    if (segment.phase != currentSegment.phase) {
      return segment.phase;
    }
  }
  return null;
}

int? getNextPhaseDay(List<PhaseSegment> segments, int currentDay) {
  for (int day = currentDay + 1; day <= segments.length; day++) {
    final segment = segments.firstWhere((s) => s.day == day);
    final currentSegment = segments.firstWhere((s) => s.day == currentDay);
    if (segment.phase != currentSegment.phase) {
      return segment.day;
    }
  }
  return null;
}
