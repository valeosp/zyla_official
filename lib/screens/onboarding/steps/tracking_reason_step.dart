import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

class TrackingReasonStep extends StatefulWidget {
  const TrackingReasonStep({Key? key}) : super(key: key);
  @override
  State<TrackingReasonStep> createState() => _TrackingReasonStepState();
}

class _TrackingReasonStepState extends State<TrackingReasonStep> {
  String? _selected;
  final _opts = [
    'Salud',
    'Planificación familiar',
    'Bienestar personal',
    'Otro',
  ];
  final Color primaryColor = Color(0xFFFFC6C3);
  final Map<String, IconData> _optIcons = {
    'Salud': Icons.favorite_border_rounded,
    'Planificación familiar': Icons.family_restroom_rounded,
    'Bienestar personal': Icons.spa_rounded,
    'Otro': Icons.more_horiz_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFFFF5F4)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.lightbulb_outline_rounded,
                size: 48,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '¿Por qué sigues tu ciclo?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Esto nos ayuda a mostrarte información relevante',
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 0.95,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children:
                    _opts.map((option) {
                      bool isSelected = _selected == option;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selected = option);
                          context.read<OnboardingProvider>().setTrackingReason(
                            option,
                          );
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? primaryColor
                                      : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    isSelected
                                        ? primaryColor.withOpacity(0.3)
                                        : Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                spreadRadius: isSelected ? 2 : 0,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? primaryColor.withOpacity(0.2)
                                          : Colors.grey.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _optIcons[option] ??
                                      Icons.check_circle_outline,
                                  size: 32,
                                  color:
                                      isSelected
                                          ? primaryColor
                                          : Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 14),
                              Text(
                                option,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                  color:
                                      isSelected
                                          ? Colors.black87
                                          : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            Container(
              height: 8,
              width: 100,
              margin: EdgeInsets.only(bottom: 24, top: 16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
