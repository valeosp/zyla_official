import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

class SexualImprovementStep extends StatefulWidget {
  const SexualImprovementStep({Key? key}) : super(key: key);
  @override
  State<SexualImprovementStep> createState() => _SexualImprovementStepState();
}

class _SexualImprovementStepState extends State<SexualImprovementStep> {
  String? _selected;
  final _opts = ['Comunicación', 'Deseo', 'Placer', 'Otro'];
  final Color primaryColor = Color(0xFFFFC6C3);

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
                Icons.favorite_rounded,
                size: 48,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '¿Qué quieres mejorar en el sexo?',
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
              'Selecciona un área que te gustaría desarrollar',
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(children: _buildOptions()),
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
                widthFactor: 0.66, // Indica segundo paso de tres
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

  List<Widget> _buildOptions() {
    List<Widget> options = [];

    for (int i = 0; i < _opts.length; i++) {
      options.add(
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.vertical(
              top: i == 0 ? Radius.circular(24) : Radius.zero,
              bottom: i == _opts.length - 1 ? Radius.circular(24) : Radius.zero,
            ),
            onTap: () {
              setState(() => _selected = _opts[i]);
              context.read<OnboardingProvider>().setSexualImprovement(_opts[i]);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color:
                    _selected == _opts[i]
                        ? primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                border:
                    i < _opts.length - 1
                        ? Border(
                          bottom: BorderSide(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        )
                        : null,
                borderRadius: BorderRadius.vertical(
                  top: i == 0 ? Radius.circular(24) : Radius.zero,
                  bottom:
                      i == _opts.length - 1 ? Radius.circular(24) : Radius.zero,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    margin: EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            _selected == _opts[i]
                                ? primaryColor
                                : Colors.grey.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child:
                        _selected == _opts[i]
                            ? Container(
                              margin: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor,
                              ),
                            )
                            : null,
                  ),
                  Text(
                    _opts[i],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          _selected == _opts[i]
                              ? FontWeight.w600
                              : FontWeight.normal,
                      color:
                          _selected == _opts[i]
                              ? Colors.black87
                              : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return options;
  }
}
