import 'package:flutter/material.dart';
import '../data/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _verPass    = false;
  bool _cargando   = false;
  String _error    = '';

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _cargando = true; _error = ''; });
    await Future.delayed(const Duration(milliseconds: 500));
    final ok = await AuthService.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    setState(() => _cargando = false);
    if (ok) {
      if (AuthService.esAdmin) {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      setState(() => _error = 'Email o contraseña incorrectos');
    }
  }

  void _llenarCredenciales(String email, String pass) {
    _emailCtrl.text = email;
    _passCtrl.text  = pass;
  }

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final bgPage     = isDark ? const Color(0xFF0F172A) : const Color(0xFFEEF2FF);
    final bgCard     = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor  = isDark ? Colors.white : Colors.black87;
    final subColor   = isDark ? Colors.white60 : Colors.grey;
    final fillColor  = isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);
    final cuentaBg   = isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB);

    return Scaffold(
      backgroundColor: bgPage,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: 24, offset: const Offset(0, 8))],
            ),
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Center(child: Column(children: [
                  Container(
                    width: 64, height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB), shape: BoxShape.circle),
                    child: const Icon(Icons.work, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text('Bienvenido a UniTrabajo',
                    style: TextStyle(fontSize: 24,
                      fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 4),
                  Text('Inicia sesión para continuar',
                    style: TextStyle(color: subColor, fontSize: 14)),
                ])),

                const SizedBox(height: 32),

                Text('Email',
                  style: TextStyle(fontWeight: FontWeight.w600,
                    fontSize: 14, color: textColor)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: textColor),
                  decoration: _inputDeco('tu@email.com',
                    fillColor, borderColor, subColor),
                  validator: (v) => v!.isEmpty ? 'Ingresa tu email' : null,
                ),
                const SizedBox(height: 16),

                Text('Contraseña',
                  style: TextStyle(fontWeight: FontWeight.w600,
                    fontSize: 14, color: textColor)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: !_verPass,
                  style: TextStyle(color: textColor),
                  decoration: _inputDeco('••••••••',
                    fillColor, borderColor, subColor).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _verPass ? Icons.visibility_off : Icons.visibility,
                        color: subColor),
                      onPressed: () => setState(() => _verPass = !_verPass),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? 'Ingresa tu contraseña' : null,
                ),

                if (_error.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                        ? const Color(0xFF7F1D1D).withOpacity(0.4)
                        : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8)),
                    child: Text(_error,
                      style: const TextStyle(
                        color: Color(0xFFDC2626), fontSize: 13)),
                  ),
                ],

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                        ? const Color(0xFF2563EB)
                        : Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _cargando
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                      : const Text('Iniciar Sesión',
                          style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),

                const SizedBox(height: 16),
                Center(child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('¿No tienes cuenta? ',
                      style: TextStyle(fontSize: 13, color: subColor)),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text('Regístrate aquí',
                        style: TextStyle(fontSize: 13,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w600)),
                    ),
                  ],
                )),

                const SizedBox(height: 24),
                Divider(color: borderColor),
                const SizedBox(height: 12),
                Text('Cuentas de prueba:',
                  style: TextStyle(fontSize: 13, color: subColor)),
                const SizedBox(height: 8),
                _cuentaPrueba('Estudiante', 'estudiante@universidad.edu',
                  '123456', cuentaBg, borderColor, textColor, subColor),
                const SizedBox(height: 6),
                _cuentaPrueba('Empresa', 'empresa@negocio.com',
                  '123456', cuentaBg, borderColor, textColor, subColor),
                const SizedBox(height: 6),
                _cuentaPrueba('Administrador', 'admin@unitrabajo.com',
                  'admin123', cuentaBg, borderColor, textColor, subColor),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cuentaPrueba(String rol, String email, String pass,
      Color bg, Color border, Color txtColor, Color subColor) {
    return GestureDetector(
      onTap: () => _llenarCredenciales(email, pass),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border),
        ),
        child: Row(children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rol,
                style: TextStyle(fontWeight: FontWeight.w600,
                  fontSize: 12, color: txtColor)),
              Text('$email / $pass',
                style: TextStyle(fontSize: 12, color: subColor)),
            ],
          )),
          Icon(Icons.touch_app_outlined, size: 16, color: subColor),
        ]),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, Color fillColor,
      Color borderColor, Color hintColor) =>
    InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: hintColor),
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2)),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14, vertical: 12),
    );

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }
}