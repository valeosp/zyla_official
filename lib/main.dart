import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:menstrual_cycle_widget/menstrual_cycle_widget.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/cycle_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/user_data_provider.dart';

// Pantallas
import 'screens/welcome/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/tips/tips_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/partner_view_screen.dart';

// widget screens
import 'package:zyla/menstrual/calendar_screen.dart';
import 'widgets/initial_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('es_CO', null);

  // Inicializa el widget (usa tus claves de 32 y 16 caracteres)
  MenstrualCycleWidget.init(
    secretKey: 'TU_SECRET_KEY_DE_32_CARACTERES',
    ivKey: 'TU_IV_KEY_DE_16_CARACTERES',
  );

  runApp(const ZylaApp());
}

class ZylaApp extends StatelessWidget {
  const ZylaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CycleProvider()),
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Zyla',
        locale: const Locale('es', 'CO'),
        supportedLocales: const [Locale('es', 'CO')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: '/',
        routes: {
          '/': (_) => const InitialLoader(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/onboarding': (_) => const OnboardingScreen(),
          '/home': (_) => const HomeScreen(),
          '/history': (_) => const HistoryScreen(),
          '/tips': (_) => TipsScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/partner':
              (ctx) => PartnerViewScreen(
                partnerUid: ModalRoute.of(ctx)!.settings.arguments as String,
              ),

          '/menstrual/calendar': (_) => const CalendarScreen(),
        },
      ),
    );
  }
}
