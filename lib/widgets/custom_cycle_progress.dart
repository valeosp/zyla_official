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
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuint,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color.fromARGB(170, 247, 243, 239),
            colorForPhase(currentSegment.phase).withOpacity(0.08),
          ],
          stops: const [0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCycleWheel(),
          const SizedBox(height: 28),
          _buildPhaseInfo(currentSegment),
          if (widget.nextPhase != null && widget.nextPhaseDay != null) ...[
            const SizedBox(height: 16),
            _buildNextPhaseInfo(),
          ],
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
              // Círculo de fondo sutil
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade50,
                ),
              ),
              // Círculos guía para los días
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade100, width: 0.5),
                ),
              ),
              // Segmentos del ciclo
              ...widget.segments.map((segment) {
                final sweepAngle = 360 / widget.cycleLength;
                final startAngle = (segment.day - 1) * sweepAngle;

                return Positioned.fill(
                  child: CustomPaint(
                    painter: _SegmentPainter(
                      startAngle: startAngle,
                      sweepAngle: sweepAngle,
                      color: colorForPhase(segment.phase),
                      isToday: segment.isToday,
                      animation: _animation.value,
                    ),
                    child: Container(),
                  ),
                );
              }).toList(),
              // Números de los días
              ...widget.segments.map((segment) {
                final angle = (segment.day - 1) * (360 / widget.cycleLength);
                final radians = (angle - 90) * math.pi / 180;
                const radius = 117.0; // Ajustado para alinear mejor
                final x = radius * math.cos(radians);
                final y = radius * math.sin(radians);

                return Positioned(
                  left: 140 + x - 12,
                  top: 140 + y - 12,
                  child: _buildDayNumber(segment),
                );
              }).toList(),
              // Contenido central
              _buildCenterContent(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayNumber(PhaseSegment segment) {
    final isToday = segment.isToday;
    final isMultipleOfFive =
        segment.day % 5 == 0; // Mostrar solo múltiplos de 5 por limpieza visual

    // Para hacerlo más minimalista, solo mostramos algunos números de días
    if (!isToday && !isMultipleOfFive && segment.day != 1) {
      return Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isToday ? colorForPhase(segment.phase) : Colors.grey.shade300,
        ),
      );
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isToday ? 1.0 : (isMultipleOfFive ? 0.8 : 0.5),
      child: Container(
        width: isToday ? 26 : 22,
        height: isToday ? 26 : 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isToday ? colorForPhase(segment.phase) : Colors.transparent,
          border:
              isToday
                  ? null
                  : Border.all(color: Colors.grey.shade300, width: 0.5),
          boxShadow:
              isToday
                  ? [
                    BoxShadow(
                      color: colorForPhase(segment.phase).withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 0,
                      offset: const Offset(0, 1),
                    ),
                  ]
                  : null,
        ),
        child: Center(
          child: Text(
            '${segment.date.day}',
            style: TextStyle(
              fontSize: isToday ? 12 : 10,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? Colors.white : Colors.grey.shade600,
            ),
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
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: colorForPhase(currentSegment.phase).withOpacity(0.1),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 0.8 + (0.2 * _animation.value),
                child: Icon(
                  iconForPhase(currentSegment.phase),
                  size: 38,
                  color: colorForPhase(currentSegment.phase),
                ),
              ),
              const SizedBox(height: 8),
              Opacity(
                opacity: _animation.value,
                child: Column(
                  children: [
                    Text(
                      'Día ${widget.currentDay}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorForPhase(currentSegment.phase),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'de ${widget.cycleLength}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPhaseInfo(PhaseSegment currentSegment) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 16 - (16 * _animation.value)),
          child: Opacity(
            opacity: _animation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
              decoration: BoxDecoration(
                color: colorForPhase(currentSegment.phase).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorForPhase(currentSegment.phase).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    iconForPhase(currentSegment.phase),
                    color: colorForPhase(currentSegment.phase),
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayNameForPhase(currentSegment.phase),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: colorForPhase(currentSegment.phase),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fase actual de tu ciclo',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextPhaseInfo() {
    if (widget.nextPhase == null || widget.nextPhaseDay == null) {
      return const SizedBox.shrink();
    }

    final daysUntilNext = widget.nextPhaseDay! - widget.currentDay;
    final nextPhaseColor = colorForPhase(widget.nextPhase!);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 24 - (24 * _animation.value)),
          child: Opacity(
            opacity: _animation.value * 0.9,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(156, 154, 255, 223),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: nextPhaseColor.withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: nextPhaseColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.schedule,
                      color: nextPhaseColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Próxima fase: ${displayNameForPhase(widget.nextPhase!)}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          daysUntilNext == 1
                              ? 'En 1 día'
                              : 'En $daysUntilNext días',
                          style: TextStyle(
                            fontSize: 13,
                            color: nextPhaseColor.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
    final baseStrokeWidth = isToday ? 8.0 : 6.0;
    final animatedStrokeWidth = baseStrokeWidth * animation;

    final rect = Offset.zero & size;
    final paint =
        Paint()
          ..color = color.withOpacity(
            isToday ? 0.9 * animation : 0.7 * animation,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = animatedStrokeWidth
          ..strokeCap = StrokeCap.round;

    if (isToday) {
      // Efecto de brillo para el día actual
      final glowPaint =
          Paint()
            ..color = color.withOpacity(0.25 * animation)
            ..style = PaintingStyle.stroke
            ..strokeWidth = animatedStrokeWidth + 6
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      final startRadian = (startAngle - 90) * (math.pi / 180);
      final sweepRadian = sweepAngle * (math.pi / 180);

      canvas.drawArc(
        Rect.fromCircle(
          center: rect.center,
          radius: size.width / 2 - animatedStrokeWidth - 2,
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
        radius: size.width / 2 - animatedStrokeWidth,
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
