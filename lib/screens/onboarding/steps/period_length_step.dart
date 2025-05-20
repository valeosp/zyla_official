import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

class PeriodLengthStep extends StatelessWidget {
  const PeriodLengthStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<OnboardingProvider>();
    final selected = prov.data.periodLength ?? 5;
    final Color primaryColor = Color(0xFFFFC6C3);

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
                Icons.calendar_today_rounded,
                size: 48,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '¿Cuántos días dura tu periodo normalmente?',
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
              'Esta información nos ayuda a personalizar tu experiencia',
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: DropdownButtonFormField<int>(
                value: selected,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                icon: Icon(Icons.keyboard_arrow_down, color: primaryColor),
                dropdownColor: Colors.white,
                items:
                    List.generate(8, (i) => i + 3)
                        .map(
                          (d) => DropdownMenuItem(
                            value: d,
                            child: Text(
                              '$d días',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (v) {
                  if (v != null) prov.setPeriodLength(v);
                },
              ),
            ),
            const Spacer(),
            Container(
              height: 8,
              width: 100,
              margin: EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: FractionallySizedBox(
                widthFactor: 0.33, // Indica primer paso de tres
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
