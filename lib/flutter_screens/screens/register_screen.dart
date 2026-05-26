import 'package:flutter/material.dart';
import '../data/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fk       = GlobalKey<FormState>();
  final _nombre   = TextEditingController();
  final _apellido = TextEditingController();
  final _email    = TextEditingController();
  final _pass     = TextEditingController();
  final _tel      = TextEditingController();
  final _uni      = TextEditingController();
  bool _verPass   = false;
  bool _cargando  = false;
  String _error   = '';

  Future<void> _registrar() async {
    if (!_fk.currentState!.validate()) return;
    setState(() { _cargando = true; _error = ''; });
    await Future.delayed(const Duration(milliseconds: 400));
    final ok = await AuthService.registrar(
      email:       _email.text.trim(),
      password:    _pass.text,
      nombre:      _nombre.text.trim(),
      apellido:    _apellido.text.trim(),
      telefono:    _tel.text.trim(),
      universidad: _uni.text.trim(),
    );
    if (!mounted) return;
    setState(() => _cargando = false);
    if (ok) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _error = 'Este correo ya está registrado.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final bgScaffold = isDark ? const Color(0xFF0F172A) : const Color(0xFFEEF2FF);
    final bgCard     = isDark ? const Color(0xFF1E293B) : Colors.white;
    final bgField    = isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB);
    final borderCol  = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);
    final labelColor = isDark ? Colors.white70 : Colors.grey;
    final subColor   = isDark ? const Color(0xFF94A3B8) : Colors.grey;

    return Scaffold(
      backgroundColor: bgScaffold,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: 24, offset: const Offset(0, 8),
              )],
            ),
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _fk,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Column(children: [
                  Container(
                    width: 64, height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB), shape: BoxShape.circle),
                    child: const Icon(Icons.person_add, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text('Crear cuenta', style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  )),
                  const SizedBox(height: 4),
                  Text('Únete a UniTrabajo hoy',
                    style: TextStyle(color: subColor, fontSize: 14)),
                ])),
                const SizedBox(height: 28),
                Row(children: [
                  Expanded(child: _campo('Nombre', _nombre,
                    bgField: bgField, borderCol: borderCol, labelColor: labelColor,
                    validator: (v) => v!.isEmpty ? 'Requerido' : null)),
                  const SizedBox(width: 12),
                  Expanded(child: _campo('Apellido', _apellido,
                    bgField: bgField, borderCol: borderCol, labelColor: labelColor,
                    validator: (v) => v!.isEmpty ? 'Requerido' : null)),
                ]),
                _campo('Email universitario', _email,
                  bgField: bgField, borderCol: borderCol, labelColor: labelColor,
                  teclado: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Requerido' : null),
                _campo('Contraseña', _pass,
                  bgField: bgField, borderCol: borderCol, labelColor: labelColor,
                  esPass: true,
                  validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null),
                _campo('Teléfono (opcional)', _tel,
                  bgField: bgField, borderCol: borderCol, labelColor: labelColor,
                  teclado: TextInputType.phone),
                _campo('Universidad', _uni,
                  bgField: bgField, borderCol: borderCol, labelColor: labelColor),
                if (_error.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                        ? const Color(0xFF7F1D1D).withOpacity(0.4)
                        : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8)),
                    child: Text(_error,
                      style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13)),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _registrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _cargando
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Crear cuenta',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),
                Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('¿Ya tienes cuenta? ', style: TextStyle(fontSize: 13, color: subColor)),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text('Inicia sesión', style: TextStyle(
                      fontSize: 13, color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                  ),
                ])),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(String label, TextEditingController ctrl, {
    required Color bgField,
    required Color borderCol,
    required Color labelColor,
    bool esPass = false,
    TextInputType? teclado,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(
          fontWeight: FontWeight.w600, fontSize: 13, color: labelColor)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          obscureText: esPass && !_verPass,
          keyboardType: teclado,
          validator: validator,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            filled: true, fillColor: bgField,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderCol)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderCol)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            suffixIcon: esPass ? IconButton(
              icon: Icon(_verPass ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey),
              onPressed: () => setState(() => _verPass = !_verPass),
            ) : null,
          ),
        ),
      ]),
    );
  }
}