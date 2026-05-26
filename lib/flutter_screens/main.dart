import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/jobs_screen.dart';
import 'screens/job_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/my_applications_screen.dart';
import 'screens/mis_empleos_empresa_screen.dart';   
import 'screens/publicar_empleo_screen.dart';        

class TemaApp extends ChangeNotifier {
  bool esOscuro = false;
  void toggleTema() {
    esOscuro = !esOscuro;
    notifyListeners();
  }
}

final temaApp = TemaApp();

void main() {
  runApp(const UniTrabajoApp());
}

class UniTrabajoApp extends StatefulWidget {
  const UniTrabajoApp({super.key});
  @override
  State<UniTrabajoApp> createState() => _UniTrabajoAppState();
}

class _UniTrabajoAppState extends State<UniTrabajoApp> {
  @override
  void initState() {
    super.initState();
    temaApp.addListener(_actualizar);
  }

  void _actualizar() => setState(() {});

  @override
  void dispose() {
    temaApp.removeListener(_actualizar);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniTrabajo',
      debugShowCheckedModeBanner: false,
      themeMode: temaApp.esOscuro ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge:   TextStyle(color: Colors.white),
          bodyMedium:  TextStyle(color: Colors.white),
          bodySmall:   TextStyle(color: Color(0xFFCBD5E1)),
          titleLarge:  TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall:  TextStyle(color: Colors.white),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          fillColor: Color(0xFF1E293B),
          filled: true,
          labelStyle: TextStyle(color: Colors.white70),
          hintStyle: TextStyle(color: Colors.white38),
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF334155)),
          ),
        ),
        dividerColor: const Color(0xFF334155),
        iconTheme: const IconThemeData(color: Colors.white),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.all(const Color(0xFF2563EB)),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all(Colors.white),
          trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
              ? const Color(0xFF2563EB)
              : const Color(0xFF334155)),
        ),
      ),
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/splash':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/jobs':
            return MaterialPageRoute(builder: (_) => const JobsScreen());
          case '/profile':
            return MaterialPageRoute(builder: (_) => const ProfileScreen());
          case '/admin':
            return MaterialPageRoute(builder: (_) => const AdminScreen());
          case '/favorites':
            return MaterialPageRoute(builder: (_) => const FavoritesScreen());
          case '/my-applications':
            return MaterialPageRoute(builder: (_) => const MyApplicationsScreen());

      
          case '/mis-empleos-empresa':
            return MaterialPageRoute(
              builder: (_) => const MisEmpleosEmpresaScreen());
          case '/publicar-empleo':
            return MaterialPageRoute(
              builder: (_) => const PublicarEmpleoScreen());

          case '/job-detail':
            final job = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => JobDetailScreen(job: job));
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}