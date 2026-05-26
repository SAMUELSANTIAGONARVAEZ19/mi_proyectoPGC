import 'package:flutter/material.dart';
import '../data/auth_service.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    temaApp.addListener(_actualizar);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (AuthService.estaAutenticado) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  void _actualizar() => setState(() {});

  @override
  void dispose() {
    temaApp.removeListener(_actualizar);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgIcon = temaApp.esOscuro
      ? Colors.white.withOpacity(0.1)
      : Colors.white.withOpacity(0.2);

    return Scaffold(
      backgroundColor: const Color(0xFF2563EB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: bgIcon,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.work_outline, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text('UniTrabajo', style: TextStyle(
              color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Empleos para estudiantes universitarios',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}